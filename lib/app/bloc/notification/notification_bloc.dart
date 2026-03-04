import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/notification_model.dart';
import '../../repositories/notification_repository.dart';

// Link event and state files as parts of this bloc
part 'notification_event.dart';
part 'notification_state.dart';

/// BLoC that manages the user's in-app notifications.
///
/// Listens to a real-time Firestore stream of notification documents
/// for the current user and supports marking individual or all notifications as read.
///
/// Events handled:
/// - [LoadNotifications]  : Starts the Firestore stream for this user's notifications.
/// - [UpdateNotifications]: Internal — fired when the stream emits fresh data.
/// - [MarkAsRead]         : Marks a single notification as read in Firestore.
/// - [MarkAllAsRead]      : Marks all unread notifications as read in a batched write.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  /// Repository that handles all Firestore reads/writes for notifications.
  final NotificationRepository _notificationRepository;

  /// Active Firestore stream subscription for the user's notifications.
  StreamSubscription? _notificationSubscription;

  /// Creates the bloc and registers event handlers.
  ///
  /// Starts in [NotificationInitial] state.
  NotificationBloc({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository,
        super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<UpdateNotifications>(_onUpdateNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
  }

  /// Handles [LoadNotifications]: cancels any previous subscription,
  /// emits [NotificationLoading], then subscribes to Firestore notifications stream.
  ///
  /// When new data arrives, the [UpdateNotifications] event is dispatched internally.
  /// Stream errors are currently only printed — consider emitting an error state in production.
  void _onLoadNotifications(LoadNotifications event, Emitter<NotificationState> emit) {
    emit(NotificationLoading());
    _notificationSubscription?.cancel();
    _notificationSubscription = _notificationRepository.watchNotifications().listen(
      (notifications) => add(UpdateNotifications(notifications)),
      onError: (error) => print('Notification stream error: $error'), // TODO: Emit error state in production
    );
  }

  /// Handles [UpdateNotifications]: replaces the state with a fresh [NotificationLoaded]
  /// containing the updated list from Firestore.
  void _onUpdateNotifications(UpdateNotifications event, Emitter<NotificationState> emit) {
    emit(NotificationLoaded(event.notifications));
  }

  /// Handles [MarkAsRead]: updates a single notification's `isRead` field in Firestore.
  ///
  /// The list will refresh automatically via the stream after the write.
  Future<void> _onMarkAsRead(MarkAsRead event, Emitter<NotificationState> emit) async {
    await _notificationRepository.markAsRead(event.notificationId);
  }

  /// Handles [MarkAllAsRead]: uses a Firestore batch write to mark all unread
  /// notifications for the current user as read in a single atomic operation.
  Future<void> _onMarkAllAsRead(MarkAllAsRead event, Emitter<NotificationState> emit) async {
    await _notificationRepository.markAllAsRead();
  }

  /// Cancels the Firestore stream subscription when the bloc is closed.
  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}
