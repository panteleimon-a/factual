# DatabaseService - Usage Guide

## Overview

The `DatabaseService` is a comprehensive SQLite database manager that handles all persistent data for the Factual app. It provides full CRUD operations for users, search queries, news articles, sources, and user preferences.

## Database Schema

### Tables

1. **users** - User profiles and metadata
2. **search_queries** - User search history with sentiment
3. **news_sources** - News outlet information and credibility
4. **news_articles** - Cached news articles with location data
5. **popular_searches** - Trending searches by geographic region
6. **user_preferences** - User settings and preferences

### Indexes

- `idx_search_userId` - Fast user search history lookup
- `idx_search_timestamp` - Chronological search queries
- `idx_article_publishedAt` - Latest news sorting
- `idx_popular_region` - Regional trending searches

---

## Usage Examples

### Initialize Database

```dart
import 'package:factual/services/database_service.dart';

final db = DatabaseService();
await db.database; // Initializes if not already done
```

---

## User Operations

### Create User

```dart
final user = User(
  id: 'user123',
  username: 'john_doe',
  email: 'john@example.com',
  createdAt: DateTime.now(),
  lastActive: DateTime.now(),
);

await db.insertUser(user);
```

### Get User

```dart
final user = await db.getUser('user123');
if (user != null) {
  print('Welcome ${user.username}!');
}
```

### Update User

```dart
final updatedUser = user.copyWith(
  lastActive: DateTime.now(),
);
await db.updateUser(updatedUser);
```

### Delete User

```dart
await db.deleteUser('user123');
```

---

## Search Query Operations

### Save Search Query

```dart
final query = SearchQuery(
  id: 'query123',
  userId: 'user123',
  query: 'political news',
  sentiment: 'neutral',
  timestamp: DateTime.now(),
  location: 'New York',
);

// Automatically updates popular searches for the region
await db.insertSearchQuery(query);
```

### Get User Search History

```dart
final history = await db.getUserSearchHistory('user123', limit: 20);

for (var search in history) {
  print('${search.timestamp}: ${search.query}');
}
```

### Get Recent Searches (All Users)

```dart
final recent = await db.getRecentSearches(limit: 10);
```

### Clear User History

```dart
await db.clearUserSearchHistory('user123');
```

---

## News Article Operations

### Cache News Article

```dart
final source = NewsSource(
  id: 'cnn',
  name: 'CNN',
  url: 'https://cnn.com',
  country: 'United States',
  language: 'en',
  credibilityScore: 0.75,
);

final article = NewsArticle(
  id: 'article123',
  title: 'Breaking News',
  summary: 'Important story...',
  source: source,
  url: 'https://cnn.com/article',
  publishedAt: DateTime.now(),
  topics: ['politics', 'economy'],
  location: 'Washington DC',
  isVerified: true,
);

// Automatically saves the source if it doesn't exist
await db.insertArticle(article);
```

### Batch Insert Articles

```dart
List<NewsArticle> articles = [...]; // Your articles
await db.insertArticles(articles);
```

### Get Cached Articles

```dart
// Get all articles
final allArticles = await db.getArticles(limit: 50);

// Get articles by topic
final politicsArticles = await db.getArticles(topic: 'politics');

// Get articles by location
final localNews = await db.getArticlesByLocation('New York');
```

### Get Single Article

```dart
final article = await db.getArticle('article123');
```

### Delete Old Articles (Cleanup)

```dart
// Delete articles older than 7 days
await db.deleteOldArticles(daysOld: 7);
```

---

## Popular Searches Operations

### Get Popular Searches by Region

```dart
final popularInNY = await db.getPopularSearchesByRegion('New York', limit: 10);

for (var search in popularInNY) {
  print('${search['query']}: ${search['count']} searches');
}
```

### Get Global Popular Searches

```dart
final globalPopular = await db.getGlobalPopularSearches(limit: 10);

for (var search in globalPopular) {
  print('${search['query']}: ${search['total_count']} total searches');
}
```

