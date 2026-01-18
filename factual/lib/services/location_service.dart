import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    print('LocationService: Checking if location services are enabled...');
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('LocationService: Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    print('LocationService: Checking current permission status...');
    permission = await Geolocator.checkPermission();
    print('LocationService: Current permission: $permission');

    if (permission == LocationPermission.denied) {
      print('LocationService: Requesting permission via geolocator...');
      permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied) {
        print('LocationService: Denied. Requesting via permission_handler...');
        final status = await Permission.location.request();
        if (status.isPermanentlyDenied) {
          return Future.error('Location permissions are permanently denied');
        }
        if (!status.isGranted) {
          return Future.error('Location permissions are denied');
        }
        // If granted via permission_handler, re-check geolocator permission
        permission = await Geolocator.checkPermission();
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print('LocationService: Permission permanently denied.');
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    print('LocationService: Getting current position...');
    return await Geolocator.getCurrentPosition();
  }

  Future<String?> getCountryCode(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        return placemarks.first.isoCountryCode;
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return null;
  }
}
