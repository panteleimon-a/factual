# NewsService - Multi-Source News Aggregation

## Overview

The NewsService fetches news from multiple free APIs, normalizes formats, removes duplicates, tags sentiment, and caches articles locally for offline access.

## Supported APIs

### 1. NewsAPI.org
- **Free Tier**: 100 requests/day
- **Features**: Top headlines, keyword search, category filtering
- **Sign up**: https://newsapi.org/register
- **Endpoints**: `/top-headlines`, `/everything`

### 2. NewsData.io
- **Free Tier**: 200 requests/day
- **Features**: Real-time news, multi-language, geographic data
- **Sign up**: https://newsdata.io/register
- **Endpoint**: `/news`

---

## Setup

### 1. Get API Keys

**NewsAPI.org:**
```
1. Go to https://newsapi.org/register
2. Create free account
3. Copy API key from dashboard
```

**NewsData.io:**
```
1. Go to https://newsdata.io/register
2. Sign up for free plan
3. Get API key from settings
```

### 2. Add Keys to Service

Edit `lib/services/news_service.dart`:

```dart
static const String _newsApiKey = 'your_newsapi_key_here';
static const String _newsDataApiKey = 'your_newsdata_key_here';
```

**Security Best Practice:**
Use environment variables or `.env` file (with flutter_dotenv):

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

static final String _newsApiKey = dotenv.env['NEWS_API_KEY'] ?? '';
```

---

## Usage

### Basic Fetching

```dart
import 'package:factual/services/news_service.dart';

final newsService = NewsService();

// Fetch latest news
final articles = await newsService.fetchNews(limit: 20);
```

### Search by Query

```dart
final results = await newsService.searchNews('climate change');
```

### Category Headlines

```dart
final techNews = await newsService.getTopHeadlines(
  category: 'technology',
  country: 'us',
);
```

**Available Categories:**
- `business`
- `entertainment`
- `general`
- `health`
- `science`
- `sports`
- `technology`

### Offline Mode

```dart
// Get cached articles
final cached = await newsService.getCachedArticles(limit: 50);

// Get by topic
final techCached = await newsService.getCachedArticles(
  topic: 'technology',
  limit: 20,
);
```

### Refresh Cache

```dart
await newsService.refreshCache();
```

---

## Features

### 1. Multi-Source Aggregation

Combines articles from multiple APIs:

```dart
final articles = await newsService.fetchNews(query: 'politics');
// Returns mixed results from NewsAPI + NewsData
```

### 2. Duplicate Detection

Uses LLM to identify duplicate articles:

```dart
// Automatic during fetchNews()
// Falls back to simple title comparison if LLM fails
```

**Algorithm:**
1. Compare each new article with existing ones
2. Use `LLMService.detectDuplicate()` for semantic similarity
3. Remove articles with similarity > 0.8
4. Fallback to word overlap if LLM unavailable

### 3. Sentiment Tagging

Automatically analyzes sentiment:

```dart
// Each article gets:
// - sentiment: 'positive' | 'negative' | 'neutral'
// - sentimentScore: -1.0 to 1.0
```

### 4. Smart Caching

All fetched articles are cached to SQLite:

```dart
// Cache is automatically updated
// Survives app restarts
// Works offline
```

### 5. Format Normalization

Different API formats → Unified `NewsArticle` model:

```dart
NewsArticle {
  id, title, summary, content,
  source (NewsSource),
  url, imageUrl,
  publishedAt,
  sentiment, sentimentScore,
  latitude, longitude  // from NewsData
}
```

---

## API Rate Limits

### Managing Limits

```dart
// Limit total articles
final articles = await newsService.fetchNews(limit: 30);

// Use cache when possible
if (isOffline) {
  final articles = await newsService.getCachedArticles();
}
```

### Daily Quotas

- **NewsAPI**: 100 requests/day (free)
- **NewsData**: 200 requests/day (free)
- **Total**: ~300 requests/day

**Best Practices:**
1. Cache aggressively
2. Refresh only when needed
3. Implement pull-to-refresh (user-initiated)
4. Don't auto-refresh on app launch

---

## Complete Example - News Feed

```dart
import 'package:flutter/material.dart';
import '../services/news_service.dart';
import '../models/news_article.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({Key? key}) : super(key: key);

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final NewsService _newsService = NewsService();
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final articles = await _newsService.fetchNews(limit: 30);
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load news: $e';
        _isLoading = false;
      });
      
      // Load cached as fallback
      final cached = await _newsService.getCachedArticles();
      setState(() => _articles = cached);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNews,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNews,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            ElevatedButton(
              onPressed: _loadNews,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: article.imageUrl != null
                ? Image.network(
                    article.imageUrl!,
                    width: 80,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.article, size: 80),
            title: Text(article.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.source.name),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getSentimentColor(article.sentiment),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    article.sentiment,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              // Navigate to article details
            },
          ),
        );
      },
    );
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
```

---

## Search Implementation

```dart
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final NewsService _newsService = NewsService();
  final TextEditingController _searchController = TextEditingController();
  List<NewsArticle> _results = [];
  bool _isSearching = false;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    final results = await _newsService.searchNews(query);

    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search news...',
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final article = _results[index];
                return ListTile(
                  title: Text(article.title),
                  subtitle: Text(article.source.name),
                );
              },
            ),
    );
  }
}
```

---

## Error Handling

### Network Errors

```dart
try {
  final articles = await newsService.fetchNews();
} catch (e) {
  if (e is NewsServiceException) {
    print('Service error: ${e.message}');
  }
  
  // Fallback to cache
  final cached = await newsService.getCachedArticles();
}
```

### API Key Missing

```dart
if (_newsApiKey.isEmpty || _newsDataApiKey.isEmpty) {
  throw NewsServiceException('API keys not configured');
}
```

### Rate Limit Exceeded

APIs return HTTP 429 - handle gracefully:

```dart
// Service automatically falls back to cache
// User sees cached articles instead of error
```

---

## Performance Optimization

### 1. Batch Processing

```dart
// Don't fetch one-by-one
// ❌ Bad
for (var category in categories) {
  await newsService.getTopHeadlines(category: category);
}

// ✅ Good
final Future.wait([
  newsService.getTopHeadlines(category: 'tech'),
  newsService.getTopHeadlines(category: 'sports'),
]);
```

### 2. Cache Strategy

```dart
// Check cache first
final cached = await newsService.getCachedArticles();

if (cached.isNotEmpty && !forceRefresh) {
  return cached; // Use cache
}

// Fetch fresh if needed
return await newsService.fetchNews();
```

### 3. Debounce Search

```dart
Timer? _debounce;

void _onSearchChanged(String query) {
  _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () {
    _performSearch(query);
  });
}
```

---

## Troubleshooting

### No Articles Returned

1. Check API keys are set
2. Verify internet connection
3. Check API quota (console logs)
4. Try cached articles

### Duplicate Articles

1. LLM service might be down (fallback active)
2. Increase similarity threshold in `_removeDuplicates()`
3. Different sources reporting same story

### Slow Performance

1. Reduce `limit` parameter
2. Use cached articles when possible
3. Implement pagination
4. Fetch in background

---

## Future Enhancements

1. **More APIs**: Add RSS feeds, Reddit, Twitter
2. **Smart Caching**: Time-based expiration
3. **Offline Queue**: Retry failed requests
4. **Image Caching**: Download article images
5. **Webhooks**: Real-time updates

---

**NewsService is production-ready with free API support!** ✅
