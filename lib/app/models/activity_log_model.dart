import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType {
  complaint,
  community,
  vote,
  reward,
  comment,
  other
}

class ActivityLog {
  final String id;
  final String userId;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime createdAt;
  final String? relatedId;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.relatedId,
  });

  factory ActivityLog.fromMap(Map<String, dynamic> map, String id) {
    return ActivityLog(
      id: id,
      userId: map['userId'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ActivityType.other,
      ),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      relatedId: map['relatedId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'relatedId': relatedId,
    };
  }
}
