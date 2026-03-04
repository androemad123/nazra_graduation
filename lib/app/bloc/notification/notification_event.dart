part of 'notification_bloc.dart';

/// Base class for all notification events.
///
/// All events extend [Equatable] for efficient BLoC comparison.
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

/// Event to start loading the current user's notifications from Firestore.
///
/// Subscribes to a real-time stream. Any existing subscription is cancelled first.
class LoadNotifications extends NotificationEvent {}

/// Internal event dispatched by the stream listener when new notifications arrive.
///
/// Should not be dispatched from outside the bloc — it is used internally
/// to bridge the stream callback into a BLoC event.
class UpdateNotifications extends NotificationEvent {
  /// The refreshed list of [AppNotification] objects from Firestore.
  final List<AppNotification> notifications;

  const UpdateNotifications(this.notifications);

  @override
  List<Object> get props => [notifications];
}

/// Event to mark a single notification as read.
///
/// [notificationId] is the Firestore document ID of the notification to update.
class MarkAsRead extends NotificationEvent {
  /// The Firestore document ID of the notification to mark as read.
  final String notificationId;

  const MarkAsRead(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

/// Event to mark ALL unread notifications of the current user as read.
///
/// Uses a Firestore batch write for an atomic, efficient bulk update.
class MarkAllAsRead extends NotificationEvent {}
