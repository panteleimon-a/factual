import 'dart:math';

class LocationRegion {

  final String id;
  final String name;
  final String country;
  final String countryCode; // ISO 3166-1 alpha-2
  final double latitude;
  final double longitude;
  final String type; // 'city', 'region', 'country', 'continent'
  final int? population;
  final List<String> languages;
  final String? timezone;
  final Map<String, dynamic> metadata; // Additional location data

  LocationRegion({
    required this.id,
    required this.name,
    required this.country,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    this.type = 'city',
    this.population,
    this.languages = const [],
    this.timezone,
    this.metadata = const {},
  });

  // Create LocationRegion from JSON
  factory LocationRegion.fromJson(Map<String, dynamic> json) {
    return LocationRegion(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      countryCode: json['countryCode'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      type: json['type'] ?? 'city',
      population: json['population'],
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : [],
      timezone: json['timezone'],
      metadata: json['metadata'] ?? {},
    );
  }

  // Convert LocationRegion to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'countryCode': countryCode,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'population': population,
      'languages': languages,
      'timezone': timezone,
      'metadata': metadata,
    };
  }

  // Create a copy with modified fields
  LocationRegion copyWith({
    String? id,
    String? name,
    String? country,
    String? countryCode,
    double? latitude,
    double? longitude,
    String? type,
    int? population,
    List<String>? languages,
    String? timezone,
    Map<String, dynamic>? metadata,
  }) {
    return LocationRegion(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      population: population ?? this.population,
      languages: languages ?? this.languages,
      timezone: timezone ?? this.timezone,
      metadata: metadata ?? this.metadata,
    );
  }

  // Display name with country
  String get displayName => '$name, $country';

  // Formatted coordinates
  String get coordinates =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  // Calculate distance to another location (Haversine formula)
  double distanceTo(LocationRegion other) {
    const earthRadius = 6371; // km
    final dLat = _toRadians(other.latitude - latitude);
    final dLon = _toRadians(other.longitude - longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(latitude)) *
            cos(_toRadians(other.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * (pi / 180);
}

