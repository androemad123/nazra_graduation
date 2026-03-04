import 'package:equatable/equatable.dart';

/// Base class for all complaint-related events.
///
/// Extends [Equatable] so the BLoC can compare event instances.
abstract class ComplaintEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to start loading the complaints of the currently signed-in user.
///
/// Opens a real-time Firestore stream filtered to the current user's UID.
/// Any previously active stream is cancelled before starting the new one.
class LoadUserComplaints extends ComplaintEvent {}

/// Event to start loading ALL complaints in Firestore (for admin/officer views).
///
/// Opens a real-time Firestore stream with no user filter.
/// Any previously active stream is cancelled before starting the new one.
class LoadAllComplaints extends ComplaintEvent {}
