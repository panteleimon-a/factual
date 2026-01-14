import 'package:flutter/material.dart';
import '../models/location_data.dart';
import '../services/location_service.dart';
import '../services/database_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  LocationData? _currentLocation;
  double? _selectedRadius;
  bool _isLoading = false;
  String? _error;

  LocationData? get currentLocation => _currentLocation;
  double? get selectedRadius => _selectedRadius;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final position = await _locationService.determinePosition();
      final countryCode = await _locationService.getCountryCode(
        position.latitude, 
        position.longitude,
      );

      _currentLocation = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        countryCode: countryCode,
        timestamp: DateTime.now(),
      );
      
      // Log location to local database
      await DatabaseService().logLocationUpdate(
        'default_user', // Using mock ID for now
        position.latitude,
        position.longitude,
        countryCode,
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentLocation = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectRegion(double latitude, double longitude, double radius) {
    _currentLocation = LocationData(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
    );
    _selectedRadius = radius;
    notifyListeners();
  }

  void clearSelection() {
    _selectedRadius = null;
    notifyListeners();
  }
}
