import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/complaint_feedback.dart';
import '../models/notification_model.dart';
import 'notification_repository.dart';

class ComplaintFeedbackRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final NotificationRepository _notificationRepository;

  ComplaintFeedbackRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    NotificationRepository? notificationRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _notificationRepository = notificationRepository ?? NotificationRepository();

  CollectionReference<Map<String, dynamic>> get _feedback =>
      _firestore.collection('complaint_feedback');

  Future<void> submitDelayFeedback({
    required String complaintId,
    required String complaintPriority,
    required DateTime complaintCreatedAt,
    required bool immediateActionRequired,
    required bool safetyHazard,
    required String message,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final now = DateTime.now();
    final thresholdDays = _computeThresholdDays(
      priority: complaintPriority,
      immediateActionRequired: immediateActionRequired,
      safetyHazard: safetyHazard,
    );
    final ageDays = now.difference(complaintCreatedAt).inDays;
    final severity = ageDays >= thresholdDays
        ? ComplaintFeedbackSeverity.urgent
        : ComplaintFeedbackSeverity.normal;

    final doc = _feedback.doc();
    await doc.set({
      'id': doc.id,
      'complaintId': complaintId,
      'userId': user.uid,
      'message': message.trim(),
      'type': 'delay',
      'severity': severity.name,
      'status': ComplaintFeedbackStatus.open.name,
      'thresholdDays': thresholdDays,
      'complaintAgeDays': ageDays,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _notifyAdmins(
      complaintId: complaintId,
      severity: severity,
      ageDays: ageDays,
      thresholdDays: thresholdDays,
    );
  }

  Stream<List<ComplaintFeedback>> watchAllFeedback() {
    return _feedback.orderBy('createdAt', descending: true).snapshots().map((snap) {
      return snap.docs
          .map((d) => ComplaintFeedback.fromMap(d.id, d.data()))
          .toList();
    });
  }

  Future<void> markResolved(String feedbackId) async {
    await _feedback.doc(feedbackId).update({
      'status': ComplaintFeedbackStatus.resolved.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  int _computeThresholdDays({
    required String priority,
    required bool immediateActionRequired,
    required bool safetyHazard,
  }) {
    int threshold;
    switch (priority.toLowerCase()) {
      case 'emergency':
        threshold = 1;
        break;
      case 'high':
        threshold = 1;
        break;
      case 'medium':
        threshold = 4;
        break;
      case 'low':
      default:
        threshold = 7;
        break;
    }

    if (immediateActionRequired) threshold = threshold < 1 ? threshold : 1;
    if (safetyHazard) threshold = threshold < 2 ? threshold : 2;
    return threshold;
  }

  Future<void> _notifyAdmins({
    required String complaintId,
    required ComplaintFeedbackSeverity severity,
    required int ageDays,
    required int thresholdDays,
  }) async {
    final admins = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get();

    for (final admin in admins.docs) {
      await _notificationRepository.sendNotification(
        recipientId: admin.id,
        title: severity == ComplaintFeedbackSeverity.urgent
            ? 'Urgent delay feedback'
            : 'New delay feedback',
        body:
            'Complaint delay feedback received. Age: ${ageDays}d, threshold: ${thresholdDays}d.',
        type: NotificationType.general,
        relatedId: complaintId,
      );
    }
  }
}

