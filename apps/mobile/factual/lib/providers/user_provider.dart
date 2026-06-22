import 'package:flutter/foundation.dart';
import '../services/user_activity_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user.dart';
import '../models/search_query.dart';
import '../models/news_article.dart';
import '../services/database_service.dart';
import '../services/llm_service.dart';
import 'package:uuid/uuid.dart';

/// Provider for user state and personalization
class UserProvider extends ChangeNotifier {
  UserProvider() {
    initializeUser();
  }

  final DatabaseService _db = DatabaseService();
  final LLMService _llm = LLMService();
  final Uuid _uuid = const Uuid();
  final UserActivityService _activityService = UserActivityService();

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

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  /// Initialize or load user
  Future<void> initializeUser() async {
    _isLoading = true;
    notifyListeners();

    // Listen to Firebase Auth state changes
    _auth.authStateChanges().listen((auth.User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      } else {
        print("User detected: ${firebaseUser.uid}");
        // Map Firebase User to our local User model
        await _syncUserFromFirebase(firebaseUser);
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  /// Helper to sync Firebase user data with local database
  Future<void> _syncUserFromFirebase(auth.User firebaseUser) async {
    try {
      var localUser = await _db.getUser(firebaseUser.uid);
      
      if (localUser == null) {
        // New user or first time sync
        localUser = User(
          id: firebaseUser.uid,
          username: firebaseUser.displayName ?? 'User${firebaseUser.uid.substring(0, 5)}',
          email: firebaseUser.email ?? '',
          createdAt: DateTime.now(), // In a real app, sync this from Firestore
          lastActive: DateTime.now(),
        );
        await _db.insertUser(localUser);
      }
      
      _currentUser = localUser;
      
      // Load user data
      await _loadSearchHistory();
      await _loadRecommendations();
      await _loadTrendingTopics();
      
      // Sync pending activity to Firebase/Analytics
      await _activityService.syncPendingActivity(firebaseUser.uid);
    } catch (e) {
      _error = 'Failed to sync user data: $e';
      notifyListeners();
    }
  }

  /// Sign Up with Email and Password
  Future<void> signUp(String email, String password, String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      auth.UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Update display name
      if (credential.user != null) {
        await credential.user!.updateDisplayName(username);
        // Force reload to get updated display name
        await credential.user!.reload();
      }
      
      // Initialization listener will handle the rest
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign In with Email and Password
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Initialization listener will handle the rest
    } catch (e) {
      _error = 'Sign in failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign In Anonymously (Guest Mode for Beta Testing)
  Future<void> signInAnonymously() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.signInAnonymously();
      // Initialization listener will handle the rest
    } catch (e) {
      _error = 'Guest login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      _searchHistory = [];
      notifyListeners();
    } catch (e) {
      _error = 'Sign out failed: $e';
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

      // Track to Analytics/Firestore
      // Note: syncPendingActivity will pick it up later if we don't call it here, 
      // but trackSearchQuery logic in service is empty/placeholder.
      // However, we should ensure the location is updated too.
      if (location != null) {
          // Extract lat/lng if possible or just log generic
          // For now, we rely on the sync call which reads from SQLite.
          // But we need to trigger a sync or write.
          // The UserActivityService.syncPendingActivity scans SQLite.
          // So we just need to call it.
          await _activityService.syncPendingActivity(_currentUser!.id);
      } else {
         await _activityService.syncPendingActivity(_currentUser!.id);
      }

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
