import 'news_source.dart';

class NewsArticle {
  final String id;
  final String title;
  final String summary;
  final String content;
  final NewsSource source;
  final String url;
  final String? imageUrl;
  final DateTime publishedAt;
  final String sentiment; // 'positive', 'negative', 'neutral'
  final double sentimentScore; // -1.0 to 1.0
  final List<String> topics; // Tags/categories
  final String? location; // Geographic relevance
  final double? latitude;
  final double? longitude;
  final List<String> relatedArticleIds; // Duplicate/similar articles
  final bool isVerified; // Fact-checked
  final DateTime? lastUpdated;

  NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    this.content = '',
    required this.source,
    required this.url,
    this.imageUrl,
    required this.publishedAt,
    this.sentiment = 'neutral',
    this.sentimentScore = 0.0,
    this.topics = const [],
    this.location,
    this.latitude,
    this.longitude,
    this.relatedArticleIds = const [],
    this.isVerified = false,
    this.lastUpdated,
  });

  // Create NewsArticle from JSON
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      source: NewsSource.fromJson(json['source'] ?? {}),
      url: json['url'] ?? '',
      imageUrl: json['imageUrl'],
      publishedAt: DateTime.parse(
          json['publishedAt'] ?? DateTime.now().toIso8601String()),
      sentiment: json['sentiment'] ?? 'neutral',
      sentimentScore: (json['sentimentScore'] ?? 0.0).toDouble(),
      topics: json['topics'] != null ? List<String>.from(json['topics']) : [],
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      relatedArticleIds: json['relatedArticleIds'] != null
          ? List<String>.from(json['relatedArticleIds'])
          : [],
      isVerified: json['isVerified'] ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  // Convert NewsArticle to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'source': source.toJson(),
      'url': url,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt.toIso8601String(),
      'sentiment': sentiment,
      'sentimentScore': sentimentScore,
      'topics': topics,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'relatedArticleIds': relatedArticleIds,
      'isVerified': isVerified,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  NewsArticle copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    NewsSource? source,
    String? url,
    String? imageUrl,
    DateTime? publishedAt,
    String? sentiment,
    double? sentimentScore,
    List<String>? topics,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? relatedArticleIds,
    bool? isVerified,
    DateTime? lastUpdated,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      source: source ?? this.source,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      sentiment: sentiment ?? this.sentiment,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      topics: topics ?? this.topics,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      relatedArticleIds: relatedArticleIds ?? this.relatedArticleIds,
      isVerified: isVerified ?? this.isVerified,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Time ago formatter
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays >= 730 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays >= 60 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Sentiment emoji
  String get sentimentEmoji {
    if (sentiment == 'positive') return '😊';
    if (sentiment == 'negative') return '😟';
    return '😐';
  }
}

