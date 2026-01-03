import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String id;
  final String userId;
  final List<String> imageUrls;
  final String category;
  final String description;
  final GeoPoint location;
  final String address;
  final String status; // pending, in_progress, resolved, not_issue
  final String priority; // emergency, high, medium, low
  final String? assignedOfficerId;
  final String? communityId;
  final ComplaintAiAnalysis? aiAnalysis;
  final String? resolutionNote;
  final int likes;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Complaint({
    required this.id,
    required this.userId,
    required this.imageUrls,
    required this.category,
    required this.description,
    required this.location,
    required this.address,
    required this.status,
    required this.priority,
    this.assignedOfficerId,
    this.communityId,
    this.aiAnalysis,
    this.resolutionNote,
    this.likes = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Complaint.fromMap(Map<String, dynamic> map, String docId) {
    final aiAnalysisMap = map['aiAnalysis'] as Map<String, dynamic>?;
    final aiAnalysis = ComplaintAiAnalysis.maybeFromMap(aiAnalysisMap);
    final rawImageUrls = map['imageUrls'];
    final parsedImages = rawImageUrls is List
        ? rawImageUrls.whereType<String>().toList()
        : <String>[];

    final fallbackImage = map['imageUrl'];
    if (parsedImages.isEmpty && fallbackImage is String) {
      parsedImages.add(fallbackImage);
    }

    return Complaint(
      id: map['id'] ?? docId, // Prefer stored ID, fallback to docId for backward compatibility
      userId: map['userId'] ?? '',
      imageUrls: parsedImages,
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      location: _parseLocation(map['location']),
      address: map['address'] ?? '',
      status: map['status'] ??
          (aiAnalysis?.isIssue ?? true ? 'pending' : 'not_issue'),
      priority:
          (map['priority'] ?? aiAnalysis?.priority ?? 'medium').toString(),
      assignedOfficerId: map['assignedOfficerId'],
      communityId: map['communityId'],
      aiAnalysis: aiAnalysis,
      resolutionNote: map['resolutionNote'],
      likes: map['likes'] ?? 0,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'imageUrls': imageUrls,
      'category': category,
      'description': description,
      'location': location,
      'address': address,
      'status': status,
      'priority': priority,
      'assignedOfficerId': assignedOfficerId,
      'communityId': communityId,
      if (aiAnalysis != null) 'aiAnalysis': aiAnalysis!.toMap(),
      'resolutionNote': resolutionNote,
      'likes': likes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static GeoPoint _parseLocation(dynamic rawLocation) {
    if (rawLocation is GeoPoint) return rawLocation;
    if (rawLocation is Map<String, dynamic>) {
      final latValue = rawLocation['latitude'];
      final lngValue = rawLocation['longitude'];
      final latitude = latValue is num ? latValue.toDouble() : 0.0;
      final longitude = lngValue is num ? lngValue.toDouble() : 0.0;
      return GeoPoint(latitude, longitude);
    }
    return const GeoPoint(0, 0);
  }

  /// 🧩 Dummy data for UI testing
  static List<Complaint> dummyData = [
    Complaint(
      id: '1',
      userId: 'user_001',
      imageUrls: const [
        'https://images.unsplash.com/photo-1581092334444-3a86b0b5a3b7?w=800'
      ],
      category: 'Garbage & Waste',
      description: 'Overflowing trash bins near the market area.',
      location: const GeoPoint(30.0444, 31.2357),
      address: 'Tahrir Square, Cairo',
      status: 'pending',
      priority: 'high',
      assignedOfficerId: 'officer_001',
      communityId: 'community_001',
      aiAnalysis: ComplaintAiAnalysis(
        isIssue: true,
        data: const <String, dynamic>{
          'description': 'Trash bins overflowing, needs urgent cleanup.',
          'priority': 'high',
          'issue_type': 'garbage_overflow',
          'confidence_level': 'high',
        },
      ),
      resolutionNote: null,
      likes: 12,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    ),
    Complaint(
      id: '2',
      userId: 'user_002',
      imageUrls: const [
        'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800'
      ],
      category: 'Road & Sidewalk Damage',
      description: 'Large pothole near the school entrance.',
      location: const GeoPoint(30.0595, 31.2234),
      address: 'Nasr City, Street 10',
      status: 'in_progress',
      priority: 'medium',
      assignedOfficerId: 'officer_002',
      communityId: 'community_002',
      aiAnalysis: ComplaintAiAnalysis(
        isIssue: true,
        data: const <String, dynamic>{
          'description': 'Pothole causing traffic disruption.',
          'priority': 'medium',
          'issue_type': 'road_damage',
          'confidence_level': 'medium',
        },
      ),
      resolutionNote: 'Repair scheduled for tomorrow.',
      likes: 9,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    ),
    Complaint(
      id: '3',
      userId: 'user_003',
      imageUrls: const [
        'https://images.unsplash.com/photo-1604328698692-f76ea9498e76?w=800'
      ],
      category: 'Trees & Vegetation',
      description: 'Fallen tree blocking part of the sidewalk.',
      location: const GeoPoint(30.0611, 31.2184),
      address: 'Heliopolis, Abu Bakr St.',
      status: 'resolved',
      priority: 'high',
      assignedOfficerId: 'officer_003',
      communityId: 'community_003',
      aiAnalysis: ComplaintAiAnalysis(
        isIssue: true,
        data: const <String, dynamic>{
          'description': 'Tree obstructing pedestrian path.',
          'priority': 'high',
          'issue_type': 'vegetation',
          'confidence_level': 'high',
        },
      ),
      resolutionNote: 'Tree removed by the cleanup team.',
      likes: 20,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    ),
  ];
}

class ComplaintAiAnalysis {
  final bool isIssue;
  final Map<String, dynamic> data;

  ComplaintAiAnalysis({
    required this.isIssue,
    required Map<String, dynamic> data,
  }) : data = Map<String, dynamic>.unmodifiable(
          Map<String, dynamic>.from(data),
        );

  String? get reason => data['reason'] as String?;
  String? get description => data['description'] as String?;
  String? get priority => data['priority'] as String?;
  String? get issueType => data['issue_type'] as String?;
  String? get responsibleSector => data['responsible_sector'] as String?;
  String? get confidenceLevel => data['confidence_level'] as String?;
  bool? get immediateActionRequired =>
      data['immediate_action_required'] as bool?;
  bool? get safetyHazard => data['safety_hazard'] as bool?;
  String? get visibleLocationDetails =>
      data['visible_location_details'] as String?;
  String? get repairComplexity => data['repair_complexity'] as String?;

  String get confidenceLabel =>
      confidenceLevel?.toUpperCase() ?? 'UNKNOWN';

  Map<String, dynamic> toMap() {
    return {
      'is_issue': isIssue,
      'data': Map<String, dynamic>.from(data),
    };
  }

  static ComplaintAiAnalysis? maybeFromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    final rawData = map['data'];
    return ComplaintAiAnalysis(
      isIssue: map['is_issue'] as bool? ?? true,
      data: rawData is Map<String, dynamic>
          ? Map<String, dynamic>.from(rawData)
          : <String, dynamic>{},
    );
  }
}
