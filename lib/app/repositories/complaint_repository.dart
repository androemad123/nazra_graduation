import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

/// Repository for managing complaints in Firestore
class ComplaintRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Adds a complaint to the 'complaints' collection in Firestore
  /// 
  /// [imageUrls] - List of Cloudinary image URLs
  /// [description] - Description of the complaint
  /// [category] - Category/type of problem
  /// [location] - Position object containing latitude and longitude
  /// [address] - Human-readable address string
  /// [mlAnalysisResult] - Full ML analysis result (optional, for storing additional fields)
  /// 
  /// Returns the document ID of the created complaint
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

      final normalizedAnalysis = _normalizeMlPayload(mlAnalysisResult);
      final bool aiThinksIssue = normalizedAnalysis?['is_issue'] as bool? ?? true;
      final Map<String, dynamic> aiDetails =
          normalizedAnalysis?['data'] as Map<String, dynamic>? ?? {};
      final derivedPriority =
          (aiDetails['priority'] as String?)?.toLowerCase() ?? 'medium';
      final status = aiThinksIssue ? 'pending' : 'not_issue';

      // Create document reference first to get the ID
      final docRef = _firestore.collection('complaints').doc();
      final complaintId = docRef.id;

      final complaintData = {
        'id': complaintId, // Store the ID in the document
        'userId': user.uid,
        'userEmail': user.email,
        'imageUrls': imageUrls,
        'description': description,
        'category': category,
        'location': GeoPoint(location.latitude, location.longitude),
        'address': address,
        'status': status,
        'priority': derivedPriority,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (normalizedAnalysis != null) 'aiAnalysis': normalizedAnalysis,
      };

      await docRef.set(complaintData);

      return complaintId;
    } catch (e) {
      print('Error adding complaint to Firestore: $e');
      rethrow;
    }
  }

  /// Gets all complaints for the current user
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

  /// Gets all complaints (admin view)
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

  /// Updates the status of a complaint (admin function)

  /// Updates the status of a complaint (admin function)
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

  /// Stream all complaints for admin (real-time updates)
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

