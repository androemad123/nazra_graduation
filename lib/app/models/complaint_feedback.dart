import 'package:cloud_firestore/cloud_firestore.dart';

enum ComplaintFeedbackSeverity { normal, urgent }
enum ComplaintFeedbackStatus { open, resolved }

class ComplaintFeedback {
  final String id;
  final String complaintId;
  final String userId;
  final String message;
  final String type;
  final ComplaintFeedbackSeverity severity;
  final ComplaintFeedbackStatus status;
  final int thresholdDays;
  final int complaintAgeDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  ComplaintFeedback({
    required this.id,
    required this.complaintId,
    required this.userId,
    required this.message,
    required this.type,
    required this.severity,
    required this.status,
    required this.thresholdDays,
    required this.complaintAgeDays,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComplaintFeedback.fromMap(String id, Map<String, dynamic> map) {
    return ComplaintFeedback(
      id: id,
      complaintId: (map['complaintId'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      message: (map['message'] ?? '').toString(),
      type: (map['type'] ?? 'delay').toString(),
      severity: ComplaintFeedbackSeverity.values.firstWhere(
        (e) => e.name == map['severity'],
        orElse: () => ComplaintFeedbackSeverity.normal,
      ),
      status: ComplaintFeedbackStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ComplaintFeedbackStatus.open,
      ),
      thresholdDays: (map['thresholdDays'] as num?)?.toInt() ?? 0,
      complaintAgeDays: (map['complaintAgeDays'] as num?)?.toInt() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

