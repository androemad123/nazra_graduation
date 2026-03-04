import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/activity_log_model.dart';
import '../../repositories/activity_log_repository.dart';

// Link the event and state files as parts of this bloc
part 'activity_log_event.dart';
part 'activity_log_state.dart';

/// BLoC responsible for managing the user's activity log.
///
/// It listens to a real-time stream of activity documents from Firestore
/// and supports filtering activities by type (e.g., Complaints, Communities, Rewards).
///
/// Events handled:
/// - [LoadActivityLogs] : Starts the Firestore stream and loads all activities.
/// - [_UpdateActivityLogs] : Internal event triggered whenever new data arrives from the stream.
/// - [FilterActivityLogs] : Filters the already-loaded activities by a given type label.
class ActivityLogBloc extends Bloc<ActivityLogEvent, ActivityLogState> {
  /// Repository used to fetch activity data from Firestore.
  final ActivityLogRepository _repository;

  /// Active Firestore stream subscription. Stored so it can be cancelled on reload or close.
  StreamSubscription? _subscription;

  /// Creates the bloc and wires up event handlers.
  ///
  /// Starts in the [ActivityLogLoading] state.
  ActivityLogBloc({required ActivityLogRepository repository})
      : _repository = repository,
        super(ActivityLogLoading()) {
    on<LoadActivityLogs>(_onLoadActivityLogs);
    on<_UpdateActivityLogs>(_onUpdateActivityLogs);
    on<FilterActivityLogs>(_onFilterActivityLogs);
  }

  /// Handles [LoadActivityLogs]: cancels any existing subscription,
  /// emits a loading state, then starts listening to [ActivityLogRepository.getUserActivities].
  ///
  /// Every time new data arrives, it dispatches [_UpdateActivityLogs] internally.
  /// Errors from the stream emit [ActivityLogError].
  void _onLoadActivityLogs(LoadActivityLogs event, Emitter<ActivityLogState> emit) {
    emit(ActivityLogLoading());
    _subscription?.cancel();
    _subscription = _repository.getUserActivities().listen(
      (activities) => add(_UpdateActivityLogs(activities)),
      onError: (error) => emit(ActivityLogError(error.toString())),
    );
  }

  /// Handles [_UpdateActivityLogs]: emits a fresh [ActivityLogLoaded] state
  /// with both the full list and the filtered list set to all activities (no filter applied).
  void _onUpdateActivityLogs(_UpdateActivityLogs event, Emitter<ActivityLogState> emit) {
    emit(ActivityLogLoaded(
      allActivities: event.activities,
      filteredActivities: event.activities,
    ));
  }

  /// Handles [FilterActivityLogs]: filters the currently loaded activities by type.
  ///
  /// - 'All' → returns all activities without filtering.
  /// - 'Complaints' → keeps only [ActivityType.complaint].
  /// - 'Communities' → keeps only [ActivityType.community].
  /// - 'Rewards' → keeps only [ActivityType.reward].
  ///
  /// This does NOT reload from Firestore; it operates on the in-memory list.
  void _onFilterActivityLogs(FilterActivityLogs event, Emitter<ActivityLogState> emit) {
    final currentState = state;
    if (currentState is ActivityLogLoaded) {
      List<ActivityLog> filtered;
      if (event.filter == 'All') {
        // No filter — show everything
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
          // Keep only activities that match the selected type
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

  /// Cancels the Firestore stream subscription when the bloc is closed
  /// to prevent memory leaks.
  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
