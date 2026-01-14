class NewsSource {
  final String id;
  final String name;
  final String url;
  final String country;
  final String language;
  final String category; // e.g., 'general', 'business', 'technology', 'politics'
  final double credibilityScore; // 0.0 to 1.0
  final String? description;
  final String? logoUrl;
  final DateTime? lastUpdated;

  NewsSource({
    required this.id,
    required this.name,
    required this.url,
    required this.country,
    required this.language,
    this.category = 'general',
    this.credibilityScore = 0.5,
    this.description,
    this.logoUrl,
    this.lastUpdated,
  });

  // Create NewsSource from JSON
  factory NewsSource.fromJson(Map<String, dynamic> json) {
    return NewsSource(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      country: json['country'] ?? '',
      language: json['language'] ?? 'en',
      category: json['category'] ?? 'general',
      credibilityScore: (json['credibilityScore'] ?? 0.5).toDouble(),
      description: json['description'],
      logoUrl: json['logoUrl'],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  // Convert NewsSource to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'country': country,
      'language': language,
      'category': category,
      'credibilityScore': credibilityScore,
      'description': description,
      'logoUrl': logoUrl,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  NewsSource copyWith({
    String? id,
    String? name,
    String? url,
    String? country,
    String? language,
    String? category,
    double? credibilityScore,
    String? description,
    String? logoUrl,
    DateTime? lastUpdated,
  }) {
    return NewsSource(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      country: country ?? this.country,
      language: language ?? this.language,
      category: category ?? this.category,
      credibilityScore: credibilityScore ?? this.credibilityScore,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Credibility rating (human-readable)
  String get credibilityRating {
    if (credibilityScore >= 0.8) return 'Very High';
    if (credibilityScore >= 0.6) return 'High';
    if (credibilityScore >= 0.4) return 'Medium';
    if (credibilityScore >= 0.2) return 'Low';
    return 'Very Low';
  }
}
