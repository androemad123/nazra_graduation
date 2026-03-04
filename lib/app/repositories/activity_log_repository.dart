import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/activity_log_model.dart';

/// Repository for managing user activity logs in Firestore.
///
/// Activity logs are stored in the `activity_logs` collection and are created
/// automatically by other repositories (community, issue, etc.) when the user
/// performs significant actions.
///
/// All write operations are best-effort: errors are caught and printed rather
/// than rethrown, so that failures in logging do not disrupt the main user flow.
class ActivityLogRepository {
  /// Firestore instance used for all database operations.
  final FirebaseFirestore _firestore;

  /// Firebase Auth instance used to identify the current user.
  final FirebaseAuth _auth;

  /// Creates the repository with optional injectable dependencies.
  ///
  /// Defaults to the singleton instances if not provided,
  /// enabling easy dependency injection in tests.
  ActivityLogRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Convenience reference to the `activity_logs` Firestore collection.
  CollectionReference get _activityLogs => _firestore.collection('activity_logs');

  /// Records a new activity entry for the currently signed-in user.
  ///
  /// Silently no-ops if no user is logged in.
  /// Errors during the Firestore write are caught and printed (non-fatal).
  ///
  /// [title]       — Short human-readable label (e.g., 'Complaint filed: "Pothole"').
  /// [description] — More detailed text shown in the log detail view.
  /// [type]        — The [ActivityType] enum value (stored as its string name).
  /// [relatedId]   — Optional Firestore ID of the related entity (issue, community, etc.).
  Future<void> logActivity({
    required String title,
    required String description,
    required ActivityType type,
    String? relatedId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return; // Guard: silently skip if not authenticated

    try {
      await _activityLogs.add({
        'userId': user.uid,
        'title': title,
        'description': description,
        'type': type.name, // Store the enum as a string (e.g., 'complaint')
        'relatedId': relatedId,
        'createdAt': FieldValue.serverTimestamp(), // Let Firestore set the timestamp
      });
    } catch (e) {
      print('Error logging activity: $e');
      // Non-fatal: do not rethrow so the caller's main operation is not blocked
    }
  }

  /// Returns a real-time stream of activity log entries for the current user.
  ///
  /// Activities are ordered by [createdAt] in descending order (newest first).
  /// Returns an empty stream if no user is signed in.
  ///
  /// Each Firestore snapshot is mapped to a list of [ActivityLog] model objects.
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
