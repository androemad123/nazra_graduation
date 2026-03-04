import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing a citizen complaint submitted to the platform.
///
/// Complaints are stored in the `complaints` Firestore collection.
/// Each complaint goes through an AI analysis pipeline (ML API + Cloudinary)
/// before being stored, which determines its [status] and [priority].
///
/// Status lifecycle:
///   pending → in_progress → resolved
///   pending → not_issue (if the AI determines the photo is not a valid issue)
///
/// Priority values: 'emergency', 'high', 'medium', 'low' (set by AI or default 'medium')
class Complaint {
  /// Firestore document ID for this complaint (also stored in the `id` field).
  final String id;

  /// Firebase UID of the user who submitted the complaint.
  final String userId;

  /// List of Cloudinary secure URLs for images attached to the complaint.
  final List<String> imageUrls;

  /// Category label for the type of problem (e.g., 'Garbage & Waste', 'Road Damage').
  final String category;

  /// User-provided description of the issue.
  final String description;

  /// Geographic coordinates of the reported issue stored as a Firestore [GeoPoint].
  final GeoPoint location;

  /// Human-readable address string resolved via reverse geocoding.
  final String address;

  /// Current processing status of the complaint.
  /// Possible values: 'pending', 'in_progress', 'resolved', 'not_issue'.
  final String status;

  /// AI-derived priority level.
  /// Possible values: 'emergency', 'high', 'medium', 'low'.
  final String priority;

  /// Firebase UID of the officer assigned to handle this complaint (if any).
  final String? assignedOfficerId;

  /// Firestore ID of the community this complaint is associated with (if any).
  final String? communityId;

  /// Structured result of the ML API image analysis. May be null for legacy records.
  final ComplaintAiAnalysis? aiAnalysis;

  /// Optional note added when the complaint is resolved.
  final String? resolutionNote;

  /// Number of "likes"/upvotes received from other users. Defaults to 0.
  final int likes;

  /// Firestore-compatible creation timestamp.
  final Timestamp createdAt;

  /// Firestore-compatible last-updated timestamp.
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

  /// Creates a [Complaint] from a Firestore document.
  ///
  /// [map] is the raw `data()` from the snapshot. [docId] is the Firestore document ID.
  ///
  /// Handles legacy documents that stored a single `imageUrl` field instead of `imageUrls`.
  /// Parses the nested `aiAnalysis` map via [ComplaintAiAnalysis.maybeFromMap].
  /// Falls back gracefully for missing fields using safe defaults.
  factory Complaint.fromMap(Map<String, dynamic> map, String docId) {
    final aiAnalysisMap = map['aiAnalysis'] as Map<String, dynamic>?;
    final aiAnalysis = ComplaintAiAnalysis.maybeFromMap(aiAnalysisMap);

    // Parse image URLs — handles both array and legacy single-URL formats
    final rawImageUrls = map['imageUrls'];
    final parsedImages = rawImageUrls is List
        ? rawImageUrls.whereType<String>().toList()
        : <String>[];

    // Backward compatibility: if imageUrls is empty, check for legacy imageUrl field
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

  /// Serialises this [Complaint] to a Firestore-compatible map.
  ///
  /// [aiAnalysis] is only included if non-null.
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

  /// Safely parses a location value that may be a native [GeoPoint]
  /// or a plain map `{latitude, longitude}` (e.g., from older schema versions).
  ///
  /// Returns `GeoPoint(0, 0)` as a safe default if the value is unrecognised.
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

  /// 🧩 Dummy data for UI testing and development.
  ///
  /// Provides three sample complaints covering garbage, road damage, and vegetation issues.
  /// Used to preview UI components without a live Firestore connection.
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

/// Structured result of the ML API analysis for a complaint's submitted image.
///
/// Wraps the raw JSON response from the backend in a typed Dart class,
/// exposing individual fields as computed getters.
///
/// The underlying [data] map is made unmodifiable at construction time
/// to prevent accidental mutation.
class ComplaintAiAnalysis {
  /// Whether the AI classified the submitted image as a genuine civic issue.
  /// If false, the complaint status is set to 'not_issue'.
  final bool isIssue;

  /// The full AI analysis payload from the ML backend. Stored as an unmodifiable map.
  final Map<String, dynamic> data;

  ComplaintAiAnalysis({
    required this.isIssue,
    required Map<String, dynamic> data,
  }) : data = Map<String, dynamic>.unmodifiable(
          Map<String, dynamic>.from(data),
        );

  /// Explanation from the AI of why this is (or isn't) considered a valid issue.
  String? get reason => data['reason'] as String?;

  /// AI-generated plain-text description of what was detected in the image.
  String? get description => data['description'] as String?;

  /// AI-suggested priority level ('emergency', 'high', 'medium', 'low').
  String? get priority => data['priority'] as String?;

  /// Specific issue sub-type identified by the AI (e.g., 'garbage_overflow').
  String? get issueType => data['issue_type'] as String?;

  /// The government sector responsible for handling this type of issue.
  String? get responsibleSector => data['responsible_sector'] as String?;

  /// AI's confidence rating for its analysis ('high', 'medium', 'low').
  String? get confidenceLevel => data['confidence_level'] as String?;

  /// Whether the AI flagged this as requiring immediate intervention.
  bool? get immediateActionRequired =>
      data['immediate_action_required'] as bool?;

  /// Whether the AI identified a safety hazard in the image.
  bool? get safetyHazard => data['safety_hazard'] as bool?;

  /// Observable location details visible in the image (e.g., 'Near a school').
  String? get visibleLocationDetails =>
      data['visible_location_details'] as String?;

  /// AI estimate of how complex the repair will be (e.g., 'simple', 'complex').
  String? get repairComplexity => data['repair_complexity'] as String?;

  /// Uppercased [confidenceLevel] for display (e.g., 'HIGH'). Falls back to 'UNKNOWN'.
  String get confidenceLabel =>
      confidenceLevel?.toUpperCase() ?? 'UNKNOWN';

  /// Serialises this [ComplaintAiAnalysis] to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'is_issue': isIssue,
      'data': Map<String, dynamic>.from(data),
    };
  }

  /// Creates a [ComplaintAiAnalysis] from a Firestore nested map.
  ///
  /// Returns null if [map] itself is null (e.g., for older complaints without AI analysis).
  /// Handles cases where the `data` field is missing or not a map.
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
