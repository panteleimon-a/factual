class UserSearch {
  final String id;
  final String query;
  final DateTime timestamp;
  final String sentiment;

  UserSearch({
    required this.id,
    required this.query,
    required this.timestamp,
    this.sentiment = 'neutral',
  });
}
