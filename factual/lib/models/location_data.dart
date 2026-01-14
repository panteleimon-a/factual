class LocationData {
  final double latitude;
  final double longitude;
  final String? countryCode;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.countryCode,
    required this.timestamp,
  });

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      countryCode: map['countryCode'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'countryCode': countryCode,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