> **Note**: Popular searches are automatically tracked when you call `insertSearchQuery()`.

---

## User Preferences Operations

### Save Preference

```dart
await db.setPreference('user123', 'theme', 'dark');
await db.setPreference('user123', 'notifications_enabled', 'true');
await db.setPreference('user123', 'default_region', 'North America');
```

### Get Preference

```dart
final theme = await db.getPreference('user123', 'theme');
print('User theme: $theme'); // "dark"
```

### Get All Preferences

```dart
final prefs = await db.getAllPreferences('user123');

prefs.forEach((key, value) {
  print('$key: $value');
});
```

### Delete Preference

```dart
await db.deletePreference('user123', 'notifications_enabled');
```

---

## News Source Operations

### Get News Source

```dart
final source = await db.getNewsSource('cnn');
if (source != null) {
  print('Credibility: ${source.credibilityRating}');
}
```

### Get All Sources

```dart
final sources = await db.getAllNewsSources();
```

---

## Database Maintenance

### Clear All Data

```dart
// WARNING: This deletes ALL data from the database
await db.clearAllData();
```

### Close Database

```dart
// Call when app is closing
await db.closeDatabase();
```

---

## Best Practices

### 1. Data Persistence

All operations automatically persist data. **No manual save required.**

```dart
// ✅ Good
await db.insertUser(user);
// Data is persisted immediately

// ❌ Not needed
await db.insertUser(user);
await db.saveChanges(); // No such method exists
```

### 2. Error Handling

Always wrap database operations in try-catch:

```dart
try {
  await db.insertArticle(article);
} catch (e) {
  print('Failed to save article: $e');
}
```

### 3. Cleanup Old Data

Schedule periodic cleanup to avoid database bloat:

```dart
// Run every week
await db.deleteOldArticles(daysOld: 7);
```

### 4. Batch Operations

For multiple items, use batch methods when available:

```dart
// ✅ Efficient
await db.insertArticles(articleList);

// ❌ Less efficient
for (var article in articleList) {
  await db.insertArticle(article);
}
```

---

## Integration with Providers

### Example Provider

```dart
import 'package:provider/provider.dart';
import 'package:factual/services/database_service.dart';

class ArticleProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<NewsArticle> _articles = [];

  List<NewsArticle> get articles => _articles;

  Future<void> loadArticles() async {
    _articles = await _db.getArticles(limit: 50);
    notifyListeners();
  }

  Future<void> saveArticle(NewsArticle article) async {
    await _db.insertArticle(article);
    await loadArticles();
  }
}
```

---

## Performance Tips

1. **Use Indexes**: The database automatically creates indexes for common queries
2. **Limit Results**: Always use `limit` parameter for large queries
3. **Cleanup Schedule**: Delete old data regularly
4. **Foreign Keys**: Enabled for data integrity (cascading deletes)

---

## Data Flow Example

```dart
// 1. User searches for news
final query = SearchQuery(
  id: uuid.v4(),
  userId: currentUserId,
  query: searchText,
  timestamp: DateTime.now(),
  location: userLocation,
);
await db.insertSearchQuery(query);

// 2. Fetch articles from API
final articles = await newsApi.fetchArticles(searchText);

// 3. Cache articles locally
await db.insertArticles(articles);

// 4. Load from cache for offline access
final cachedArticles = await db.getArticles(limit: 50);

// 5. Track popular searches
final trending = await db.getPopularSearchesByRegion(userLocation);
```

---

## Troubleshooting

### Database Locked Error

```dart
// Ensure you're not calling closeDatabase() while operations are pending
await db.insertArticle(article);
await db.closeDatabase(); // ✅ OK

// Don't do this:
db.insertArticle(article); // No await
db.closeDatabase(); // ❌ May cause lock
```

### Missing Data

```dart
// Always ensure sources exist before inserting articles
await db.insertNewsSource(article.source);
await db.insertArticle(article);
```

---

**The DatabaseService handles all data persistence automatically. All changes are saved to disk immediately!** ✅
