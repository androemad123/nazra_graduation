import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import '../models/activity_log_model.dart';
import '../models/issue_model.dart';
import 'activity_log_repository.dart';
import 'notification_repository.dart';
import '../models/notification_model.dart';

/// Repository for managing community issues in Firestore.
///
/// Issues are user-submitted problem reports within a specific community.
/// They support voting, escalation, and resolution workflows.
///
/// Collaborates with:
/// - [NotificationRepository]: sends notifications to issue owners on votes and status changes.
/// - [ActivityLogRepository]: logs voting and creation actions to the user's activity feed.
class IssueRepository {
  /// Firestore instance for all database operations.
  final FirebaseFirestore _firestore;

  /// Firebase Auth instance for identifying the current user.
  final FirebaseAuth _auth;

  /// Used to send in-app notifications on vote, escalation, and resolution.
  final NotificationRepository _notificationRepository;

  /// Used to log user actions (voting, creation) to the activity feed.
  final ActivityLogRepository _activityLogRepository;

  /// Creates the repository with optional injectable dependencies.
  ///
  /// Defaults to singleton instances if not provided.
  IssueRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    NotificationRepository? notificationRepository,
    ActivityLogRepository? activityLogRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _notificationRepository = notificationRepository ?? NotificationRepository(),
        _activityLogRepository = activityLogRepository ?? ActivityLogRepository();

  /// Convenience reference to the `issues` Firestore collection.
  CollectionReference get _issues => _firestore.collection('issues');

  /// Creates a new issue document in Firestore.
  ///
  /// Normalises the ML payload and optionally uses its suggested category
  /// if it overrides the one provided by the user.
  ///
  /// Logs a complaint-type activity to the activity feed after creation.
  ///
  /// Returns the Firestore document ID of the newly created issue.
  /// Throws on authentication failure or Firestore error.
  Future<String> createIssue({
    required String communityId,
    required String title,
    required String description,
    required List<String> imageUrls,
    required String category,
    Map<String, dynamic>? mlAnalysisResult,
    Position? location,
    String? address,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Normalise the ML payload into `{is_issue, data}` format
      final normalizedAnalysis = _normalizeMlPayload(mlAnalysisResult);
      final Map<String, dynamic> aiDetails =
          normalizedAnalysis?['data'] as Map<String, dynamic>? ?? {};

      // Prefer ML-suggested category if available and non-empty
      final finalCategory = (aiDetails['category'] as String?)?.isNotEmpty == true
          ? aiDetails['category'] as String
          : category;

      final docRef = _issues.doc();
      final issueData = {
        'id': docRef.id,
        'communityId': communityId,
        'userId': user.uid,
        'title': title,
        'description': description,
        'imageUrls': imageUrls,
        'category': finalCategory,
        'votes': [], // No votes yet
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Only include optional fields when they have values
        if (normalizedAnalysis != null) 'aiAnalysis': normalizedAnalysis,
        if (location != null) 'location': GeoPoint(location.latitude, location.longitude),
        if (address != null) 'address': address,
      };

      await docRef.set(issueData);

      // Log this as a complaint-type activity in the user's activity feed
      await _activityLogRepository.logActivity(
        title: 'Complaint filed: "$title"',
        description: description,
        type: ActivityType.complaint,
        relatedId: docRef.id,
      );

      return docRef.id;
    } catch (e) {
      print('Error creating issue: $e');
      rethrow;
    }
  }

  /// Normalises the raw ML API response to a consistent Firestore-safe structure.
  ///
  /// Returns `{ "is_issue": bool, "data": { ...ai fields } }` or null if input is null.
  Map<String, dynamic>? _normalizeMlPayload(Map<String, dynamic>? payload) {
    if (payload == null) return null;

    final aiDataRaw = payload['data'];
    return {
      'is_issue': payload['is_issue'] ?? true,
      'data': aiDataRaw is Map<String, dynamic>
          ? Map<String, dynamic>.from(aiDataRaw)
          : <String, dynamic>{},
    };
  }

