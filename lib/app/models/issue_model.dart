import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for a community issue report (a problem reported within a community).
///
/// Issues are similar to complaints but are community-scoped and support
/// a democratic voting mechanism. When enough votes are accumulated, an issue
/// can be **escalated** to municipal authorities.
///
/// Stored in the `issues` Firestore collection.
///
/// Status lifecycle:
///   pending → escalated → resolved
class Issue {
  /// Firestore document ID for this issue.
  final String id;

  /// Firestore ID of the community this issue belongs to.
  final String communityId;

  /// Firebase UID of the user who submitted the issue.
  final String userId;

  /// A short descriptive title for the issue.
  final String title;

  /// A detailed description of the problem.
  final String description;

  /// Cloudinary secure URLs for photos of the issue.
  final List<String> imageUrls;

  /// Category of the issue (e.g., 'Roads', 'Sanitation').
  /// May be overridden by the ML analysis result.
  final String category;

  /// List of Firebase UIDs of users who have upvoted this issue.
  /// Use [voteCount] to get the total and [hasUserVoted] to check a specific user.
  final List<String> votes;

  /// Current status of the issue. Possible values: 'pending', 'escalated', 'resolved'.
  final String status;

  /// An optional note added when the issue is escalated or resolved.
  final String? escalationNote;

  /// Structured result from the ML API analysis. May be null for manually categorised issues.
  final IssueAiAnalysis? aiAnalysis;

  /// Optional GPS coordinates for the issue location as a Firestore [GeoPoint].
  final GeoPoint? location;

  /// Optional human-readable address string for the issue location.
  final String? address;

  /// Firestore-compatible creation timestamp.
  final Timestamp createdAt;

  /// Firestore-compatible last-updated timestamp.
  final Timestamp updatedAt;

  /// List of status change events.
  final List<StatusHistoryEntry> statusHistory;

