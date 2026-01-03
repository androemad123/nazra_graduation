import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for community issues
/// Issues are simpler than complaints - focused on community voting and escalation
class Issue {
  final String id;
  final String communityId;
  final String userId;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String category;
  final List<String> votes; // List of user IDs who voted
  final String status; // pending, escalated, resolved
  final String? escalationNote;
  final IssueAiAnalysis? aiAnalysis;
  final GeoPoint? location;
  final String? address;
  final Timestamp createdAt;
  final Timestamp updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
  });

  int get voteCount => votes.length;

  bool hasUserVoted(String userId) => votes.contains(userId);

  factory Issue.fromMap(Map<String, dynamic> map, String docId) {
    final aiAnalysisMap = map['aiAnalysis'] as Map<String, dynamic>?;
    final aiAnalysis = IssueAiAnalysis.maybeFromMap(aiAnalysisMap);
    
    final rawImageUrls = map['imageUrls'];
    final parsedImages = rawImageUrls is List
        ? rawImageUrls.whereType<String>().toList()
        : <String>[];

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
      category: map['category'] ?? (aiAnalysis?.category ?? ''),
      votes: parsedVotes,
      status: map['status'] ?? 'pending',
      escalationNote: map['escalationNote'],
      aiAnalysis: aiAnalysis,
      location: map['location'] as GeoPoint?,
      address: map['address'] as String?,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

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
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class IssueAiAnalysis {
  final bool isIssue;
  final Map<String, dynamic> data;

  IssueAiAnalysis({
    required this.isIssue,
    required Map<String, dynamic> data,
  }) : data = Map<String, dynamic>.unmodifiable(
          Map<String, dynamic>.from(data),
        );

  String? get category => data['category'] as String?;
  String? get priority => data['priority'] as String?;
  String? get description => data['description'] as String?;
  String? get issueType => data['issue_type'] as String?;
  String? get confidenceLevel => data['confidence_level'] as String?;

  String get confidenceLabel =>
      confidenceLevel?.toUpperCase() ?? 'UNKNOWN';

  Map<String, dynamic> toMap() {
    return {
      'is_issue': isIssue,
      'data': Map<String, dynamic>.from(data),
    };
  }

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

