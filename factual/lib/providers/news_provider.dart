import 'package:flutter/foundation.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';
import '../services/database_service.dart';
import '../services/llm_service.dart';
import '../services/user_activity_service.dart';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService;

  NewsProvider(this._newsService);

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
      final results = await Future.wait([
        _newsService.searchNews(query, country: country, category: category),
        if (llmService != null) 
          llmService.performFactCheck(query)
            .catchError((e) => <String, dynamic>{'error': e.toString()})
        else 
          Future.value(null)
      ]);

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
        if (!_globalContexts.containsKey(article.id)) {
          final contextData = await llmService.generateGlobalContext(article);
          _globalContexts[article.id] = contextData;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Global context load error: $e');
    } finally {
      _isGlobalContextLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePersonalizedFeed(bool value, String userId) async {
    _usePersonalizedFeed = value;
    if (_usePersonalizedFeed) {
      await loadPersonalizedNews(userId);
    } else {
      await loadTopHeadlines();
    }
  }

  Future<void> loadPersonalizedNews(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userActivityService = UserActivityService();
      final topTopics = await userActivityService.getTopInterests(userId);
      
      if (topTopics.isEmpty) {
        // Fallback to top headlines if no interaction history
        await loadTopHeadlines();
        return;
      }

      // Merge results from top 3 topics
      List<NewsArticle> personalResults = [];
      for (var topic in topTopics.take(3)) {
        final results = await _newsService.searchNews(topic);
        personalResults.addAll(results);
      }
      
      // Remove duplicates and notify
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

  Future<void> loadSmartFeed(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userActivityService = UserActivityService();
      // Check if user has any interaction history
      final topTopics = await userActivityService.getTopInterests(userId);
      
      if (topTopics.isNotEmpty) {
        // User has history, load personalized
        _usePersonalizedFeed = true;
        await loadPersonalizedNews(userId);
      } else {
        // No history, load generic
        _usePersonalizedFeed = false;
        await loadTopHeadlines();
      }
    } catch (e) {
      print('Smart feed error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
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
