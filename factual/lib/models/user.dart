class User {
  final String id;
  final String username;
  final String email;
  final List<String> searchHistory; // List of search query IDs
  final String? location; // User's current location
  final Map<String, dynamic> preferences; // User personalization settings
  final DateTime createdAt;
  final DateTime lastActive;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.searchHistory = const [],
    this.location,
    this.preferences = const {},
    required this.createdAt,
    required this.lastActive,
  });

  // Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      searchHistory: json['searchHistory'] != null
          ? List<String>.from(json['searchHistory'])
          : [],
      location: json['location'],
      preferences: json['preferences'] ?? {},
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastActive: DateTime.parse(
          json['lastActive'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'searchHistory': searchHistory,
      'location': location,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  User copyWith({
    String? id,
    String? username,
    String? email,
    List<String>? searchHistory,
    String? location,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      searchHistory: searchHistory ?? this.searchHistory,
      location: location ?? this.location,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  // Add a search to history
  User addSearchToHistory(String searchQueryId) {
    final updatedHistory = [...searchHistory, searchQueryId];
    return copyWith(
      searchHistory: updatedHistory,
      lastActive: DateTime.now(),
    );
  }
}