  /// Returns a real-time stream of all issues for a specific [communityId].
  ///
  /// Results are ordered by creation date (newest first).
  /// Each snapshot is mapped to a list of [Issue] model objects.
  Stream<List<Issue>> watchCommunityIssues(String communityId) {
    return _issues
        .where('communityId', isEqualTo: communityId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Issue.fromMap(data, doc.id);
      })
          .toList();
    });
  }

  /// Returns a real-time stream that watches a single issue by [issueId].
  ///
  /// Emits null if the document does not exist.
  Stream<Issue?> watchIssue(String issueId) {
    return _issues.doc(issueId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data() as Map<String, dynamic>;
      return Issue.fromMap(data, snapshot.id);
    });
  }

  /// Adds the current user's upvote to an issue atomically.
  ///
  /// Uses a Firestore transaction to safely add the user's UID to the `votes` array,
  /// preventing duplicate votes. Also logs the vote activity and sends a notification
  /// to the issue owner (best-effort, outside the transaction).
  ///
  /// Throws on authentication failure or Firestore error.
  Future<void> voteIssue(String issueId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final docRef = _issues.doc(issueId);
      String? issueOwnerId;
      String? issueTitle;

      // Atomically add the vote — prevents race conditions
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        if (!snap.exists) throw Exception('Issue not found');
        final data = snap.data() as Map<String, dynamic>;
        final votes = List<String>.from(data['votes'] ?? []);

        issueOwnerId = data['userId'];
        issueTitle = data['title'];

        if (!votes.contains(user.uid)) {
          votes.add(user.uid);
          tx.update(docRef, {
            'votes': votes,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Log the vote action to the user's activity feed (inside transaction scope is fine)
          _activityLogRepository.logActivity(
            title: 'Upvoted: "$issueTitle"',
            description: 'You supported this issue.',
            type: ActivityType.vote,
            relatedId: issueId,
          );
        }
      });

      // Send a notification to the issue owner (best-effort — outside the transaction)
      if (issueOwnerId != null && issueTitle != null) {
        await _notificationRepository.sendNotification(
          recipientId: issueOwnerId!,
          title: 'New Vote',
          body: 'Someone voted on your issue: "$issueTitle"',
          type: NotificationType.vote,
          relatedId: issueId,
        );
      }

    } catch (e) {
      print('Error voting on issue: $e');
      rethrow;
    }
  }

  /// Removes the current user's vote from an issue.
  ///
  /// Uses Firestore's [FieldValue.arrayRemove] for a safe, atomic array update.
  Future<void> unvoteIssue(String issueId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // arrayRemove is safe to call even if the UID isn't in the array
      await _issues.doc(issueId).update({
        'votes': FieldValue.arrayRemove([user.uid]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error unvoting issue: $e');
      rethrow;
    }
  }

  /// Marks an issue as 'escalated' in Firestore and notifies its owner.
  ///
  /// Typically triggered when a vote threshold is reached or a moderator
  /// decides the issue needs official attention.
  ///
  /// [note] is an optional message explaining the escalation reason.
  Future<void> escalateIssue(String issueId, {String? note}) async {
    try {
      await _issues.doc(issueId).update({
        'status': 'escalated',
        if (note != null) 'escalationNote': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Fetch the issue to get the owner's UID and title for the notification
      final docSnapshot = await _issues.doc(issueId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final ownerId = data['userId'];
        final title = data['title'];

        if (ownerId != null) {
          await _notificationRepository.sendNotification(
            recipientId: ownerId,
            title: 'Issue Escalated',
            body: 'Your issue "$title" has been escalated.',
            type: NotificationType.statusChange,
            relatedId: issueId,
          );
        }
      }

    } catch (e) {
      print('Error escalating issue: $e');
      rethrow;
    }
  }

  /// Marks an issue as 'resolved' in Firestore and notifies its owner.
  ///
  /// [note] is an optional message describing how the issue was resolved.
  Future<void> resolveIssue(String issueId, {String? note}) async {
    try {
      await _issues.doc(issueId).update({
        'status': 'resolved',
        if (note != null) 'escalationNote': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Fetch the issue to notify the owner
      final docSnapshot = await _issues.doc(issueId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final ownerId = data['userId'];
        final title = data['title'];

        if (ownerId != null) {
          await _notificationRepository.sendNotification(
            recipientId: ownerId,
            title: 'Issue Resolved',
            body: 'Your issue "$title" has been resolved.',
            type: NotificationType.statusChange,
            relatedId: issueId,
          );
        }
      }
    } catch (e) {
      print('Error resolving issue: $e');
      rethrow;
    }
  }

  /// Permanently deletes an issue document from Firestore.
  ///
  /// Should only be called by the issue creator or a community owner.
  /// Authorization is not enforced here — ensure callers check permissions first.
  Future<void> deleteIssue(String issueId) async {
    try {
      await _issues.doc(issueId).delete();
    } catch (e) {
      print('Error deleting issue: $e');
      rethrow;
    }
  }
}
