import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

/// Base class for all location events handled by [LocationBloc].
abstract class LocationEvent {}

/// Event to fetch the device's current GPS position and resolve its address.
///
/// Dispatching this event triggers the location service to:
/// 1. Check that location services and permissions are enabled.
/// 2. Get the current [Position] from the device GPS.
/// 3. Reverse-geocode the position into a human-readable address string.
class FetchLocation extends LocationEvent {}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

/// Base class for all location states emitted by [LocationBloc].
abstract class LocationState {}

/// Emitted before any location fetch has been requested (default state).
class LocationInitial extends LocationState {}

/// Emitted while the location is being fetched and geocoded.
///
/// The UI should show a loading indicator in this state.
class LocationLoading extends LocationState {}

/// Emitted when a location has been successfully fetched and geocoded.
class LocationLoaded extends LocationState {
  /// The raw GPS position returned by [Geolocator].
  final Position position;

  /// A human-readable address string resolved via reverse geocoding.
  final String address;
  LocationLoaded({required this.position, required this.address});
}

/// Emitted when an error occurs during location fetch or geocoding.
class LocationError extends LocationState {
  /// A description of what went wrong (e.g., permissions denied, service off).
  final String message;
  LocationError(this.message);
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

/// BLoC that manages fetching and exposing the device's current location.
///
/// Delegates all location and geocoding work to [LocationService].
///
/// Events handled:
/// - [FetchLocation] : Gets the current GPS position and its human-readable address.
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  /// Service that wraps [Geolocator] and [geocoding] for location operations.
  final LocationService locationService;

  /// Creates the bloc, starting in [LocationInitial], and registers the [FetchLocation] handler.
  LocationBloc(this.locationService) : super(LocationInitial()) {
    on<FetchLocation>((event, emit) async {
      emit(LocationLoading());
      try {
        // Step 1: Get high-accuracy GPS coordinates from the device
        final position = await locationService.getCurrentPosition();
        // Step 2: Reverse geocode the coordinates into a readable address
        final address = await locationService.getAddressFromPosition(position);
        emit(LocationLoaded(position: position, address: address));
      } catch (e) {
        // Catch permission errors, service-disabled, or geocoding failures
        emit(LocationError(e.toString()));
      }
    });
  }
}
