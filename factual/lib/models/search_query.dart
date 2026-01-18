class SearchQuery {
  final String id;
  final String userId;
  final String query;
  final String sentiment; // 'positive', 'negative', 'neutral'
  final DateTime timestamp;
  final String? location; // Geographic context of search
  final List<String> relatedArticleIds; // Articles found for this query
  final Map<String, dynamic> metadata; // Additional query context
  final bool isPinned;
  final bool isSynced;
  final String? resultJson; // Cached LLM analysis result

  SearchQuery({
    required this.id,
    required this.userId,
    required this.query,
    this.sentiment = 'neutral',
    required this.timestamp,
    this.location,
    this.relatedArticleIds = const [],
    this.metadata = const {},
    this.isPinned = false,
    this.isSynced = false,
    this.resultJson,
  });

  // Create SearchQuery from JSON
  factory SearchQuery.fromJson(Map<String, dynamic> json) {
    return SearchQuery(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      query: json['query'] ?? '',
      sentiment: json['sentiment'] ?? 'neutral',
      timestamp: DateTime.parse(
          json['timestamp'] ?? DateTime.now().toIso8601String()),
      location: json['location'],
      relatedArticleIds: json['relatedArticleIds'] != null
          ? List<String>.from(json['relatedArticleIds'])
          : [],
      metadata: json['metadata'] ?? {},
      isPinned: json['isPinned'] == 1 || json['isPinned'] == true,
      isSynced: json['isSynced'] == 1 || json['isSynced'] == true,
      resultJson: json['resultJson'],
    );
  }

  // Convert SearchQuery to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'query': query,
      'sentiment': sentiment,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'relatedArticleIds': relatedArticleIds,
      'metadata': metadata,
      'isPinned': isPinned ? 1 : 0,
      'isSynced': isSynced ? 1 : 0,
      'resultJson': resultJson,
    };
  }

  // Create a copy with modified fields
  SearchQuery copyWith({
    String? id,
    String? userId,
    String? query,
    String? sentiment,
    DateTime? timestamp,
    String? location,
    List<String>? relatedArticleIds,
    Map<String, dynamic>? metadata,
    bool? isPinned,
    bool? isSynced,
    String? resultJson,
  }) {
    return SearchQuery(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      query: query ?? this.query,
      sentiment: sentiment ?? this.sentiment,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      relatedArticleIds: relatedArticleIds ?? this.relatedArticleIds,
      metadata: metadata ?? this.metadata,
      isPinned: isPinned ?? this.isPinned,
      isSynced: isSynced ?? this.isSynced,
      resultJson: resultJson ?? this.resultJson,
    );
  }

  // Add article to related articles
  SearchQuery addRelatedArticle(String articleId) {
    final updatedArticles = [...relatedArticleIds, articleId];
    return copyWith(relatedArticleIds: updatedArticles);
  }
}
