import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing the different categories of in-app notifications.
///
/// Used to determine how the notification is displayed and which action to
/// take when the user taps it.
///
/// - [vote]            : Someone voted on an issue the user owns.
/// - [statusChange]    : An issue or complaint's status was updated.
/// - [joinRequest]     : Someone requested to join a community the user owns.
/// - [requestAccepted] : The user's own join request to a community was accepted.
/// - [general]         : A generic notification that does not fall into the above categories.
enum NotificationType {
  vote,
  statusChange,
  joinRequest,
  requestAccepted,
  general,
}

/// Data model for a single in-app notification.
///
/// Notifications are stored in the `notifications` Firestore collection.
/// Each notification is sent from one user to another when a significant action occurs
/// (e.g., a vote, a join request, a status change).
///
/// The [NotificationRepository] writes these documents, and [NotificationBloc]
/// watches them in real time.
class AppNotification {
  /// Firestore document ID for this notification.
  final String id;

  /// Firebase UID of the user who should receive (see) this notification.
  final String recipientId;

  /// Firebase UID of the user who triggered this notification (e.g., the voter).
  final String senderId;

  /// Short title of the notification (e.g., "New Vote").
  final String title;

  /// Body text of the notification (e.g., 'Someone voted on your issue: "Pothole"').
  final String body;

  /// The type/category of the notification — affects how it's rendered and nav-handled.
  final NotificationType type;

  /// The Firestore ID of the entity this notification relates to
  /// (e.g., an issue ID, community ID). Used for deep navigation.
  final String? relatedId;

  /// Whether the user has already read this notification. Defaults to false.
  final bool isRead;

  /// Timestamp when this notification was created.
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.recipientId,
    required this.senderId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    this.isRead = false,
    required this.createdAt,
  });

  /// Creates an [AppNotification] from a Firestore document map.
  ///
  /// [map] is the raw `data()` from the snapshot. [id] is the Firestore document ID.
  ///
  /// [type] is resolved by name; unknown values fall back to [NotificationType.general].
  /// [createdAt] falls back to [DateTime.now()] if the Firestore timestamp is absent.
  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    return AppNotification(
      id: id,
      recipientId: map['recipientId'] ?? '',
      senderId: map['senderId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.general,
      ),
      relatedId: map['relatedId'],
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Serialises this [AppNotification] to a Firestore-compatible map.
  ///
  /// [type] is stored as its string name (e.g., 'vote').
  /// [createdAt] is stored as a [Timestamp].
  /// Note: [id] is NOT included — Firestore uses the document ID separately.
  Map<String, dynamic> toMap() {
    return {
      'recipientId': recipientId,
      'senderId': senderId,
      'title': title,
      'body': body,
      'type': type.name,
      'relatedId': relatedId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
