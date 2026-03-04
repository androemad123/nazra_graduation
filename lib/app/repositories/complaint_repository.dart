import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

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
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
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
      });
    } catch (e) {
      print('Error updating complaint status: $e');
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
