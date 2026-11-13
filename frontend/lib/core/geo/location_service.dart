import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class BdDivisionBounds {
  final String name;
  final double south;
  final double north;
  final double west;
  final double east;

  const BdDivisionBounds({
    required this.name,
    required this.south,
    required this.north,
    required this.west,
    required this.east,
  });
}

class LocationService {
  LocationService._internal();
  static final LocationService instance = LocationService._internal();

  static const List<BdDivisionBounds> _bdDivisions = [
    BdDivisionBounds(name: 'Dhaka', south: 23.2, north: 24.5, west: 89.8, east: 91.1),
    BdDivisionBounds(name: 'Chattogram', south: 20.7, north: 24.3, west: 91.2, east: 92.7),
    BdDivisionBounds(name: 'Rajshahi', south: 23.8, north: 25.2, west: 88.0, east: 89.8),
    BdDivisionBounds(name: 'Rangpur', south: 25.1, north: 26.6, west: 88.0, east: 89.9),
    BdDivisionBounds(name: 'Khulna', south: 21.6, north: 24.1, west: 88.6, east: 89.9),
    BdDivisionBounds(name: 'Barishal', south: 21.8, north: 23.1, west: 89.8, east: 90.9),
    BdDivisionBounds(name: 'Sylhet', south: 23.9, north: 25.3, west: 91.0, east: 92.6),
    BdDivisionBounds(name: 'Mymensingh', south: 24.3, north: 25.3, west: 89.6, east: 91.0),
  ];

  Future<bool> requestPermission() async {
    try {
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (_) {
      return true;
    }
  }

  Future<Position?> getCurrentPosition({bool highAccuracy = false}) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: highAccuracy ? LocationAccuracy.high : LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 6),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  String? inferDivisionFromPosition(Position position) {
    for (final d in _bdDivisions) {
      if (position.latitude >= d.south &&
          position.latitude <= d.north &&
          position.longitude >= d.west &&
          position.longitude <= d.east) {
        return d.name;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> getLocationWithDivision() async {
    final pos = await getCurrentPosition();
    final division = pos != null ? inferDivisionFromPosition(pos) : null;
    return {'position': pos, 'division': division};
  }

  static Future<double> distanceKm(
      double lat1, double lon1, double lat2, double lon2) async {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000.0;
  }
}
