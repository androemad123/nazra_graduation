import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class DuplicateComplaintMatch {
  final String complaintId;
  final String? clusterId;
  final double score;
  final double distanceMeters;
  final DateTime createdAt;
  final String issueType;

  DuplicateComplaintMatch({
    required this.complaintId,
    required this.clusterId,
    required this.score,
    required this.distanceMeters,
    required this.createdAt,
    required this.issueType,
  });
}

/// Repository for managing citizen complaints in Firestore.
///
/// Handles all CRUD operations for the `complaints` Firestore collection.
/// Also performs ML analysis payload normalisation before writing to Firestore.
///
/// Collaborates with:
/// - [CloudinaryService]: URLs are passed in after the upload is done elsewhere.
/// - [MlApiService]: The normalised ML payload is passed in from the calling layer.
class ComplaintRepository {
  /// Firestore instance — singleton, not injectable here for simplicity.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firebase Auth instance — used to identify and authenticate the current user.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Submits a new complaint to the `complaints` Firestore collection.
  ///
  /// Normalises the ML payload, derives status and priority from it,
  /// and writes the full document to Firestore.
  ///
  /// [imageUrls]       — Cloudinary URLs of the complaint's images.
  /// [description]     — User-written description of the issue.
  /// [category]        — Issue category (e.g., 'Garbage & Waste').
  /// [location]        — GPS [Position] from the device sensor.
  /// [address]         — Human-readable address resolved from the location.
  /// [mlAnalysisResult]— Optional ML result; affects status ('not_issue') and priority.
  ///
  /// Returns the Firestore document ID of the newly created complaint, or null on failure.
  Future<String?> addComplaint({
    required List<String> imageUrls,
    required String description,
    required String category,
    required Position location,
    required String address,
    Map<String, dynamic>? mlAnalysisResult,
    String? duplicateOf,
    double? duplicateConfidence,
    String? clusterId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Normalise the ML payload into a consistent `{is_issue, data}` structure
      final normalizedAnalysis = _normalizeMlPayload(mlAnalysisResult);
      final bool aiThinksIssue = normalizedAnalysis?['is_issue'] as bool? ?? true;
      final Map<String, dynamic> aiDetails =
          normalizedAnalysis?['data'] as Map<String, dynamic>? ?? {};
      final derivedPriority =
          (aiDetails['priority'] as String?)?.toLowerCase() ?? 'medium';
      final issueTypeNormalized = _normalizeIssueType(
        (aiDetails['issue_type'] as String?) ?? category,
      );
      final geoCell = _geoCellFor(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      // Status: if AI says it's not an issue, mark accordingly
      final status = aiThinksIssue ? 'pending' : 'not_issue';

      // Pre-generate the document reference to store the ID inside the document itself
      final docRef = _firestore.collection('complaints').doc();
      final complaintId = docRef.id;

      final complaintData = {
        'id': complaintId, // Store the ID in the document for easier retrieval
        'userId': user.uid,
        'userEmail': user.email,
        'imageUrls': imageUrls,
        'description': description,
        'category': category,
        'location': GeoPoint(location.latitude, location.longitude), // Firestore GeoPoint
        'address': address,
        'status': status,
        'priority': derivedPriority,
        'issueTypeNormalized': issueTypeNormalized,
        'geoCell': geoCell,
        'duplicateOf': duplicateOf,
        'duplicateConfidence': duplicateConfidence,
        'clusterId': clusterId ?? complaintId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'statusHistory': [
          {
            'status': status,
            'timestamp': Timestamp.now(),
          }
        ],
        // Only include aiAnalysis if the ML service returned a result
        if (normalizedAnalysis != null) 'aiAnalysis': normalizedAnalysis,
      };

      await docRef.set(complaintData);

      return complaintId;
    } catch (e) {
      print('Error adding complaint to Firestore: $e');
      rethrow;
    }
  }

  /// Fetches all complaints filed by the currently signed-in user (one-time read).
  ///
  /// Returns an empty list if the user is not authenticated or an error occurs.
  /// Results are ordered by creation date (newest first).
  Future<List<Map<String, dynamic>>> getUserComplaints() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return [];
      }

