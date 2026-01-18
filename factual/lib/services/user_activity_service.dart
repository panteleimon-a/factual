import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'database_service.dart';
import '../models/search_query.dart';

class UserActivityService {
  bool get _isFirebaseAvailable {
    try {
      Firebase.app();
      return true;
    } catch (_) {
      return false;
    }
  }

  FirebaseFirestore? get _firestore => _isFirebaseAvailable ? FirebaseFirestore.instance : null;
  FirebaseAnalytics? get _analytics => _isFirebaseAvailable ? FirebaseAnalytics.instance : null;
  final DatabaseService _dbService = DatabaseService();

  /// Tracks an article view for personalization.
  /// Strategy: Log to Local DB immediately, cloud sync via syncPendingActivity.
  Future<void> trackArticleView(String userId, String articleId, List<String> topics) async {
    try {
      // 1. Log to SQLite
      await _dbService.logArticleView(userId, articleId, topics);
      print('Logged article view locally: $articleId');
    } catch (e) {
      print('Error tracking article view locally: $e');
    }
  }

  /// Tracks a search query for personalization.
  /// Strategy: Syncing search queries is handled primarily by ChatHubScreen logging to SQLite.
  /// This method can be used for extra cloud tracking if needed.
  Future<void> trackSearchQuery(String userId, String query) async {
    // Note: Search queries are already inserted into SQLite in ChatHubScreen.
    // We don't need to double-insert here, just ensure sync happens.
  }

  /// Updates user location in the cloud for regional adaptation and analytics.
  Future<void> updateUserLocation(String userId, double lat, double lng, String? country) async {
    try {
      // 1. ANALYTICS
      await _analytics?.logEvent(
        name: 'location_update',
        parameters: {
          'latitude': lat,
          'longitude': lng,
          'country': country ?? 'unknown',
        },
      );

      // 2. FIRESTORE
      await _firestore?.collection('users').doc(userId).set({
        'current_location': {
          'lat': lat,
          'lng': lng,
          'country': country,
          'updated_at': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user location: $e');
    }
  }

  /// Syncs all unsynced local activity to Firestore and Analytics.
  /// Should be called on app startup or after login.
  Future<void> syncPendingActivity(String userId) async {
    try {
      final db = await _dbService.database;

      // 1. Sync Search Queries
      final List<Map<String, dynamic>> unsyncedSearches = await db.query(
        'search_queries',
        where: 'userId = ? AND isSynced = 0',
        whereArgs: [userId],
      );

      for (var map in unsyncedSearches) {
        final query = map['query'] as String;
        
        // Push to Analytics
        await _analytics?.logEvent(
          name: 'search_query',
          parameters: {'query': query},
        );

        // Push to Firestore
        await _firestore?.collection('users').doc(userId).set({
          'recent_searches': FieldValue.arrayUnion([query]),
          'last_active': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Mark as synced locally
        await db.update(
          'search_queries',
          {'isSynced': 1},
          where: 'id = ?',
          whereArgs: [map['id']],
        );
      }

      // 2. Sync Article Views (Interactions)
      final List<Map<String, dynamic>> unsyncedInteractions = await db.query(
        'user_interactions',
        where: 'userId = ? AND isSynced = 0',
        whereArgs: [userId],
      );

      for (var map in unsyncedInteractions) {
        final topics = (map['topics'] as String?)?.split(',') ?? [];
        
        // Push to Analytics and Firestore for each topic
        for (var topic in topics) {
          if (topic.trim().isEmpty) continue;
          
          await _analytics?.logEvent(
            name: 'view_article',
            parameters: {'topic': topic.trim()},
          );

          await _firestore?.collection('users').doc(userId).set({
            'interest_scores': {
              topic.trim(): FieldValue.increment(1),
            },
            'last_active': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        // Mark as synced locally
        await db.update(
          'user_interactions',
          {'isSynced': 1},
          where: 'id = ?',
          whereArgs: [map['id']],
        );
      }

      print('Successfully synced ${unsyncedSearches.length} searches and ${unsyncedInteractions.length} interactions.');
    } catch (e) {
      print('Error syncing pending activity: $e');
    }
  }

  /// Retrieves the top interests for a user from Firestore
  Future<List<String>> getTopInterests(String userId) async {
    List<String> interests = [];
    
    // 1. Try Firestore if available
    if (_isFirebaseAvailable) {
      try {
        final doc = await _firestore!.collection('users').doc(userId).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data.containsKey('interest_scores')) {
            final scores = data['interest_scores'] as Map<String, dynamic>;
            final sortedEntries = scores.entries.toList()
              ..sort((a, b) => (b.value as num).compareTo(a.value as num));
            interests = sortedEntries.map((e) => e.key).toList();
          }
        }
      } catch (e) {
        print('Firestore fetch failed: $e. Falling back to specific local DB.');
      }
    }

    // 2. Fallback to Local DB (SQLite) if no results from cloud
    if (interests.isEmpty) {
      try {
        interests = await _dbService.getTopInterestedTopics(userId);
        print('Fetched interests from local DB: $interests');
      } catch (e) {
        print('Local DB fetch failed: $e');
      }
    }

    return interests;
  }
}
