part of 'notification_bloc.dart';

/// Base class for all notification states.
///
/// All states extend [Equatable] so widgets only rebuild on actual state changes.
abstract class NotificationState extends Equatable {
  const NotificationState();
  
  @override
  List<Object> get props => [];
}

/// Emitted before [LoadNotifications] has been dispatched (default state).
class NotificationInitial extends NotificationState {}

/// Emitted while the Firestore notifications stream is being set up.
///
/// The UI should display a loading indicator in this state.
class NotificationLoading extends NotificationState {}

/// Emitted when the notification stream has successfully delivered data.
///
/// Contains the full list of [AppNotification] objects for the current user.
/// Also exposes a convenience [unreadCount] getter.
class NotificationLoaded extends NotificationState {
  /// The complete list of notifications for the current user.
  final List<AppNotification> notifications;

  const NotificationLoaded(this.notifications);

  @override
  List<Object> get props => [notifications];

  /// Number of unread notifications — computed from the list.
  /// Used to show the badge count on the notification icon.
  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

/// Emitted when an error occurs in the notification stream.
///
/// [message] contains a human-readable description of what went wrong.
class NotificationError extends NotificationState {
  /// The error message to display or log.
  final String message;

  const NotificationError(this.message);

  @override
  List<Object> get props => [message];
}
