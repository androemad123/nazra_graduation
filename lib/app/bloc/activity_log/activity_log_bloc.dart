import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/activity_log_model.dart';
import '../../repositories/activity_log_repository.dart';

part 'activity_log_event.dart';
part 'activity_log_state.dart';

class ActivityLogBloc extends Bloc<ActivityLogEvent, ActivityLogState> {
  final ActivityLogRepository _repository;
  StreamSubscription? _subscription;

  ActivityLogBloc({required ActivityLogRepository repository})
      : _repository = repository,
        super(ActivityLogLoading()) {
    on<LoadActivityLogs>(_onLoadActivityLogs);
    on<_UpdateActivityLogs>(_onUpdateActivityLogs);
    on<FilterActivityLogs>(_onFilterActivityLogs);
  }

  void _onLoadActivityLogs(LoadActivityLogs event, Emitter<ActivityLogState> emit) {
    emit(ActivityLogLoading());
    _subscription?.cancel();
    _subscription = _repository.getUserActivities().listen(
      (activities) => add(_UpdateActivityLogs(activities)),
      onError: (error) => emit(ActivityLogError(error.toString())),
    );
  }

  void _onUpdateActivityLogs(_UpdateActivityLogs event, Emitter<ActivityLogState> emit) {
    emit(ActivityLogLoaded(
      allActivities: event.activities,
      filteredActivities: event.activities,
    ));
  }

  void _onFilterActivityLogs(FilterActivityLogs event, Emitter<ActivityLogState> emit) {
    final currentState = state;
    if (currentState is ActivityLogLoaded) {
      List<ActivityLog> filtered;
      if (event.filter == 'All') {
        filtered = currentState.allActivities;
      } else {
        ActivityType? type;
        switch (event.filter) {
          case 'Complaints':
            type = ActivityType.complaint;
            break;
          case 'Communities':
            type = ActivityType.community;
            break;
          case 'Rewards':
            type = ActivityType.reward;
            break;
        }
        
        if (type != null) {
          filtered = currentState.allActivities.where((a) => a.type == type).toList();
        } else {
           filtered = currentState.allActivities;
        }
      }

      emit(ActivityLogLoaded(
        allActivities: currentState.allActivities,
        filteredActivities: filtered,
        currentFilter: event.filter,
      ));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
