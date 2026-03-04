import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing a user-created community (neighbourhood/district group).
///
/// Communities are stored in the `communities` Firestore collection.
/// Each community has an owner, a list of member UIDs, and a list of pending join requests.
///
/// Member access is controlled by the owner, who must approve join requests before
/// a user is added to [members].
class Community {
  /// Firestore document ID for this community.
  final String id;

  /// Display name of the community (e.g., "Nasr City Residents").
  final String name;

  /// A short description of the community's purpose or area.
  final String description;

  /// Firebase UID of the user who created and administrates this community.
  final String ownerId;

  /// List of Firebase UIDs of all accepted members.
  /// Always includes [ownerId] (added automatically on creation).
  final List<String> members;

  /// List of Firebase UIDs of users who have requested to join but not yet been approved.
  final List<String> joinRequests;

  /// Timestamp when the community was created.
  final DateTime createdAt;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.members,
    required this.joinRequests,
    required this.createdAt,
  });

  /// Creates a [Community] from a Firestore document.
  ///
  /// [id] is the Firestore document ID.
  /// [map] is the raw `data()` from the snapshot.
  ///
  /// Defensively handles cases where [members] or [joinRequests] might be null or
  /// contain non-string items (e.g., stale data from schema migrations).
  factory Community.fromMap(String id, Map<String,dynamic> map) {
    // Safely parse members — filter to strings only in case of mixed-type lists
    final rawMembers = map['members'];
    final members = rawMembers is List
        ? rawMembers.whereType<String>().toList()
        : <String>[];
    
    // Safely parse join requests — same defensive approach
    final rawJoinRequests = map['joinRequests'];
    final joinRequests = rawJoinRequests is List
        ? rawJoinRequests.whereType<String>().toList()
        : <String>[];
    
    return Community(
      id: id,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      ownerId: map['ownerId']?.toString() ?? '',
      members: members,
      joinRequests: joinRequests,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Serialises this [Community] to a Firestore-compatible map.
  ///
  /// Note: [id] is NOT included because Firestore uses the document ID separately.
  Map<String,dynamic> toMap() => {
    'name': name,
    'description': description,
    'ownerId': ownerId,
    'members': members,
    'joinRequests': joinRequests,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  /// Creates a modified copy of this community with selective field overrides.
  ///
  /// [id], [ownerId], and [createdAt] are immutable and cannot be changed via [copyWith].
  Community copyWith({
    String? name,
    String? description,
    List<String>? members,
    List<String>? joinRequests,
  }) {
    return Community(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId,
      members: members ?? this.members,
      joinRequests: joinRequests ?? this.joinRequests,
      createdAt: createdAt,
    );
  }
}
