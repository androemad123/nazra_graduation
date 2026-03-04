import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_log_model.dart';
import '../models/community.dart';
import '../models/notification_model.dart';
import 'activity_log_repository.dart';
import 'notification_repository.dart';

/// Repository for all Firestore operations related to communities.
///
/// Handles creating communities, watching the list in real time,
/// managing join requests (request / approve / reject), and member removal.
///
/// Collaborates with:
/// - [NotificationRepository]: sends in-app notifications on join request / approval.
/// - [ActivityLogRepository]: logs significant user actions to the activity feed.
class CommunityRepository {
  /// Firestore instance used for all community-related database operations.
  final FirebaseFirestore _firestore;

  /// Used to send notifications to community owners and members.
  final NotificationRepository _notificationRepository;

  /// Used to record user actions in the activity log.
  final ActivityLogRepository _activityLogRepository;

  /// Creates the repository with optional injectable dependencies.
  ///
  /// Defaults to singleton instances if not provided, enabling easy mocking in tests.
  CommunityRepository({
    FirebaseFirestore? firestore,
    NotificationRepository? notificationRepository,
    ActivityLogRepository? activityLogRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _notificationRepository = notificationRepository ?? NotificationRepository(),
        _activityLogRepository = activityLogRepository ?? ActivityLogRepository();

  /// Convenience reference to the `communities` Firestore collection.
  CollectionReference get _communities => _firestore.collection('communities');
  
  /// Exposes the Firestore instance for screens that need to perform custom
  /// sub-collection queries (e.g., the join requests management screen).
  FirebaseFirestore get firestore => _firestore;

  /// Returns a real-time stream of all communities, ordered by creation date (newest first).
  ///
  /// Each Firestore snapshot is mapped to a list of [Community] model objects.
  Stream<List<Community>> watchCommunities() {
    return _communities.orderBy('createdAt', descending: true).snapshots().map((snap) {
      return snap.docs.map((d) => Community.fromMap(d.id, d.data() as Map<String,dynamic>)).toList();
    });
  }

  /// Creates a new community document in Firestore and logs the activity.
  ///
  /// The [ownerId] is automatically added as the first member of the community.
  /// Throws an [Exception] if [ownerId] is empty.
  ///
  /// Returns the newly created [Community] object.
  Future<Community> createCommunity({
    required String name,
    required String description,
    required String ownerId,
  }) async {
    if (ownerId.isEmpty) {
      throw Exception('Owner ID cannot be empty');
    }
    
    final docRef = _communities.doc();
    final now = DateTime.now();
    final communityData = {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'members': [ownerId], // Owner is automatically a member
      'joinRequests': <String>[], // Explicitly initialise as empty list
      'createdAt': Timestamp.fromDate(now),
    };
    
    await docRef.set(communityData);
    
    // Log this action to the user's activity feed
    await _activityLogRepository.logActivity(
      title: 'Created Community: "$name"',
      description: 'You created a new community.',
      type: ActivityType.community,
      relatedId: docRef.id,
    );
    
    return Community(
      id: docRef.id,
      name: name,
      description: description,
      ownerId: ownerId,
      members: [ownerId],
      joinRequests: [],
      createdAt: now,
    );
  }

  /// Returns a real-time stream of a single community document by [communityId].
  ///
  /// Emits null if the document does not exist.
  Stream<Community?> watchCommunity(String communityId) {
    return _communities.doc(communityId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return Community.fromMap(snap.id, snap.data() as Map<String,dynamic>);
    });
  }

  /// Submits a join request for [userId] to the community identified by [communityId].
  ///
  /// Steps:
  /// 1. Checks that the community exists and the user is not already a member.
  /// 2. Creates a `joinRequests/{userId}` sub-document as a pending request.
  /// 3. Sends a notification to the community owner.
  ///
  /// Throws if the community is not found. Rethrows any other Firestore errors.
  Future<void> requestJoin(String communityId, String userId) async {
    print('Repo: requestJoin called for community: $communityId, user: $userId');
    final communityRef = _communities.doc(communityId);
    final requestRef = communityRef.collection('joinRequests').doc(userId);

    try {
      // Step 1: Verify the community exists and check current members
      final snapshot = await communityRef.get();
      if (!snapshot.exists) {
        throw Exception('Community not found');
      }
      
      final data = snapshot.data() as Map<String,dynamic>;
      final members = List<String>.from(data['members'] ?? []);
      final ownerId = data['ownerId'] as String?;
      final communityName = data['name'] as String?;

      if (members.contains(userId)) {
        print('Repo: User already a member');
        return; // Silently skip if already a member
      }

      // Step 2: Create the join request sub-document
      print('Repo: Creating join request document');
      await requestRef.set({
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('Repo: Request created successfully');

      // Step 3: Notify the community owner of the new request
      if (ownerId != null && communityName != null) {
        await _notificationRepository.sendNotification(
          recipientId: ownerId,
          title: 'New Join Request',
          body: 'Someone requested to join "$communityName"',
          type: NotificationType.joinRequest,
          relatedId: communityId,
        );
      }

    } catch (e) {
      print('Repo: Error in requestJoin: $e');
      rethrow;
    }
  }

  /// Approves a user's pending join request using an atomic Firestore transaction.
  ///
  /// In a single transaction:
  /// - Adds [userId] to the community's `members` array.
  /// - Deletes the corresponding `joinRequests/{userId}` sub-document.
  ///
  /// After the transaction, sends an approval notification to the user.
  Future<void> approveJoin(String communityId, String userId) async {
    final communityRef = _communities.doc(communityId);
    final requestRef = communityRef.collection('joinRequests').doc(userId);

    String? communityName;

    // Use a transaction to ensure the member add and request delete are atomic
    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(communityRef);
      if (!snapshot.exists) throw Exception('Community not found');
      
      final data = snapshot.data() as Map<String,dynamic>;
      final members = List<String>.from(data['members'] ?? []);
      communityName = data['name'];
      
      // Only add the user if they aren't already a member (idempotency guard)
      if (!members.contains(userId)) {
        members.add(userId);
        tx.update(communityRef, {'members': members});
      }
      
      // Remove the pending join request document
      tx.delete(requestRef);
    });

    // Notify the user their request was accepted (after the transaction)
    if (communityName != null) {
      await _notificationRepository.sendNotification(
        recipientId: userId,
        title: 'Request Accepted',
        body: 'Your request to join "$communityName" was accepted.',
        type: NotificationType.requestAccepted,
        relatedId: communityId,
      );
      
      // Note: We can't easily log activity for the *user* here because this runs as admin/owner.
      // Consider adding a log entry for the owner ("You accepted a request") if needed.
    }
  }

  /// Rejects and deletes a pending join request sub-document.
  ///
  /// After rejection, no notification is sent to the requesting user
  /// (by design — silent rejection).
  Future<void> rejectJoin(String communityId, String userId) async {
    final requestRef = _communities.doc(communityId).collection('joinRequests').doc(userId);
    await requestRef.delete();
  }

  /// Removes [userId] from the community's `members` array.
  ///
  /// Uses [FieldValue.arrayRemove] so the operation is safe to call even if
  /// the user is not in the array. Also logs the action to the activity feed.
  Future<void> leaveCommunity(String communityId, String userId) async {
    final docRef = _communities.doc(communityId);
    await docRef.update({
      'members': FieldValue.arrayRemove([userId])
    });
    
    // Log the leave action to the user's activity feed
    await _activityLogRepository.logActivity(
      title: 'Left Community',
      description: 'You left a community.',
      type: ActivityType.community,
      relatedId: communityId,
    );
  }
}
