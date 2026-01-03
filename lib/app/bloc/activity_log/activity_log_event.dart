part of 'activity_log_bloc.dart';

abstract class ActivityLogEvent extends Equatable {
  const ActivityLogEvent();

  @override
  List<Object> get props => [];
}

class LoadActivityLogs extends ActivityLogEvent {}

class FilterActivityLogs extends ActivityLogEvent {
  final String filter;

  const FilterActivityLogs(this.filter);

  @override
  List<Object> get props => [filter];
}

class _UpdateActivityLogs extends ActivityLogEvent {
  final List<ActivityLog> activities;

  const _UpdateActivityLogs(this.activities);

  @override
  List<Object> get props => [activities];
}
