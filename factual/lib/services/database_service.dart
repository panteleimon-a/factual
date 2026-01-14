import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/search_query.dart';
import '../models/news_article.dart';
import '../models/news_source.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'factual.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        searchHistory TEXT,
        location TEXT,
        preferences TEXT,
        createdAt TEXT NOT NULL,
        lastActive TEXT NOT NULL
      )
    ''');

    // Search queries table
    await db.execute('''
      CREATE TABLE search_queries(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        query TEXT NOT NULL,
        sentiment TEXT,
        timestamp TEXT NOT NULL,
        location TEXT,
        relatedArticleIds TEXT,
        metadata TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // News sources table
    await db.execute('''
      CREATE TABLE news_sources(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        url TEXT NOT NULL,
        country TEXT NOT NULL,
        language TEXT NOT NULL,
        category TEXT,
        credibilityScore REAL,
        description TEXT,
        logoUrl TEXT,
        lastUpdated TEXT
      )
    ''');

    // News articles table
    await db.execute('''
      CREATE TABLE news_articles(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        summary TEXT,
        content TEXT,
        sourceId TEXT NOT NULL,
        url TEXT NOT NULL,
        imageUrl TEXT,
        publishedAt TEXT NOT NULL,
        sentiment TEXT,
        sentimentScore REAL,
        topics TEXT,
        location TEXT,
        latitude REAL,
        longitude REAL,
        relatedArticleIds TEXT,
        isVerified INTEGER,
        lastUpdated TEXT,
        FOREIGN KEY (sourceId) REFERENCES news_sources (id)
      )
    ''');

    // Popular searches table (by region)
    await db.execute('''
      CREATE TABLE popular_searches(
        id TEXT PRIMARY KEY,
        query TEXT NOT NULL,
        region TEXT NOT NULL,
        count INTEGER DEFAULT 1,
        lastSearched TEXT NOT NULL
      )
    ''');

    // User preferences table
    await db.execute('''
      CREATE TABLE user_preferences(
        userId TEXT PRIMARY KEY,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // User interactions table for personalization
    await db.execute('''
      CREATE TABLE user_interactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        articleId TEXT NOT NULL,
        topics TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Location history table
    await db.execute('''
      CREATE TABLE location_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        countryCode TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for faster queries
    await db.execute('CREATE INDEX idx_search_userId ON search_queries(userId)');
    await db.execute('CREATE INDEX idx_search_timestamp ON search_queries(timestamp)');
    await db.execute('CREATE INDEX idx_article_publishedAt ON news_articles(publishedAt)');
    await db.execute('CREATE INDEX idx_popular_region ON popular_searches(region)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here if needed
  }

  // ==================== USER OPERATIONS ====================

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(
      'users',
      _userToMap(user),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;
    return _userFromMap(maps.first);
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      _userToMap(user),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String userId) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ==================== SEARCH QUERY OPERATIONS ====================

  Future<int> insertSearchQuery(SearchQuery query) async {
    final db = await database;
    
    // Update popular searches
    await _updatePopularSearch(query.query, query.location ?? 'global');
    
    return await db.insert(
      'search_queries',
      _searchQueryToMap(query),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SearchQuery>> getUserSearchHistory(String userId, {int limit = 50}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'search_queries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return maps.map((map) => _searchQueryFromMap(map)).toList();
  }

  Future<List<SearchQuery>> getRecentSearches({int limit = 10}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'search_queries',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return maps.map((map) => _searchQueryFromMap(map)).toList();
  }
  
  Future<int> getSearchCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM search_queries WHERE userId = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> deleteSearchQuery(String queryId) async {
    final db = await database;
    return await db.delete(
      'search_queries',
      where: 'id = ?',
      whereArgs: [queryId],
    );
  }

  Future<int> clearUserSearchHistory(String userId) async {
    final db = await database;
    return await db.delete(
      'search_queries',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // ==================== NEWS ARTICLE OPERATIONS ====================

  Future<int> insertArticle(NewsArticle article) async {
    final db = await database;
    
    // First ensure the source exists
    await insertNewsSource(article.source);
    
    return await db.insert(
      'news_articles',
      _articleToMap(article),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertArticles(List<NewsArticle> articles) async {
    int count = 0;
    
    for (var article in articles) {
      await insertArticle(article);
      count++;
    }
    
    return count;
  }

  Future<NewsArticle?> getArticle(String articleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'news_articles',
      where: 'id = ?',
      whereArgs: [articleId],
    );

    if (maps.isEmpty) return null;
    
    final articleMap = maps.first;
    final source = await getNewsSource(articleMap['sourceId']);
    if (source == null) return null;
    
    return _articleFromMap(articleMap, source);
  }

  Future<List<NewsArticle>> getArticles({int limit = 50, String? topic}) async {
    final db = await database;
    
    String? where;
    List<dynamic>? whereArgs;
    
    if (topic != null) {
      where = 'topics LIKE ?';
      whereArgs = ['%$topic%'];
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'news_articles',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'publishedAt DESC',
      limit: limit,
    );

    List<NewsArticle> articles = [];
    for (var map in maps) {
      final source = await getNewsSource(map['sourceId']);
      if (source != null) {
        articles.add(_articleFromMap(map, source));
      }
    }
    
    return articles;
  }

  Future<List<NewsArticle>> getArticlesByLocation(String location, {int limit = 50}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'news_articles',
      where: 'location = ?',
      whereArgs: [location],
      orderBy: 'publishedAt DESC',
      limit: limit,
    );

    List<NewsArticle> articles = [];
    for (var map in maps) {
      final source = await getNewsSource(map['sourceId']);
      if (source != null) {
        articles.add(_articleFromMap(map, source));
      }
    }
    
    return articles;
  }

  Future<int> deleteArticle(String articleId) async {
    final db = await database;
    return await db.delete(
      'news_articles',
      where: 'id = ?',
      whereArgs: [articleId],
    );
  }

  Future<int> deleteOldArticles({int daysOld = 7}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    
    return await db.delete(
      'news_articles',
      where: 'publishedAt < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  // ==================== NEWS SOURCE OPERATIONS ====================

  Future<int> insertNewsSource(NewsSource source) async {
    final db = await database;
    return await db.insert(
      'news_sources',
      _newsSourceToMap(source),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<NewsSource?> getNewsSource(String sourceId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'news_sources',
      where: 'id = ?',
      whereArgs: [sourceId],
    );

    if (maps.isEmpty) return null;
    return _newsSourceFromMap(maps.first);
  }

  Future<List<NewsSource>> getAllNewsSources() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('news_sources');
    return maps.map((map) => _newsSourceFromMap(map)).toList();
  }

  // ==================== POPULAR SEARCHES OPERATIONS ====================

  Future<void> _updatePopularSearch(String query, String region) async {
    final db = await database;
    
    // Check if this query already exists for this region
    final existing = await db.query(
      'popular_searches',
      where: 'query = ? AND region = ?',
      whereArgs: [query, region],
    );

    if (existing.isNotEmpty) {
      // Increment count
      await db.update(
        'popular_searches',
        {
          'count': (existing.first['count'] as int) + 1,
          'lastSearched': DateTime.now().toIso8601String(),
        },
        where: 'query = ? AND region = ?',
        whereArgs: [query, region],
      );
    } else {
      // Insert new popular search
      await db.insert('popular_searches', {
        'id': '${query}_$region',
        'query': query,
        'region': region,
        'count': 1,
        'lastSearched': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<List<Map<String, dynamic>>> getPopularSearchesByRegion(String region, {int limit = 10}) async {
    final db = await database;
    return await db.query(
      'popular_searches',
      where: 'region = ?',
      whereArgs: [region],
      orderBy: 'count DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getGlobalPopularSearches({int limit = 10}) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT query, SUM(count) as total_count
      FROM popular_searches
      GROUP BY query
      ORDER BY total_count DESC
      LIMIT ?
    ''', [limit]);
  }

  // ==================== USER PREFERENCES OPERATIONS ====================

  Future<int> setPreference(String userId, String key, String value) async {
    final db = await database;
    return await db.insert(
      'user_preferences',
      {'userId': userId, 'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getPreference(String userId, String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_preferences',
      where: 'userId = ? AND key = ?',
      whereArgs: [userId, key],
    );

    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  Future<Map<String, String>> getAllPreferences(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_preferences',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return {for (var item in maps) item['key'] as String: item['value'] as String};
  }

  Future<int> deletePreference(String userId, String key) async {
    final db = await database;
    return await db.delete(
      'user_preferences',
      where: 'userId = ? AND key = ?',
      whereArgs: [userId, key],
    );
  }

  // ==================== PERSONALIZATION OPERATIONS ====================

  Future<void> logArticleView(String userId, String articleId, List<String> topics) async {
    final db = await database;
    await db.insert('user_interactions', {
      'userId': userId,
      'articleId': articleId,
      'topics': topics.join(','),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  Future<int> getInteractionCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM user_interactions WHERE userId = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<String>> getTopInterestedTopics(String userId, {int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT topics, COUNT(*) as count
      FROM user_interactions
      WHERE userId = ?
      GROUP BY topics
      ORDER BY count DESC
      LIMIT ?
    ''', [userId, limit]);

    List<String> allTopics = [];
    for (var row in results) {
      final topicsStr = row['topics'] as String?;
      if (topicsStr != null && topicsStr.isNotEmpty) {
        allTopics.addAll(topicsStr.split(',').map((t) => t.trim()));
      }
    }
    
    // De-duplicate and return top N
    return allTopics.toSet().take(limit).toList();
  }

  Future<void> logLocationUpdate(String userId, double lat, double lng, String? country) async {
    final db = await database;
    await db.insert('location_history', {
      'userId': userId,
      'latitude': lat,
      'longitude': lng,
      'countryCode': country,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ==================== HELPER METHODS ====================

  Map<String, dynamic> _userToMap(User user) {
    return {
      'id': user.id,
      'username': user.username,
      'email': user.email,
      'searchHistory': user.searchHistory.join(','),
      'location': user.location,
      'preferences': user.preferences.toString(),
      'createdAt': user.createdAt.toIso8601String(),
      'lastActive': user.lastActive.toIso8601String(),
    };
  }

  User _userFromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      searchHistory: map['searchHistory'] != null && (map['searchHistory'] as String).isNotEmpty
          ? (map['searchHistory'] as String).split(',')
          : [],
      location: map['location'],
      preferences: {},
      createdAt: DateTime.parse(map['createdAt']),
      lastActive: DateTime.parse(map['lastActive']),
    );
  }

  Map<String, dynamic> _searchQueryToMap(SearchQuery query) {
    return {
      'id': query.id,
      'userId': query.userId,
      'query': query.query,
      'sentiment': query.sentiment,
      'timestamp': query.timestamp.toIso8601String(),
      'location': query.location,
      'relatedArticleIds': query.relatedArticleIds.join(','),
      'metadata': query.metadata.toString(),
    };
  }

  SearchQuery _searchQueryFromMap(Map<String, dynamic> map) {
    return SearchQuery(
      id: map['id'],
      userId: map['userId'],
      query: map['query'],
      sentiment: map['sentiment'] ?? 'neutral',
      timestamp: DateTime.parse(map['timestamp']),
      location: map['location'],
      relatedArticleIds: map['relatedArticleIds'] != null && (map['relatedArticleIds'] as String).isNotEmpty
          ? (map['relatedArticleIds'] as String).split(',')
          : [],
      metadata: {},
    );
  }

  Map<String, dynamic> _newsSourceToMap(NewsSource source) {
    return {
      'id': source.id,
      'name': source.name,
      'url': source.url,
      'country': source.country,
      'language': source.language,
      'category': source.category,
      'credibilityScore': source.credibilityScore,
      'description': source.description,
      'logoUrl': source.logoUrl,
      'lastUpdated': source.lastUpdated?.toIso8601String(),
    };
  }

  NewsSource _newsSourceFromMap(Map<String, dynamic> map) {
    return NewsSource(
      id: map['id'],
      name: map['name'],
      url: map['url'],
      country: map['country'],
      language: map['language'],
      category: map['category'] ?? 'general',
      credibilityScore: map['credibilityScore'] ?? 0.5,
      description: map['description'],
      logoUrl: map['logoUrl'],
      lastUpdated: map['lastUpdated'] != null ? DateTime.parse(map['lastUpdated']) : null,
    );
  }

  Map<String, dynamic> _articleToMap(NewsArticle article) {
    return {
      'id': article.id,
      'title': article.title,
      'summary': article.summary,
      'content': article.content,
      'sourceId': article.source.id,
      'url': article.url,
      'imageUrl': article.imageUrl,
      'publishedAt': article.publishedAt.toIso8601String(),
      'sentiment': article.sentiment,
      'sentimentScore': article.sentimentScore,
      'topics': article.topics.join(','),
      'location': article.location,
      'latitude': article.latitude,
      'longitude': article.longitude,
      'relatedArticleIds': article.relatedArticleIds.join(','),
      'isVerified': article.isVerified ? 1 : 0,
      'lastUpdated': article.lastUpdated?.toIso8601String(),
    };
  }

  NewsArticle _articleFromMap(Map<String, dynamic> map, NewsSource source) {
    return NewsArticle(
      id: map['id'],
      title: map['title'],
      summary: map['summary'] ?? '',
      content: map['content'] ?? '',
      source: source,
      url: map['url'],
      imageUrl: map['imageUrl'],
      publishedAt: DateTime.parse(map['publishedAt']),
      sentiment: map['sentiment'] ?? 'neutral',
      sentimentScore: map['sentimentScore'] ?? 0.0,
      topics: map['topics'] != null && (map['topics'] as String).isNotEmpty
          ? (map['topics'] as String).split(',')
          : [],
      location: map['location'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      relatedArticleIds: map['relatedArticleIds'] != null && (map['relatedArticleIds'] as String).isNotEmpty
          ? (map['relatedArticleIds'] as String).split(',')
          : [],
      isVerified: map['isVerified'] == 1,
      lastUpdated: map['lastUpdated'] != null ? DateTime.parse(map['lastUpdated']) : null,
    );
  }

  // ==================== DATABASE MAINTENANCE ====================

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('search_queries');
    await db.delete('news_articles');
    await db.delete('news_sources');
    await db.delete('popular_searches');
    await db.delete('user_preferences');
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
