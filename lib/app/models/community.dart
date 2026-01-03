import 'package:cloud_firestore/cloud_firestore.dart';

class Community {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final List<String> members;
  final List<String> joinRequests;
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

  factory Community.fromMap(String id, Map<String,dynamic> map) {
    // Ensure members and joinRequests are never null
    final rawMembers = map['members'];
    final members = rawMembers is List
        ? rawMembers.whereType<String>().toList()
        : <String>[];
    
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

  Map<String,dynamic> toMap() => {
    'name': name,
    'description': description,
    'ownerId': ownerId,
    'members': members,
    'joinRequests': joinRequests,
    'createdAt': Timestamp.fromDate(createdAt),
  };

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
