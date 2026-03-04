part of 'activity_log_bloc.dart';

/// Base class for all activity log events.
///
/// All events extend [Equatable] so the BLoC can compare them
/// and avoid processing duplicate events.
abstract class ActivityLogEvent extends Equatable {
  const ActivityLogEvent();

  @override
  List<Object> get props => [];
}

/// Event to start loading the user's activity logs from Firestore.
///
/// Dispatching this event will cancel any existing stream subscription
/// and start a new one, effectively refreshing the activity log.
class LoadActivityLogs extends ActivityLogEvent {}

/// Event to filter the already-loaded activity logs by a human-readable label.
///
/// [filter] should be one of: 'All', 'Complaints', 'Communities', 'Rewards'.
/// Filtering is performed in memory — no new Firestore query is made.
class FilterActivityLogs extends ActivityLogEvent {
  /// The filter label selected by the user (e.g., 'Complaints').
  final String filter;

  const FilterActivityLogs(this.filter);

  @override
  List<Object> get props => [filter];
}

/// Internal event dispatched by the BLoC itself when the Firestore stream
/// emits a new list of activities.
///
/// This is private (prefixed with `_`) and should NOT be dispatched from outside the bloc.
class _UpdateActivityLogs extends ActivityLogEvent {
  /// The latest list of [ActivityLog] objects received from the Firestore stream.
  final List<ActivityLog> activities;

  const _UpdateActivityLogs(this.activities);

  @override
  List<Object> get props => [activities];
}
