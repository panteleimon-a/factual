import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class UserActivityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Tracks an article view for both immediate personalization (Firestore)
  /// and long-term analysis (Analytics).
  Future<void> trackArticleView(String userId, String topic) async {
    try {
      // 1. ANALYTICS: Log for historical reporting
      await _analytics.logEvent(
        name: 'view_article',
        parameters: {'topic': topic},
      );

      // 2. FIRESTORE: Update "Interest Profile" for immediate adaptation
      final userRef = _db.collection('users').doc(userId);
      
      // "Atomic Increment" ensures accuracy even if they click fast
      await userRef.set({
        'interest_scores': {
          topic: FieldValue.increment(1), 
        },
        'last_active': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('Tracked view for topic: $topic');
    } catch (e) {
      print('Error tracking article view: $e');
    }
  }

  /// Retrieves the top interests for a user from Firestore
  Future<List<String>> getTopInterests(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      
      if (!doc.exists || doc.data() == null) {
        return [];
      }

      final data = doc.data()!;
      if (!data.containsKey('interest_scores')) return [];

      final scores = data['interest_scores'] as Map<String, dynamic>;
      if (scores.isEmpty) return [];

      // Sort interests by score (descending)
      final sortedEntries = scores.entries.toList()
        ..sort((a, b) => (b.value as num).compareTo(a.value as num));

      // Return keys (topics)
      return sortedEntries.map((e) => e.key).toList();
    } catch (e) {
      print('Error fetching interests: $e');
      return [];
    }
  }
}
