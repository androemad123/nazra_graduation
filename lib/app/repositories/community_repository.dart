import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_log_model.dart';
import '../models/community.dart';
import '../models/notification_model.dart';
import 'activity_log_repository.dart';
import 'notification_repository.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore;
  final NotificationRepository _notificationRepository;
  final ActivityLogRepository _activityLogRepository;

  CommunityRepository({
    FirebaseFirestore? firestore,
    NotificationRepository? notificationRepository,
    ActivityLogRepository? activityLogRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _notificationRepository = notificationRepository ?? NotificationRepository(),
        _activityLogRepository = activityLogRepository ?? ActivityLogRepository();

  CollectionReference get _communities => _firestore.collection('communities');
  
  // Expose firestore for join requests screen
  FirebaseFirestore get firestore => _firestore;

  // stream list of communities (simple public query)
  Stream<List<Community>> watchCommunities() {
    return _communities.orderBy('createdAt', descending: true).snapshots().map((snap) {
      return snap.docs.map((d) => Community.fromMap(d.id, d.data() as Map<String,dynamic>)).toList();
    });
  }

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
      'joinRequests': <String>[], // Explicitly initialize as empty list
      'createdAt': Timestamp.fromDate(now),
    };
    
    await docRef.set(communityData);
    
    // Log activity
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

  Stream<Community?> watchCommunity(String communityId) {
    return _communities.doc(communityId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return Community.fromMap(snap.id, snap.data() as Map<String,dynamic>);
    });
  }

  Future<void> requestJoin(String communityId, String userId) async {
    print('Repo: requestJoin called for community: $communityId, user: $userId');
    final communityRef = _communities.doc(communityId);
    final requestRef = communityRef.collection('joinRequests').doc(userId);

    try {
      // 1. Check if community exists and get members
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
        return; 
      }

      // 2. Create join request
      print('Repo: Creating join request document');
      await requestRef.set({
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('Repo: Request created successfully');

      // Send notification to owner
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

  Future<void> approveJoin(String communityId, String userId) async {
    final communityRef = _communities.doc(communityId);
    final requestRef = communityRef.collection('joinRequests').doc(userId);

    String? communityName;

    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(communityRef);
      if (!snapshot.exists) throw Exception('Community not found');
      
      final data = snapshot.data() as Map<String,dynamic>;
      final members = List<String>.from(data['members'] ?? []);
      communityName = data['name'];
      
      if (!members.contains(userId)) {
        members.add(userId);
        tx.update(communityRef, {'members': members});
      }
      
      tx.delete(requestRef);
    });

    // Send notification to user
    if (communityName != null) {
      await _notificationRepository.sendNotification(
        recipientId: userId,
        title: 'Request Accepted',
        body: 'Your request to join "$communityName" was accepted.',
        type: NotificationType.requestAccepted,
        relatedId: communityId,
      );
      
      // Note: We can't easily log activity for the *user* here because this runs as admin/owner
      // But we could log it for the owner saying "You accepted a request"
    }
  }

  Future<void> rejectJoin(String communityId, String userId) async {
    final requestRef = _communities.doc(communityId).collection('joinRequests').doc(userId);
    await requestRef.delete();
  }

  Future<void> leaveCommunity(String communityId, String userId) async {
    final docRef = _communities.doc(communityId);
    await docRef.update({
      'members': FieldValue.arrayRemove([userId])
    });
    
    // Log activity
    await _activityLogRepository.logActivity(
      title: 'Left Community',
      description: 'You left a community.',
      type: ActivityType.community,
      relatedId: communityId,
    );
  }
}
