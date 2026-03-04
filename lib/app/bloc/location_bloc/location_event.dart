// blocs/location_bloc/location_event.dart
import 'package:equatable/equatable.dart';

/// Base class for location events that use [Equatable] for comparison.
///
/// Note: The primary event/state/bloc definitions for the location feature
/// live in `location_bloc.dart`. This file defines a separate Equatable-based
/// event hierarchy (used in an alternative implementation or future extension).
abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request fetching the device's current location.
///
/// When dispatched, the BLoC will ask [LocationService] to check permissions,
/// get the current GPS position, and reverse-geocode it into an address string.
class FetchCurrentLocation extends LocationEvent {}
