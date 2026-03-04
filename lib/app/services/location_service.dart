import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Service that handles device location and reverse geocoding.
///
/// Wraps the [Geolocator] and [geocoding] packages to provide two high-level operations:
/// - [getCurrentPosition]: checks permissions and returns the device's GPS position.
/// - [getAddressFromPosition]: converts a GPS position to a human-readable address string.
///
/// Throws descriptive [Exception]s for all failure cases (service disabled,
/// permissions denied, geocoding failure) so callers can display appropriate UI messages.
class LocationService {
  /// Checks location service status and permissions, then returns the current GPS position.
  ///
  /// Steps performed:
  /// 1. Checks if the device location service is enabled.
  /// 2. Checks the app's location permission status.
  /// 3. Requests permission if it has not been granted yet.
  /// 4. Returns the position using [LocationAccuracy.high].
  ///
  /// Throws [Exception] with a user-readable message if:
  /// - Location services are disabled on the device.
  /// - The user denies the permission prompt.
  /// - The user has permanently denied location permissions.
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Step 1: Verify location services are turned on in device settings
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Step 2: Check the current permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Step 3: Request permission if not yet granted
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    // Permanently denied — user must enable it manually in device settings
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    // Step 4: All checks passed — get the current GPS position at high accuracy
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Converts a GPS [Position] to a human-readable address string via reverse geocoding.
  ///
  /// Uses the [geocoding] package to look up placemarks for the given coordinates.
  /// Returns a concatenated string in the format: `"Street, City, Country"`.
  ///
  /// Returns `'Unknown location'` if no placemarks are found or the result is empty.
  Future<String> getAddressFromPosition(Position position) async {
    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isEmpty) return 'Unknown location';
    final place = placemarks.first;
    // Build a compact address from the most useful placemark fields
    return '${place.street}, ${place.locality}, ${place.country}';
  }
}
