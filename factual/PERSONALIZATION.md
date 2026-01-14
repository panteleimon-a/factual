# User Personalization & Recommendations - Usage Guide

## Overview

The Factual app provides comprehensive user modeling and personalization through automatic search tracking, AI-powered recommendations, regional trending topics, and customizable notification preferences.

## Components

### 1. UserProvider
**File**: `lib/providers/user_provider.dart`

Central state management for all personalization features.

### 2. Widgets
- **PastSearchesWidget** - Display and manage search history
- **TrendingTopicsWidget** - Show popular searches in user's region
- **RecommendationsWidget** - Personalized article feed
- **NotificationSettingsWidget** - Topic subscription management

---

## Setup

### 1. Add Provider to App

```dart
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider()..initializeUser(),
      child: const FactualApp(),
    ),
  );
}
```

### 2. Initialize User

```dart
final userProvider = Provider.of<UserProvider>(context, listen: false);
await userProvider.initializeUser();
```

---

## Features

### Search Tracking

**Automatic tracking** of all user searches with sentiment analysis:

```dart
final userProvider = Provider.of<UserProvider>(context, listen: false);

// Track a search
await userProvider.trackSearch(
  'political scandal',
  location: 'Washington DC',
);
```

**What happens:**
1. Sentiment analyzed by LLM
2. Saved to database with timestamp
3. Updates user's last active time
4. Refreshes recommendations
5. Increments regional trending count

### Past Searches

Display search history with swipe-to-delete:

```dart
import 'package:factual/widgets/past_searches_widget.dart';

// In your screen
const PastSearchesWidget()
```

**Features:**
- ✅ Shows all past searches
- ✅ Sentiment badges (colored)
- ✅ Time ago formatting
- ✅ Location tags
- ✅ Swipe right to delete
- ✅ Tap to re-execute search
- ✅ "Clear All" button

### Personalized Recommendations

AI-powered article recommendations based on search history:

```dart
import 'package:factual/widgets/recommendations_widget.dart';

// In your screen
const RecommendationsWidget()
```

**Algorithm:**
1. Analyzes last 10 searches
2. Loads cached articles from database
3. Matches keywords from searches to article titles/summaries
4. Ranks by relevance
5. Shows top 20 recommendations

**Refresh manually:**
```dart
await userProvider.refreshRecommendations();
```

### Trending Topics

Regional popularity-based trending:

```dart
import 'package:factual/widgets/trending_topics_widget.dart';

// In your screen
const TrendingTopicsWidget()
```

**Features:**
- Shows top 5 popular searches in user's region
- Search count badges
- Tap to execute search
- Auto-updates when region changes

**Refresh:**
```dart
await userProvider.refreshTrendingTopics(region: 'New York');
```

### Notification Preferences

Topic-based push notification subscriptions:

```dart
import 'package:factual/widgets/notification_settings_widget.dart';

// In your screen
const NotificationSettingsWidget()
```

**Available Topics:**
- Breaking News
- Politics
- Technology
- Business
- Sports
- Entertainment
- Science
- Health

**Managing subscriptions:**
```dart
// Subscribe
await userProvider.subscribeToTopic('Technology');

// Unsubscribe
await userProvider.unsubscribeFromTopic('Politics');

// Get all subscribed topics
final topics = await userProvider.getSubscribedTopics();
```

---

## UserProvider API

### Properties

```dart
User? currentUser              // Current user object
List<SearchQuery> searchHistory  // All search queries
List<NewsArticle> recommendations  // Personalized articles
List<Map> trendingTopics        // Regional trending searches
bool isLoading                  // Loading state
String? error                   // Error message
bool isLoggedIn                 // Authentication status
```

### Methods

#### User Management
```dart
await initializeUser({String? userId})
await setUserLocation(String location)
```

#### Search Tracking
```dart
await trackSearch(String query, {String? location})
await deleteSearch(String searchId)
await clearSearchHistory()
```

#### Recommendations
```dart
await refreshRecommendations()
double getRecommendationScore(NewsArticle article)
```

