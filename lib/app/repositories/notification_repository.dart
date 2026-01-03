import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference get _notifications => _firestore.collection('notifications');

  /// Send a notification to a specific user
  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String body,
    required NotificationType type,
    String? relatedId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return; // Or throw, but silently failing might be safer for UI flow

      // Don't notify self
      if (recipientId == currentUser.uid) return;

      await _notifications.add({
        'recipientId': recipientId,
        'senderId': currentUser.uid,
        'title': title,
        'body': body,
        'type': type.name,
        'relatedId': relatedId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending notification: $e');
      // Don't rethrow to avoid blocking the main action (like voting)
    }
  }

  /// Stream notifications for the current user
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

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notifications.doc(notificationId).update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
  
  /// Mark all notifications as read for current user
  Future<void> markAllAsRead() async {
     final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _notifications
          .where('recipientId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }
}
