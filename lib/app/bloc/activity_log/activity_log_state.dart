part of 'activity_log_bloc.dart';

abstract class ActivityLogState extends Equatable {
  const ActivityLogState();
  
  @override
  List<Object> get props => [];
}

class ActivityLogLoading extends ActivityLogState {}

class ActivityLogLoaded extends ActivityLogState {
  final List<ActivityLog> allActivities;
  final List<ActivityLog> filteredActivities;
  final String currentFilter;

  const ActivityLogLoaded({
    required this.allActivities,
    required this.filteredActivities,
    this.currentFilter = 'All',
  });

  @override
  List<Object> get props => [allActivities, filteredActivities, currentFilter];
}

class ActivityLogError extends ActivityLogState {
  final String message;

  const ActivityLogError(this.message);

  @override
  List<Object> get props => [message];
}
