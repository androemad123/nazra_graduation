import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import '../models/activity_log_model.dart';
import '../models/issue_model.dart';
import 'activity_log_repository.dart';
import 'notification_repository.dart';
import '../models/notification_model.dart';

/// Repository for managing community issues
class IssueRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final NotificationRepository _notificationRepository;
  final ActivityLogRepository _activityLogRepository;

  IssueRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    NotificationRepository? notificationRepository,
    ActivityLogRepository? activityLogRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _notificationRepository = notificationRepository ?? NotificationRepository(),
        _activityLogRepository = activityLogRepository ?? ActivityLogRepository();

  CollectionReference get _issues => _firestore.collection('issues');

  /// Create a new issue in a community
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

      final normalizedAnalysis = _normalizeMlPayload(mlAnalysisResult);
      final Map<String, dynamic> aiDetails =
          normalizedAnalysis?['data'] as Map<String, dynamic>? ?? {};
      // Use ML-suggested category if available, otherwise use provided category
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
        'votes': [],
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (normalizedAnalysis != null) 'aiAnalysis': normalizedAnalysis,
        if (location != null) 'location': GeoPoint(location.latitude, location.longitude),
        if (address != null) 'address': address,
      };

      await docRef.set(issueData);

      // Log activity
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

  /// Get all issues for a specific community
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

  /// Get a single issue by ID
  Stream<Issue?> watchIssue(String issueId) {
    return _issues.doc(issueId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data() as Map<String, dynamic>;
      return Issue.fromMap(data, snapshot.id);
    });
  }

  /// Vote on an issue
  Future<void> voteIssue(String issueId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final docRef = _issues.doc(issueId);
      String? issueOwnerId;
      String? issueTitle;

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

          // Log activity for upvote
          _activityLogRepository.logActivity(
            title: 'Upvoted: "$issueTitle"',
            description: 'You supported this issue.',
            type: ActivityType.vote,
            relatedId: issueId,
          );
        }
      });

      // Send notification after transaction (best effort)
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

  /// Remove vote from an issue
  Future<void> unvoteIssue(String issueId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _issues.doc(issueId).update({
        'votes': FieldValue.arrayRemove([user.uid]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error unvoting issue: $e');
      rethrow;
    }
  }

  /// Escalate an issue (typically done by owner or when vote threshold is reached)
  Future<void> escalateIssue(String issueId, {String? note}) async {
    try {
      await _issues.doc(issueId).update({
        'status': 'escalated',
        if (note != null) 'escalationNote': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Fetch issue to get owner
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

  /// Resolve an issue
  Future<void> resolveIssue(String issueId, {String? note}) async {
    try {
      await _issues.doc(issueId).update({
        'status': 'resolved',
        if (note != null) 'escalationNote': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Fetch issue to get owner
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

  /// Delete an issue (only by creator or community owner)
  Future<void> deleteIssue(String issueId) async {
    try {
      await _issues.doc(issueId).delete();
    } catch (e) {
      print('Error deleting issue: $e');
      rethrow;
    }
  }
}
