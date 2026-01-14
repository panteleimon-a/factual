import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/search_query.dart';
import '../models/news_article.dart';
import '../services/database_service.dart';
import '../services/llm_service.dart';
import 'package:uuid/uuid.dart';

/// Provider for user state and personalization
class UserProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final LLMService _llm = LLMService();
  final Uuid _uuid = const Uuid();

  User? _currentUser;
  List<SearchQuery> _searchHistory = [];
  List<NewsArticle> _recommendations = [];
  List<Map<String, dynamic>> _trendingTopics = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  List<SearchQuery> get searchHistory => _searchHistory;
  List<NewsArticle> get recommendations => _recommendations;
  List<String> get trendingTopics => _trendingTopics.map((t) => t['query'] as String).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  /// Initialize or load user
  Future<void> initializeUser({String? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (userId != null) {
        // Load existing user
        _currentUser = await _db.getUser(userId);
      }

      if (_currentUser == null) {
        // Create new user
        _currentUser = User(
          id: _uuid.v4(),
          username: 'User${DateTime.now().millisecondsSinceEpoch}',
          email: '',
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        await _db.insertUser(_currentUser!);
      }

      // Load user data
      await _loadSearchHistory();
      await _loadRecommendations();
      await _loadTrendingTopics();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize user: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Track a new search
  Future<void> trackSearch(String query, {String? location}) async {
    if (_currentUser == null) return;

    try {
      // Analyze sentiment
      final sentimentResult = await _llm.analyzeSentiment(query);

      // Create search query
      final searchQuery = SearchQuery(
        id: _uuid.v4(),
        userId: _currentUser!.id,
        query: query,
        sentiment: sentimentResult['sentiment'] ?? 'neutral',
        timestamp: DateTime.now(),
        location: location,
      );

      // Save to database
      await _db.insertSearchQuery(searchQuery);

      // Update user's last active
      _currentUser = _currentUser!.copyWith(lastActive: DateTime.now());
      await _db.updateUser(_currentUser!);

      // Reload history
      await _loadSearchHistory();

      // Update recommendations based on new search
      await _generateRecommendations();

      notifyListeners();
    } catch (e) {
      _error = 'Failed to track search: $e';
      notifyListeners();
    }
  }

  /// Load search history
  Future<void> _loadSearchHistory() async {
    if (_currentUser == null) return;

    try {
      _searchHistory = await _db.getUserSearchHistory(_currentUser!.id, limit: 50);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load search history: $e';
    }
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    if (_currentUser == null) return;

    try {
      await _db.clearUserSearchHistory(_currentUser!.id);
      _searchHistory = [];
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear history: $e';
      notifyListeners();
    }
  }

  /// Delete specific search
  Future<void> deleteSearch(String searchId) async {
    try {
      await _db.deleteSearchQuery(searchId);
      _searchHistory.removeWhere((s) => s.id == searchId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete search: $e';
      notifyListeners();
    }
  }

  /// Generate personalized recommendations
  Future<void> _generateRecommendations() async {
    if (_currentUser == null || _searchHistory.isEmpty) {
      _recommendations = [];
      return;
    }

    try {
      // Get recent search topics
      final recentSearches = _searchHistory.take(10).map((s) => s.query).toList();

      // Load articles from database
      final allArticles = await _db.getArticles(limit: 100);

      // Simple recommendation: match articles with search keywords
      final recommended = <NewsArticle>[];
      for (var article in allArticles) {
        for (var search in recentSearches) {
          if (article.title.toLowerCase().contains(search.toLowerCase()) ||
              article.summary.toLowerCase().contains(search.toLowerCase())) {
            if (!recommended.contains(article)) {
              recommended.add(article);
            }
          }
        }
      }

      _recommendations = recommended.take(20).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to generate recommendations: $e';
    }
  }

  /// Load recommendations
  Future<void> _loadRecommendations() async {
    await _generateRecommendations();
  }

  /// Refresh recommendations
  Future<void> refreshRecommendations() async {
    _isLoading = true;
    notifyListeners();
    await _generateRecommendations();
    _isLoading = false;
    notifyListeners();
  }

  /// Load trending topics by region
  Future<void> _loadTrendingTopics({String? region}) async {
    try {
      final regionToUse = region ?? _currentUser?.location ?? 'global';
      _trendingTopics = await _db.getPopularSearchesByRegion(regionToUse, limit: 10);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load trending topics: $e';
    }
  }

  /// Refresh trending topics
  Future<void> refreshTrendingTopics({String? region}) async {
    _isLoading = true;
    notifyListeners();
    await _loadTrendingTopics(region: region);
    _isLoading = false;
    notifyListeners();
  }

  /// Set user location
  Future<void> setUserLocation(String location) async {
    if (_currentUser == null) return;

    try {
      _currentUser = _currentUser!.copyWith(location: location);
      await _db.updateUser(_currentUser!);
      
      // Refresh trending topics for new location
      await _loadTrendingTopics(region: location);
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update location: $e';
      notifyListeners();
    }
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences(String key, String value) async {
    if (_currentUser == null) return;

    try {
      await _db.setPreference(_currentUser!.id, key, value);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update preferences: $e';
      notifyListeners();
    }
  }

  /// Get notification preference
  Future<String?> getNotificationPreference(String key) async {
    if (_currentUser == null) return null;
    return await _db.getPreference(_currentUser!.id, key);
  }

  /// Get all preferences
  Future<Map<String, String>> getAllPreferences() async {
    if (_currentUser == null) return {};
    return await _db.getAllPreferences(_currentUser!.id);
  }

  /// Subscribe to topic for notifications
  Future<void> subscribeToTopic(String topic) async {
    await updateNotificationPreferences('notification_topic_$topic', 'true');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (_currentUser == null) return;
    await _db.deletePreference(_currentUser!.id, 'notification_topic_$topic');
    notifyListeners();
  }

  /// Get subscribed topics
  Future<List<String>> getSubscribedTopics() async {
    final prefs = await getAllPreferences();
    return prefs.keys
        .where((k) => k.startsWith('notification_topic_'))
        .map((k) => k.replaceFirst('notification_topic_', ''))
        .toList();
  }

  /// Get recommendation score for an article
  double getRecommendationScore(NewsArticle article) {
    if (_searchHistory.isEmpty) return 0.5;

    int matchCount = 0;
    for (var search in _searchHistory.take(10)) {
      if (article.title.toLowerCase().contains(search.query.toLowerCase()) ||
          article.summary.toLowerCase().contains(search.query.toLowerCase())) {
        matchCount++;
      }
    }

    return (matchCount / 10).clamp(0.0, 1.0);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