      final snapshot = await _firestore
          .collection('complaints')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      // Merge the document ID into each data map for convenience
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error getting user complaints: $e');
      return [];
    }
  }

  /// Fetches all complaints from Firestore (admin/officer view, one-time read).
  ///
  /// No user filtering — returns all complaints from all users.
  /// Returns an empty list on error.
  Future<List<Map<String, dynamic>>> getAllComplaints() async {
    try {
      final snapshot = await _firestore
          .collection('complaints')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error getting all complaints: $e');
      return [];
    }
  }

  /// Updates the [status] field of a complaint document (admin/officer function).
  ///
  /// Also updates the `updatedAt` server timestamp.
  /// Rethrows errors so the calling layer can handle them.
  Future<void> updateComplaintStatus(String complaintId, String newStatus) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': newStatus,
            'timestamp': Timestamp.now(),
          }
        ]),
      });
    } catch (e) {
      print('Error updating complaint status: $e');
      rethrow;
    }
  }

  /// Updates status for multiple complaints in one batch.
  ///
  /// Useful for duplicate clusters where canonical status should be propagated.
  Future<void> updateComplaintStatusesBatch(
    List<String> complaintIds,
    String newStatus,
  ) async {
    if (complaintIds.isEmpty) return;
    try {
      final batch = _firestore.batch();
      final now = Timestamp.now();
      for (final id in complaintIds.toSet()) {
        final ref = _firestore.collection('complaints').doc(id);
        batch.update(ref, {
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
          'statusHistory': FieldValue.arrayUnion([
            {
              'status': newStatus,
              'timestamp': now,
            }
          ]),
        });
      }
      await batch.commit();
    } catch (e) {
      print('Error updating complaint statuses batch: $e');
      rethrow;
    }
  }

  /// Returns a real-time stream of all complaints (admin view).
  ///
  /// Each Firestore snapshot is mapped to a list of raw data maps.
  /// The document ID is merged into each map under the key 'id'.
  Stream<List<Map<String, dynamic>>> watchAllComplaints() {
    return _firestore
        .collection('complaints')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    });
  }

  /// Finds potential duplicate complaints using issue type + recency query,
  /// then computes local score with distance/time/description overlap.
  Future<List<DuplicateComplaintMatch>> findPotentialDuplicates({
    required String issueTypeOrCategory,
    required double latitude,
    required double longitude,
    required DateTime now,
    required String description,
  }) async {
    final normalizedType = _normalizeIssueType(issueTypeOrCategory);
    final since = now.subtract(const Duration(days: 14));

    final snap = await _firestore
        .collection('complaints')
        .where('issueTypeNormalized', isEqualTo: normalizedType)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('createdAt', descending: true)
        .limit(80)
        .get();

    final sourceTokens = _tokens(description);
    final results = <DuplicateComplaintMatch>[];

    for (final doc in snap.docs) {
      final data = doc.data();
      final point = data['location'];
      if (point is! GeoPoint) continue;
      final createdAtTs = data['createdAt'] as Timestamp?;
      if (createdAtTs == null) continue;

      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        point.latitude,
        point.longitude,
      );
      final ageDays = now.difference(createdAtTs.toDate()).inDays;
      final distanceScore = _distanceScore(distance);
      final timeScore = _timeScore(ageDays);
      final textScore = _textSimilarity(sourceTokens, _tokens((data['description'] ?? '').toString()));
      final score = (0.5 * distanceScore) + (0.3 * timeScore) + (0.2 * textScore);

      if (score >= 0.45) {
        results.add(
          DuplicateComplaintMatch(
            complaintId: doc.id,
            clusterId: data['clusterId']?.toString(),
            score: score,
            distanceMeters: distance,
            createdAt: createdAtTs.toDate(),
            issueType: normalizedType,
          ),
        );
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  Future<void> markAsDuplicate({
    required String complaintId,
    required String canonicalComplaintId,
    required double confidence,
  }) async {
    String canonicalClusterId = canonicalComplaintId;
    final canonicalDoc = await _firestore.collection('complaints').doc(canonicalComplaintId).get();
    if (canonicalDoc.exists) {
      canonicalClusterId = (canonicalDoc.data()?['clusterId']?.toString().trim().isNotEmpty ?? false)
          ? canonicalDoc.data()!['clusterId'].toString()
          : canonicalComplaintId;
    }

    await _firestore.collection('complaints').doc(complaintId).update({
      'duplicateOf': canonicalComplaintId,
      'duplicateConfidence': confidence,
      'clusterId': canonicalClusterId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  String _normalizeIssueType(String raw) {
    return raw.trim().toLowerCase().replaceAll(' ', '_');
  }

  String _geoCellFor({required double latitude, required double longitude}) {
    final latBucket = (latitude * 100).round();
    final lonBucket = (longitude * 100).round();
    return '${latBucket}_$lonBucket';
  }

  double _distanceScore(double meters) {
    if (meters <= 80) return 1.0;
    if (meters <= 150) return 0.8;
    if (meters <= 250) return 0.6;
    if (meters <= 350) return 0.4;
    return 0.1;
  }

  double _timeScore(int ageDays) {
    if (ageDays <= 1) return 1.0;
    if (ageDays <= 3) return 0.8;
    if (ageDays <= 7) return 0.6;
    if (ageDays <= 14) return 0.4;
    return 0.1;
  }

  Set<String> _tokens(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2)
        .toSet();
  }

  double _textSimilarity(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    final inter = a.intersection(b).length.toDouble();
    final union = a.union(b).length.toDouble();
    if (union == 0) return 0.0;
    return inter / union;
  }

  /// Fetches a single complaint by document ID.
  ///
  /// Returns null when the document does not exist.
  Future<Map<String, dynamic>?> getComplaintById(String complaintId) async {
    try {
      final doc = await _firestore.collection('complaints').doc(complaintId).get();
      if (!doc.exists) return null;
      return {
        'id': doc.id,
        ...doc.data()!,
      };
    } catch (e) {
      print('Error getting complaint by id: $e');
      return null;
    }
  }

  /// Normalises the raw ML API response into a consistent Firestore-safe structure.
  ///
  /// The output always has the shape:
  /// ```json
  /// { "is_issue": bool, "data": { ...ai fields } }
  /// ```
  ///
  /// Returns null if [payload] is null (i.e., no ML analysis was performed).
  /// Handles cases where `data` is missing or has the wrong type.
  Map<String, dynamic>? _normalizeMlPayload(Map<String, dynamic>? payload) {
    if (payload == null) return null;

    final aiDataRaw = payload['data'];
    return {
      'is_issue': payload['is_issue'] ?? true,
      'data': aiDataRaw is Map<String, dynamic>
          ? Map<String, dynamic>.from(aiDataRaw)
          : <String, dynamic>{},
    };
  }
}
