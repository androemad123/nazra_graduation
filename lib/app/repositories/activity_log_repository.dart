import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/activity_log_model.dart';

class ActivityLogRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ActivityLogRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference get _activityLogs => _firestore.collection('activity_logs');

  /// Log a new activity
  Future<void> logActivity({
    required String title,
    required String description,
    required ActivityType type,
    String? relatedId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _activityLogs.add({
        'userId': user.uid,
        'title': title,
        'description': description,
        'type': type.name,
        'relatedId': relatedId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  /// Get activities for the current user
  Stream<List<ActivityLog>> getUserActivities() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _activityLogs
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ActivityLog.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }
}
