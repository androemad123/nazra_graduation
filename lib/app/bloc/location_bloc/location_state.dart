// blocs/location_bloc/location_state.dart
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Immutable state for the location BLoC (Equatable-based variant).
///
/// Holds all location-related UI data in a single unified state object
/// using the [copyWith] pattern. This is an alternative to the sealed-class
/// approach used in `location_bloc.dart`.
///
/// Fields:
/// - [isLoading] : true while location is being fetched.
/// - [position]  : The GPS coordinate once fetched (null until loaded).
/// - [address]   : The reverse-geocoded address string (null until loaded).
/// - [error]     : An error message if something went wrong (null otherwise).
class LocationState extends Equatable {
  /// Whether a location fetch is currently in progress.
  final bool isLoading;

  /// The fetched map coordinate. Null until a location has been loaded.
  final LatLng? position;

  /// The human-readable address resolved from [position]. Null until geocoding completes.
  final String? address;

  /// An error message — set if location services or permissions failed.
  /// Reset to null on the next successful fetch.
  final String? error;

  const LocationState({
    this.isLoading = false,
    this.position,
    this.address,
    this.error,
  });

  /// Creates a modified copy of this state with selective field overrides.
  ///
  /// Note: [error] is NOT null-safe here — passing `error: null` explicitly
  /// resets it, while omitting it does not preserve the previous error.
  LocationState copyWith({
    bool? isLoading,
    LatLng? position,
    String? address,
    String? error,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      address: address ?? this.address,
      error: error, // Intentionally not null-coalesced — allows explicit reset
    );
  }

  @override
  List<Object?> get props => [isLoading, position, address, error];
}
