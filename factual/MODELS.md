# Factual App - Data Models Documentation

## Overview

All data models include:
- ✅ Complete JSON serialization (`toJson()` / `fromJson()`)
- ✅ `copyWith()` method for immutable updates
- ✅ Helper methods and computed properties
- ✅ Type-safe field definitions

---

## 1. User Model

**File**: `lib/models/user.dart`

### Purpose
Represents a user with search history tracking and personalization preferences.

### Key Fields
- `id` - Unique user identifier
- `username` - Display name
- `email` - User email
- `searchHistory` - List of search query IDs
- `location` - Current user location
- `preferences` - Key-value personalization settings
- `createdAt` / `lastActive` - Timestamps

### Usage Example
```dart
import 'package:factual/models/user.dart';

// Create new user
final user = User(
  id: 'user123',
  username: 'john_doe',
  email: 'john@example.com',
  createdAt: DateTime.now(),
  lastActive: DateTime.now(),
);

// Add search to history
final updatedUser = user.addSearchToHistory('query456');

// Serialize to JSON
final json = user.toJson();

// Deserialize from JSON
final userFromDb = User.fromJson(json);
```

---

## 2. SearchQuery Model

**File**: `lib/models/search_query.dart`

### Purpose
Tracks user searches with sentiment analysis and geographic context.

### Key Fields
- `id` - Unique query identifier
- `userId` - User who performed search
- `query` - Search text
- `sentiment` - Emotional tone ('positive', 'negative', 'neutral')
- `timestamp` - When search was performed
- `location` - Geographic context
- `relatedArticleIds` - Articles found for this search
- `metadata` - Additional context data

### Usage Example
```dart
import 'package:factual/models/search_query.dart';

// Create search query
final query = SearchQuery(
  id: 'query123',
  userId: 'user456',
  query: 'political scandal',
  sentiment: 'negative',
  timestamp: DateTime.now(),
  location: 'Washington DC',
);

// Add related article
final updated = query.addRelatedArticle('article789');
```

---

## 3. NewsSource Model

**File**: `lib/models/news_source.dart`

### Purpose
Represents a news outlet with credibility scoring.

### Key Fields
- `id` - Unique source identifier
- `name` - Source name (e.g., "CNN", "BBC")
- `url` - Source homepage
- `country` - Country of origin
- `language` - Primary language
- `category` - News category
- `credibilityScore` - 0.0 to 1.0 reliability score
- `description` - About the source
- `logoUrl` - Source logo image

### Computed Properties
- `credibilityRating` - Human-readable rating ("Very High", "High", etc.)

### Usage Example
```dart
import 'package:factual/models/news_source.dart';

final source = NewsSource(
  id: 'cnn',
  name: 'CNN',
  url: 'https://cnn.com',
  country: 'United States',
  language: 'en',
  credibilityScore: 0.75,
);

print(source.credibilityRating); // "High"
```

---

## 4. NewsArticle Model

**File**: `lib/models/news_article.dart`

### Purpose
Represents a news article with complete metadata, sentiment, and verification status.

### Key Fields
- `id` - Unique article identifier
- `title` - Article headline
- `summary` - Brief description
- `content` - Full article text
- `source` - NewsSource object
- `url` - Article URL
- `imageUrl` - Featured image
- `publishedAt` - Publication date
- `sentiment` / `sentimentScore` - Emotional analysis
- `topics` - Category tags
- `location` / `latitude` / `longitude` - Geographic relevance
- `relatedArticleIds` - Similar/duplicate articles
- `isVerified` - Fact-checked status

### Computed Properties
- `timeAgo` - Human-readable time ("2 hours ago")
- `sentimentEmoji` - Visual sentiment indicator

### Usage Example
```dart
import 'package:factual/models/news_article.dart';
import 'package:factual/models/news_source.dart';

final article = NewsArticle(
  id: 'article123',
  title: 'Breaking News Story',
  summary: 'Summary of the story...',
  source: NewsSource(/* ... */),
  url: 'https://example.com/article',
  publishedAt: DateTime.now().subtract(Duration(hours: 2)),
  sentiment: 'neutral',
  topics: ['politics', 'economy'],
  isVerified: true,
);

print(article.timeAgo); // "2 hours ago"
print(article.sentimentEmoji); // "😐"
```

---

## 5. LocationRegion Model

**File**: `lib/models/location_region.dart`

### Purpose
Represents geographic locations with distance calculations.

### Key Fields
- `id` - Unique location identifier
- `name` - Location name (e.g., "Paris")
- `country` - Country name
- `countryCode` - ISO code
- `latitude` / `longitude` - GPS coordinates
- `type` - Location type ('city', 'region', 'country')
- `population` - Population count
- `languages` - Spoken languages
- `timezone` - Time zone

### Computed Properties
- `displayName` - "Paris, France"
- `coordinates` - Formatted GPS string

### Methods
- `distanceTo(other)` - Calculate km distance using Haversine formula

### Usage Example
```dart
import 'package:factual/models/location_region.dart';

final paris = LocationRegion(
  id: 'paris-fr',
  name: 'Paris',
  country: 'France',
  countryCode: 'FR',
  latitude: 48.8566,
  longitude: 2.3522,
  type: 'city',
  population: 2200000,
);

final london = LocationRegion(
  id: 'london-uk',
  name: 'London',
  country: 'United Kingdom',
  countryCode: 'GB',
  latitude: 51.5074,
  longitude: -0.1278,
  type: 'city',
);

final distance = paris.distanceTo(london);
print('Distance: ${distance.toStringAsFixed(0)} km'); // ~344 km
```

---

## Database Integration

### SQLite Example
```dart
// Save to database
final db = await DatabaseService().database;
await db.insert('articles', article.toJson());

// Load from database
final maps = await db.query('articles', where: 'id = ?', whereArgs: [articleId]);
final article = NewsArticle.fromJson(maps.first);
```

### Hive Example
```dart
// Store in Hive box
final box = await Hive.openBox<Map>('articles');
await box.put(article.id, article.toJson());

// Retrieve from Hive
final json = box.get(articleId);
final article = NewsArticle.fromJson(json!);
```

---

## Model Relationships

```
User
  └─ searchHistory: List<SearchQuery.id>

SearchQuery
  ├─ userId: User.id
  └─ relatedArticleIds: List<NewsArticle.id>

NewsArticle
  ├─ source: NewsSource
  ├─ location: LocationRegion (optional)
  └─ relatedArticleIds: List<NewsArticle.id>

NewsSource
  └─ Used by: NewsArticle

LocationRegion
  └─ Used by: NewsArticle, SearchQuery, User
```

---

## Next Steps

1. Implement database repositories using these models
2. Create Provider state notifiers for each model
3. Build UI screens that consume these models
4. Implement API services to populate models from news sources
5. Add validation logic for model fields

---

**All models are production-ready and follow Flutter best practices!** ✅
