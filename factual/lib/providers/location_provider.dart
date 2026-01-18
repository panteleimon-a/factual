import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
    print('LocationProvider: Starting getCurrentLocation...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('LocationProvider: Calling determinePosition...');
      final position = await _locationService.determinePosition();
      print('LocationProvider: Position received: ${position.latitude}, ${position.longitude}');
      
      // Check if location has changed significantly (> 5km)
      if (_currentLocation != null) {
        double distanceInMeters = Geolocator.distanceBetween(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
          position.latitude,
          position.longitude,
        );
        
        if (distanceInMeters < 5000) {
          print('LocationProvider: Moved ${distanceInMeters.toStringAsFixed(0)}m. Within 5km threshold. Using cached location.');
           _isLoading = false;
          notifyListeners();
          return;
        }
      }

      print('LocationProvider: Location changed or initial load. Fetching country code...');
      final countryCode = await _locationService.getCountryCode(
        position.latitude, 
        position.longitude,
      );
      print('LocationProvider: Country code received: $countryCode');

      _currentLocation = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        countryCode: countryCode,
        country: countryCode, // Using code as placeholder for now, or fetch full name if needed
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
      print('LocationProvider ERROR: $e');
      _error = e.toString();
      // Keep previous location if new fetch fails
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
