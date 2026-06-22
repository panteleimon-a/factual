import 'package:flutter/foundation.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';
import '../services/database_service.dart';
import '../services/llm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_activity_service.dart';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService;

  NewsProvider(this._newsService) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _usePersonalizedFeed = prefs.getBool('use_personalized_feed') ?? false;
    notifyListeners();
  }

  // State
  List<NewsArticle> _articles = [];
  List<NewsArticle> _regionalArticles = [];
  bool _isLoading = false;
  bool _isRegionalLoading = false;
  String? _error;
  String _currentQuery = '';
  String? _selectedSource;
  String? _selectedSentiment;
  bool _usePersonalizedFeed = false;
  Map<String, Map<String, dynamic>> _globalContexts = {};
  bool _isGlobalContextLoading = false;

  // Getters
  Map<String, dynamic>? _factCheckResult;

  // Getters
  List<NewsArticle> get articles => _articles;
  List<NewsArticle> get regionalArticles => _regionalArticles;
  bool get isLoading => _isLoading;
  bool get isRegionalLoading => _isRegionalLoading;
  String? get error => _error;
  String get currentQuery => _currentQuery;
  String? get selectedSource => _selectedSource;
  String? get selectedSentiment => _selectedSentiment;
  bool get usePersonalizedFeed => _usePersonalizedFeed;
  Map<String, Map<String, dynamic>> get globalContexts => _globalContexts;
  bool get isGlobalContextLoading => _isGlobalContextLoading;
  Map<String, dynamic>? get factCheckResult => _factCheckResult;

  List<NewsArticle> get filteredArticles {
    var filtered = _articles;

    if (_selectedSource != null) {
      filtered = filtered.where((a) => a.source.name == _selectedSource).toList();
    }

    if (_selectedSentiment != null) {
      filtered = filtered.where((a) => a.sentiment == _selectedSentiment).toList();
    }

    return filtered;
  }

  // Methods
  Future<void> loadRegionalHeadlines({String? country}) async {
    _isRegionalLoading = true;
    notifyListeners();

    try {
      _regionalArticles = await _newsService.getTopHeadlines(
        country: country ?? 'us',
        category: 'general',
      );
      
      // Filter out articles without images to improve carousel aesthetics
      _regionalArticles = _regionalArticles
          .where((a) => a.imageUrl != null && a.imageUrl!.isNotEmpty)
          .toList();
    } catch (e) {
      print('Regional load error: $e');
      _regionalArticles = [];
    } finally {
      _isRegionalLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query, {String? country, String? category, LLMService? llmService}) async {
    _isLoading = true;
    _error = null;
    _currentQuery = query;
    _factCheckResult = null; // Reset previous result
    notifyListeners();

    try {
      // Parallel execution: Fetch news + Perform Fact Check (if service provided)
      final List<Future<dynamic>> futures = [
        _newsService.searchNews(query, country: country, category: category),
        if (llmService != null) 
          llmService.performFactCheck(query)
            .catchError((e) => <String, dynamic>{'error': e.toString()})
        else 
          Future<dynamic>.value(null)
      ];
      final results = await Future.wait(futures);

      _articles = results[0] as List<NewsArticle>;
      if (results.length > 1 && results[1] != null) {
        _factCheckResult = results[1] as Map<String, dynamic>;
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTopHeadlines({String? country, String? category}) async {
    _isLoading = true;
    _error = null;
    _currentQuery = 'Top Headlines';
    notifyListeners();

    try {
      _articles = await _newsService.getTopHeadlines(
        country: country ?? 'us',
        category: category ?? 'general',
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCachedArticles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _articles = await _newsService.getCachedArticles();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSourceFilter(String? source) {
    _selectedSource = source;
    notifyListeners();
  }

  void setSentimentFilter(String? sentiment) {
    _selectedSentiment = sentiment;
    notifyListeners();
  }

  void clearFilters() {
    _selectedSource = null;
    _selectedSentiment = null;
    notifyListeners();
  }

  Future<void> loadGlobalContexts(LLMService llmService, {int count = 10}) async {
    if (_articles.isEmpty) return;
    
    _isGlobalContextLoading = true;
    notifyListeners();

    try {
      // Analyze up to 'count' articles (Utility C)
      final itemsToAnalyze = _articles.take(count).toList();
      for (var article in itemsToAnalyze) {
        // Skip if already has context to save LLM quota
        if (!_globalContexts.containsKey(article.id) || _globalContexts[article.id] == null) {
          try {
            final contextData = await llmService.generateGlobalContext(article);
            _globalContexts[article.id] = contextData;
            notifyListeners();
          } catch (e) {
            print('Global context error for ${article.id}: $e');
            // If we hit 429, stop the batch to prevent further errors
            if (e.toString().contains('429') || e.toString().contains('quota')) {
              break; 
            }
          }
        }
      }
    } catch (e) {
      print('Global context load error: $e');
    } finally {
      _isGlobalContextLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePersonalizedFeed(bool value, String userId, {String? location}) async {
    _usePersonalizedFeed = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_personalized_feed', value);
    
    if (_usePersonalizedFeed) {
      await loadPersonalizedNews(userId, location: location);
    } else {
      await loadTopHeadlines();
    }
  }

  Future<void> loadPersonalizedNews(String userId, {String? location}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userActivityService = UserActivityService();
      final llmService = LLMService(); // Get initialized instance
      
      // 1. Get User Interests (Local Fallback included)
      final topTopics = await userActivityService.getTopInterests(userId);
      
      if (topTopics.isEmpty) {
        // Fallback to top headlines if no interaction history
        await loadTopHeadlines();
        return;
      }

      // 2. Generate Adaptive Feed Parameters (AI-Driven)
      List<String> adaptiveQueries = [];
      try {
        adaptiveQueries = await llmService.generateAdaptiveFeedParams(topTopics, location: location);
      } catch (e) {
        print('Adaptive params failed, using raw topics: $e');
        adaptiveQueries = topTopics.take(3).toList();
      }

      // 3. Fetch Personal Results (Merge top 3 adaptive queries)
      List<NewsArticle> personalResults = [];
      for (var query in adaptiveQueries.take(3)) {
        // Use 'searchNews' for each AI-generated query
        final results = await _newsService.searchNews(query);
        personalResults.addAll(results);
      }
      
      // 4. Remove duplicates and notify
      _articles = personalResults.toSet().toList();
      _error = null;
    } catch (e) {
      print('Personalization error: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSmartFeed(String userId, {String? location}) async {
    // If user has explicitly enabled personalized feed, try to load it.
    // Otherwise, load top headlines.
    if (_usePersonalizedFeed) {
      await loadPersonalizedNews(userId, location: location);
    } else {
      await loadTopHeadlines();
    }
  }

  Future<void> analyzeArticle(String articleId) async {
    final article = _articles.firstWhere(
      (a) => a.id == articleId, 
      orElse: () => _regionalArticles.firstWhere((a) => a.id == articleId),
    );
    
    // Skip if already analyzed
    if (_globalContexts.containsKey(articleId)) return;

    try {
      final llmService = LLMService(); // Get initialized instance
      final contextData = await llmService.generateGlobalContext(article);
      _globalContexts[articleId] = contextData;
      notifyListeners();
    } catch (e) {
      print('Error analyzing article $articleId: $e');
    }
  }

  void clearResults() {
    _articles = [];
    _currentQuery = '';
    _error = null;
    notifyListeners();
  }

  @visibleForTesting
  void setArticlesForTest(List<NewsArticle> articles) {
    _articles = articles;
    notifyListeners();
  }
}