#### Trending Topics
```dart
await refreshTrendingTopics({String? region})
```

#### Notifications
```dart
await subscribeToTopic(String topic)
await unsubscribeFromTopic(String topic)
Future<List<String>> getSubscribedTopics()
await updateNotificationPreferences(String key, String value)
Future<String?> getNotificationPreference(String key)
```

---

## Complete Example - Profile Screen

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/past_searches_widget.dart';
import '../widgets/trending_topics_widget.dart';
import '../widgets/recommendations_widget.dart';
import '../widgets/notification_settings_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userProvider.error != null) {
            return Center(child: Text('Error: ${userProvider.error}'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // User info
                _buildUserInfo(userProvider),
                
                // Trending topics
                const TrendingTopicsWidget(),
                
                // Notification settings
                const NotificationSettingsWidget(),
                
                // Past searches
                SizedBox(
                  height: 300,
                  child: const PastSearchesWidget(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(UserProvider userProvider) {
    final user = userProvider.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('${userProvider.searchHistory.length} searches'),
            Text('${userProvider.recommendations.length} recommendations'),
          ],
        ),
      ),
    );
  }
}
```

---

## Home Screen Integration

```dart
import 'package:flutter/material.dart';
import '../widgets/trending_topics_widget.dart';
import '../widgets/recommendations_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Factual')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search bar
            _buildSearchBar(context),
            
            // Trending topics
            const TrendingTopicsWidget(),
            
            // Personalized recommendations
            const RecommendationsWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search news...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onSubmitted: (query) async {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          await userProvider.trackSearch(query);
          // Navigate to search results
        },
      ),
    );
  }
}
```

---

## Data Persistence

All data is automatically persisted to SQLite via DatabaseService:

### Tables Used
- **users** - User profiles
- **search_queries** - Search history with sentiment
- **popular_searches** - Regional trending topics
- **user_preferences** - Notification subscriptions
- **news_articles** - Cached for recommendations

### Data Flow

```
User searches
    ↓
trackSearch() called
    ↓
LLM analyzes sentiment
    ↓
Save to search_queries table
    ↓
Update popular_searches (increment count)
    ↓
Update user last_active
    ↓
Generate recommendations (keyword matching)
    ↓
UI updates automatically (ChangeNotifier)
```

---

## Performance Optimization

### 1. Lazy Loading
- Search history limited to 50 items
- Recommendations capped at 20
- Trending topics max 10

### 2. Caching
- User object cached in provider
- Recommendations refreshed on demand
- Database queries optimized

### 3. Async Operations
```dart
// Good - non-blocking
userProvider.trackSearch(query); // Fire and forget

// For critical operations
await userProvider.trackSearch(query); // Wait for completion
```

---

## Testing Recommendations

### Add Test Data

```dart
// Create some searches
final userProvider = Provider.of<UserProvider>(context, listen: false);
await userProvider.trackSearch('technology news');
await userProvider.trackSearch('AI developments');
await userProvider.trackSearch('climate change');

// Add test articles to database
final db = DatabaseService();
await db.insertArticles([/* test articles */]);

// Refresh recommendations
await userProvider.refreshRecommendations();
```

---

## Troubleshooting

### No Recommendations Showing
1. Ensure user has search history
2. Verify articles exist in database with matching keywords
3. Check recommendation algorithm in `_generateRecommendations()`

### Trending Topics Empty
1. Ensure searches have location set
2. Check `popular_searches` table has data
3. Verify region name matches

### Notifications Not Working
1. Check Android permissions in manifest
2. Verify `user_preferences` table
3. Ensure topic names match exactly

---

## Future Enhancements

1. **Machine Learning**
   - TensorFlow Lite model for better recommendations
   - Collaborative filtering

2. **Social Features**
   - Share searches with friends
   - Follow other users' interests

3. **Advanced Analytics**
   - Time-of-day preferences
   - Topic affinity scoring
   - Reading time prediction

4. **Smart Notifications**
   - Breaking news from subscribed topics
   - Scheduled digest emails
   - Location-based alerts

---

**All personalization features are fully functional and integrated!** ✅
