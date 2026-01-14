import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_data.dart';

class LocationProvider with ChangeNotifier {
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
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentLocation = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
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
