import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  const LocationResult(this.latitude, this.longitude);
}

/// Thin wrapper around geolocator that safely resolves the device location,
/// requesting permission when needed and returning null on any failure so
/// callers can fall back to a manually selected city.
class LocationService {
  static Future<LocationResult?> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      return LocationResult(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }
}
