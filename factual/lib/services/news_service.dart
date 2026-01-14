import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';
import '../models/news_source.dart';
import '../services/database_service.dart';
import '../services/llm_service.dart';
import 'package:uuid/uuid.dart';

/// Service for fetching news from multiple APIs
class NewsService {
  final DatabaseService _db = DatabaseService();
  final LLMService _llm = LLMService();
  final Uuid _uuid = const Uuid();

  // Free API keys (replace with actual keys)
  static const String _newsApiKey = 'YOUR_NEWSAPI_KEY_HERE'; // newsapi.org (free tier: 100 req/day)
  static const String _newsDataApiKey = 'YOUR_NEWSDATA_KEY_HERE'; // newsdata.io (free tier: 200 req/day)

  // API endpoints
  static const String _newsApiUrl = 'https://newsapi.org/v2';
  static const String _newsDataUrl = 'https://newsdata.io/api/1';

  /// Fetch news from all sources
  Future<List<NewsArticle>> fetchNews({
    String? query,
    String? category,
    String? country,
    int limit = 50,
  }) async {
    List<NewsArticle> allArticles = [];

    try {
      // Fetch from NewsAPI
      final newsApiArticles = await _fetchFromNewsAPI(
        query: query,
        category: category,
        country: country,
      );
      allArticles.addAll(newsApiArticles);

      // Fetch from NewsData.io
      final newsDataArticles = await _fetchFromNewsData(
        query: query,
        category: category,
        country: country,
      );
      allArticles.addAll(newsDataArticles);

      // Remove duplicates
      final uniqueArticles = await _removeDuplicates(allArticles);

      // Tag with sentiment
      final taggedArticles = await _tagSentiment(uniqueArticles);

      // Cache to database
      await _cacheArticles(taggedArticles);

      return taggedArticles.take(limit).toList();
    } catch (e) {
      print('Error fetching news: $e');
      // Return cached articles as fallback
      return await _db.getArticles(limit: limit);
    }
  }