  Issue({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.category,
    required this.votes,
    required this.status,
    this.escalationNote,
    this.aiAnalysis,
    this.location,
    this.address,
    this.statusHistory = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convenience getter: returns the total number of upvotes on this issue.
  int get voteCount => votes.length;

  /// Returns true if the user with [userId] has voted on this issue.
  bool hasUserVoted(String userId) => votes.contains(userId);

  /// Creates an [Issue] from a Firestore document.
  ///
  /// [map] is the raw `data()` from the snapshot. [docId] is the document ID.
  ///
  /// Defensively parses [imageUrls] and [votes] to handle nulls or mixed-type lists.
  /// Falls back to the ML-suggested category if the stored category is empty.
  factory Issue.fromMap(Map<String, dynamic> map, String docId) {
    final aiAnalysisMap = map['aiAnalysis'] as Map<String, dynamic>?;
    final aiAnalysis = IssueAiAnalysis.maybeFromMap(aiAnalysisMap);
    
    // Parse image URLs safely — filter to strings only
    final rawImageUrls = map['imageUrls'];
    final parsedImages = rawImageUrls is List
        ? rawImageUrls.whereType<String>().toList()
        : <String>[];

    // Parse status history
    final rawHistory = map['statusHistory'] as List?;
    final statusHistory = rawHistory != null
        ? rawHistory
            .map((e) => StatusHistoryEntry.fromMap(e as Map<String, dynamic>))
            .toList()
        : <StatusHistoryEntry>[];

    // Parse votes safely — must be a list of user UID strings
    final rawVotes = map['votes'];
    final parsedVotes = rawVotes is List
        ? rawVotes.whereType<String>().toList()
        : <String>[];

    return Issue(
      id: docId,
      communityId: map['communityId'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrls: parsedImages,
      // Use AI-suggested category if available; otherwise fall back to stored/provided category
      category: map['category'] ?? (aiAnalysis?.category ?? ''),
      votes: parsedVotes,
      status: map['status'] ?? 'pending',
      escalationNote: map['escalationNote'],
      aiAnalysis: aiAnalysis,
      location: map['location'] as GeoPoint?,
      address: map['address'] as String?,
      statusHistory: statusHistory,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  /// Serialises this [Issue] to a Firestore-compatible map.
  ///
  /// Optional fields ([escalationNote], [aiAnalysis], [location], [address])
  /// are only included in the map if they are non-null.
  Map<String, dynamic> toMap() {
    return {
      'communityId': communityId,
      'userId': userId,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'category': category,
      'votes': votes,
      'status': status,
      if (escalationNote != null) 'escalationNote': escalationNote,
      if (aiAnalysis != null) 'aiAnalysis': aiAnalysis!.toMap(),
      if (location != null) 'location': location,
      if (address != null) 'address': address,
      'statusHistory': statusHistory.map((e) => e.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Creates a modified copy of this issue with selective field overrides.
  ///
  /// [id], [communityId], [userId], [aiAnalysis], and [createdAt] are immutable
  /// and not overridable via [copyWith].
  Issue copyWith({
    String? title,
    String? description,
    List<String>? imageUrls,
    String? category,
    List<String>? votes,
    String? status,
    String? escalationNote,
    GeoPoint? location,
    String? address,
    List<StatusHistoryEntry>? statusHistory,
    Timestamp? updatedAt,
  }) {
    return Issue(
      id: id,
      communityId: communityId,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      votes: votes ?? this.votes,
      status: status ?? this.status,
      escalationNote: escalationNote ?? this.escalationNote,
      location: location ?? this.location,
      address: address ?? this.address,
      statusHistory: statusHistory ?? this.statusHistory,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Structured result of the ML API analysis for a community issue's image.
///
/// Similar to [ComplaintAiAnalysis] but tailored to the fields returned
/// for community issues. Primarily used to auto-set the [Issue.category].
class IssueAiAnalysis {
  /// Whether the AI classified the image as a genuine civic issue.
  final bool isIssue;

  /// The full AI analysis payload. Stored as an unmodifiable map.
  final Map<String, dynamic> data;

  IssueAiAnalysis({
    required this.isIssue,
    required Map<String, dynamic> data,
  }) : data = Map<String, dynamic>.unmodifiable(
          Map<String, dynamic>.from(data),
        );

  /// AI-suggested category for the issue (e.g., 'Roads', 'Sanitation').
  String? get category => data['category'] as String?;

  /// AI-suggested priority level.
  String? get priority => data['priority'] as String?;

  /// AI-generated plain-text description of what was seen in the image.
  String? get description => data['description'] as String?;

  /// Specific issue sub-type identified by the AI (e.g., 'pothole').
  String? get issueType => data['issue_type'] as String?;

  /// Confidence rating for the AI's analysis ('high', 'medium', 'low').
  String? get confidenceLevel => data['confidence_level'] as String?;

  /// Uppercased confidence label for display. Falls back to 'UNKNOWN'.
  String get confidenceLabel =>
      confidenceLevel?.toUpperCase() ?? 'UNKNOWN';

  /// Serialises this [IssueAiAnalysis] to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'is_issue': isIssue,
      'data': Map<String, dynamic>.from(data),
    };
  }

  /// Creates an [IssueAiAnalysis] from a Firestore nested map.
  ///
  /// Returns null if [map] is null (e.g., for issues without AI analysis).
  static IssueAiAnalysis? maybeFromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    final rawData = map['data'];
    return IssueAiAnalysis(
      isIssue: map['is_issue'] as bool? ?? true,
      data: rawData is Map<String, dynamic>
          ? Map<String, dynamic>.from(rawData)
          : <String, dynamic>{},
    );
  }
}

/// Represents a single status change event in the history of a complaint or issue.
class StatusHistoryEntry {
  /// The status value at this point in time.
  final String status;

  /// When this status was reached.
  final Timestamp timestamp;

  StatusHistoryEntry({
    required this.status,
    required this.timestamp,
  });

  /// Creates a [StatusHistoryEntry] from a Firestore map.
  factory StatusHistoryEntry.fromMap(Map<String, dynamic> map) {
    return StatusHistoryEntry(
      status: map['status'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  /// Serialises this entry to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'timestamp': timestamp,
    };
  }
}
