import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/notification_model.dart';

/// Repository for managing in-app notifications in Firestore.
///
/// Notifications are stored in the `notifications` Firestore collection.
/// Each document is targeted at a specific recipient user and is read
/// back by [NotificationBloc] via a real-time stream.
///
/// Key behaviours:
/// - Silently ignores attempts to notify users of their own actions.
/// - Does NOT throw on notification send failure, so that secondary failures
///   never block the main user action (e.g., voting on an issue still succeeds
///   even if sending the notification fails).
class NotificationRepository {
  /// Firestore instance for all read/write operations.
  final FirebaseFirestore _firestore;

  /// Firebase Auth instance for identifying the current user.
  final FirebaseAuth _auth;

  /// Creates the repository with optional injectable dependencies.
  ///
  /// Defaults to singleton instances if not provided.
  NotificationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Convenience reference to the `notifications` Firestore collection.
  CollectionReference get _notifications => _firestore.collection('notifications');

  /// Sends an in-app notification to the user identified by [recipientId].
  ///
  /// Silently returns without sending if:
  /// - No user is currently signed in.
  /// - The recipient is the same as the sender (self-notification prevention).
  ///
  /// [recipientId] — Firebase UID of the user who should see the notification.
  /// [title]        — Short heading (e.g., 'New Vote').
  /// [body]         — Detail text (e.g., 'Someone voted on your issue: "Pothole"').
  /// [type]         — [NotificationType] used for UI rendering and navigation.
  /// [relatedId]    — Optional ID of the related entity (issue, community, etc.).
  ///
  /// Errors are caught and printed (non-fatal) to avoid blocking the main action.
  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String body,
    required NotificationType type,
    String? relatedId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return; // Not authenticated — silently skip

      // Do not send a notification to the user who triggered the action
      if (recipientId == currentUser.uid) return;

      await _notifications.add({
        'recipientId': recipientId,
        'senderId': currentUser.uid,
        'title': title,
        'body': body,
        'type': type.name, // Stored as string (e.g., 'vote')
        'relatedId': relatedId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending notification: $e');
      // Non-fatal: do not rethrow so the caller's primary operation is not interrupted
    }
  }

  /// Returns a real-time stream of [AppNotification] objects for the current user.
  ///
  /// Notifications are filtered to the current user's UID and ordered by
  /// creation date (newest first). Returns an empty stream if unauthenticated.
  Stream<List<AppNotification>> watchNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _notifications
        .where('recipientId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppNotification.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Marks a single notification as read by updating its `isRead` field.
  ///
  /// The UI will update automatically via the real-time stream after the write.
  /// Errors are caught and printed (non-fatal).
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notifications.doc(notificationId).update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Marks all unread notifications for the current user as read in a single batch write.
  ///
  /// Uses a Firestore [WriteBatch] to perform the bulk update atomically,
  /// which is more efficient than individual update calls.
  ///
  /// Silently returns if no user is signed in. Errors are caught and printed.
  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      final batch = _firestore.batch();

      // Fetch only the unread documents to minimise Firestore write cost
      final querySnapshot = await _notifications
          .where('recipientId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .get();

      // Queue an update for each unread notification in the batch
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      // Commit all updates in a single round-trip
      await batch.commit();
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }
}