  /// Fetch from NewsAPI.org
  Future<List<NewsArticle>> _fetchFromNewsAPI({
    String? query,
    String? category,
    String? country,
  }) async {
    try {
      String endpoint = query != null ? '/everything' : '/top-headlines';
      
      final params = <String, String>{
        'apiKey': _newsApiKey,
        if (query != null) 'q': query,
        if (category != null && query == null) 'category': category,
        if (country != null && query == null) 'country': country ?? 'us',
        'pageSize': '50',
      };

      final uri = Uri.parse('$_newsApiUrl$endpoint').replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List)
            .map((article) => _normalizeNewsApiArticle(article))
            .where((article) => article != null)
            .cast<NewsArticle>()
            .toList();
        return articles;
      }
    } catch (e) {
      print('NewsAPI error: $e');
    }
    return [];
  }

  /// Fetch from NewsData.io
  Future<List<NewsArticle>> _fetchFromNewsData({
    String? query,
    String? category,
    String? country,
  }) async {
    try {
      final params = <String, String>{
        'apikey': _newsDataApiKey,
        if (query != null) 'q': query,
        if (category != null) 'category': category,
        if (country != null) 'country': country ?? 'us',
        'language': 'en',
      };

      final uri = Uri.parse('$_newsDataUrl/news').replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['results'] as List)
            .map((article) => _normalizeNewsDataArticle(article))
            .where((article) => article != null)
            .cast<NewsArticle>()
            .toList();
        return articles;
      }
    } catch (e) {
      print('NewsData error: $e');
    }
    return [];
  }

  /// Normalize NewsAPI article
  NewsArticle? _normalizeNewsApiArticle(Map<String, dynamic> article) {
    try {
      return NewsArticle(
        id: _uuid.v4(),
        title: article['title'] ?? 'No title',
        summary: article['description'] ?? '',
        content: article['content'] ?? '',
        source: NewsSource(
          id: _uuid.v4(),
          name: article['source']['name'] ?? 'Unknown',
          url: article['url'] ?? '',
          country: '',
          language: 'en',
          category: '',
          credibilityScore: 0.7,
        ),
        url: article['url'] ?? '',
        imageUrl: article['urlToImage'],
        publishedAt: DateTime.parse(article['publishedAt'] ?? DateTime.now().toIso8601String()),
        sentiment: 'neutral',
        sentimentScore: 0.0,
      );
    } catch (e) {
      print('Error normalizing NewsAPI article: $e');
      return null;
    }
  }

  /// Normalize NewsData article
  NewsArticle? _normalizeNewsDataArticle(Map<String, dynamic> article) {
    try {
      return NewsArticle(
        id: _uuid.v4(),
        title: article['title'] ?? 'No title',
        summary: article['description'] ?? '',
        content: article['content'] ?? '',
        source: NewsSource(
          id: _uuid.v4(),
          name: article['source_id'] ?? 'Unknown',
          url: article['link'] ?? '',
          country: article['country']?.first ?? '',
          language: article['language'] ?? 'en',
          category: article['category']?.first ?? '',
          credibilityScore: 0.7,
        ),
        url: article['link'] ?? '',
        imageUrl: article['image_url'],
        publishedAt: DateTime.parse(article['pubDate'] ?? DateTime.now().toIso8601String()),
        sentiment: 'neutral',
        sentimentScore: 0.0,
        latitude: article['latitude'],
        longitude: article['longitude'],
      );
    } catch (e) {
      print('Error normalizing NewsData article: $e');
      return null;
    }
  }

  /// Remove duplicate articles using LLM
  Future<List<NewsArticle>> _removeDuplicates(List<NewsArticle> articles) async {
    if (articles.length <= 1) return articles;

    final unique = <NewsArticle>[];
    unique.add(articles.first);

    for (int i = 1; i < articles.length; i++) {
      bool isDuplicate = false;

      for (final existing in unique) {
        try {
          final result = await _llm.detectDuplicate(articles[i], existing);
          
          if (result['isDuplicate'] == true || 
              ((result['similarityScore'] as num?) ?? 0.0) > 0.8) {
            isDuplicate = true;
            break;
          }
        } catch (e) {
          // Fallback to simple title comparison
          if (_simpleDuplicateCheck(articles[i], existing)) {
            isDuplicate = true;
            break;
          }
        }
      }

      if (!isDuplicate) {
        unique.add(articles[i]);
      }
    }

    return unique;
  }

  /// Simple duplicate check (fallback)
  bool _simpleDuplicateCheck(NewsArticle a1, NewsArticle a2) {
    // Check if titles are very similar
    final title1 = a1.title.toLowerCase();
    final title2 = a2.title.toLowerCase();
    
    // Exact match
    if (title1 == title2) return true;
    
    // High similarity (simple word overlap)
    final words1 = title1.split(' ').toSet();
    final words2 = title2.split(' ').toSet();
    final intersection = words1.intersection(words2);
    final union = words1.union(words2);
    
    final similarity = intersection.length / union.length;
    return similarity > 0.7;
  }

  /// Tag articles with sentiment using LLM
  Future<List<NewsArticle>> _tagSentiment(List<NewsArticle> articles) async {
    final tagged = <NewsArticle>[];

    for (final article in articles) {
      try {
        final sentiment = await _llm.analyzeSentiment(article.title);
        
        tagged.add(article.copyWith(
          sentiment: sentiment['sentiment'] ?? 'neutral',
          sentimentScore: (sentiment['score'] ?? 0.0).toDouble(),
        ));
      } catch (e) {
        // Keep original article if sentiment analysis fails
        tagged.add(article);
      }
    }

    return tagged;
  }

  /// Cache articles to database
  Future<void> _cacheArticles(List<NewsArticle> articles) async {
    try {
      await _db.insertArticles(articles);
    } catch (e) {
      print('Error caching articles: $e');
    }
  }

  /// Search news with caching
  Future<List<NewsArticle>> searchNews(String query, {String? location, String? country, String? category}) async {
    // Try to fetch fresh results
    final freshArticles = await fetchNews(query: query, country: country, category: category);
    
    if (freshArticles.isNotEmpty) {
      return freshArticles;
    }

    // Fallback to cached results
    final allCached = await _db.getArticles(limit: 100);
    return allCached.where((a) => 
      a.title.toLowerCase().contains(query.toLowerCase()) ||
      a.summary.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Get top headlines by category
  Future<List<NewsArticle>> getTopHeadlines({
    String category = 'general',
    String country = 'us',
  }) async {
    return await fetchNews(category: category, country: country);
  }

  /// Get cached articles (offline mode)
  Future<List<NewsArticle>> getCachedArticles({
    int limit = 50,
    String? topic,
  }) async {
    if (topic != null) {
      final all = await _db.getArticles(limit: limit * 2);
      return all.where((a) => a.topics.contains(topic)).take(limit).toList();
    }
    return await _db.getArticles(limit: limit);
  }

  /// Refresh cache
  Future<void> refreshCache() async {
    final articles = await fetchNews(limit: 100);
    await _cacheArticles(articles);
  }
}

/// Exception for news service errors
class NewsServiceException implements Exception {
  final String message;
  NewsServiceException(this.message);

  @override
  String toString() => 'NewsServiceException: $message';
}
