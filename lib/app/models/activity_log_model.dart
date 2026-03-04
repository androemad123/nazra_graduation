import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing the different types of user activities tracked in the app.
///
/// These types are stored as strings in Firestore (via `type.name`) and
/// are used to filter the activity log by category in [ActivityLogBloc].
///
/// - [complaint] : The user filed a complaint.
/// - [community] : The user created or left a community.
/// - [vote]      : The user upvoted a community issue.
/// - [reward]    : The user earned a reward or achievement.
/// - [comment]   : The user commented on something (reserved for future use).
/// - [other]     : Any activity that does not match a known type.
enum ActivityType {
  complaint,
  community,
  vote,
  reward,
  comment,
  other
}

/// Data model representing a single entry in a user's activity log.
///
/// Activity logs are stored in the `activity_logs` Firestore collection and
/// are created automatically by repositories whenever a user performs a
/// significant action (filing a complaint, joining a community, etc.).
class ActivityLog {
  /// Firestore document ID for this activity entry.
  final String id;

  /// Firebase UID of the user who performed the activity.
  final String userId;

  /// The category/type of the activity (e.g., complaint, vote).
  final ActivityType type;

  /// A short human-readable title for the activity (e.g., "Complaint filed: 'Pothole'").
  final String title;

  /// A more detailed description of what the activity involved.
  final String description;

  /// Timestamp when this activity was recorded.
  final DateTime createdAt;

  /// Optional ID of the related entity (issue ID, community ID, etc.)
  /// that this activity refers to. Used for deep-linking in the UI.
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

  /// Creates an [ActivityLog] from a Firestore document map.
  ///
  /// [map] is the raw `data()` from the Firestore snapshot.
  /// [id] is the Firestore document ID.
  ///
  /// The [type] field is resolved by name — unknown values fall back to [ActivityType.other].
  /// [createdAt] falls back to [DateTime.now()] if the Firestore timestamp is absent.
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

  /// Serialises this [ActivityLog] to a Firestore-compatible map.
  ///
  /// The [type] is stored as its string name (e.g., 'complaint').
  /// [createdAt] is stored as a [Timestamp] for Firestore compatibility.
  /// Note: [id] is NOT included because Firestore uses the document ID separately.
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
