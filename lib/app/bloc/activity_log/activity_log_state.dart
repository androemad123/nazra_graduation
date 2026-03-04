part of 'activity_log_bloc.dart';

/// Base class for all activity log states.
///
/// All states extend [Equatable] so that the widget tree only rebuilds
/// when the state actually changes.
abstract class ActivityLogState extends Equatable {
  const ActivityLogState();
  
  @override
  List<Object> get props => [];
}

/// Emitted while the activity log is being fetched from Firestore.
///
/// The UI should show a loading indicator in this state.
class ActivityLogLoading extends ActivityLogState {}

/// Emitted when the activity log has been successfully loaded.
///
/// Contains both the full unfiltered list and the currently displayed subset.
class ActivityLogLoaded extends ActivityLogState {
  /// The complete list of all user activities (used as the source of truth for filtering).
  final List<ActivityLog> allActivities;

  /// The filtered list currently shown to the user (may equal [allActivities] when no filter is active).
  final List<ActivityLog> filteredActivities;

  /// The active filter label (e.g., 'All', 'Complaints', 'Communities', 'Rewards').
  /// Defaults to 'All' when no filter has been applied.
  final String currentFilter;

  const ActivityLogLoaded({
    required this.allActivities,
    required this.filteredActivities,
    this.currentFilter = 'All',
  });

  @override
  List<Object> get props => [allActivities, filteredActivities, currentFilter];
}

/// Emitted when an error occurs while loading or listening to the activity log stream.
///
/// [message] contains a human-readable description of what went wrong.
class ActivityLogError extends ActivityLogState {
  /// The error message to display or log.
  final String message;

  const ActivityLogError(this.message);

  @override
  List<Object> get props => [message];
}
