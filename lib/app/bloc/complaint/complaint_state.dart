import 'package:equatable/equatable.dart';
import '../../models/complaint_model.dart';

enum ComplaintStatus { initial, loading, success, failure }

class ComplaintState extends Equatable {
  final ComplaintStatus status;
  final List<Complaint> complaints;
  final String? error;

  const ComplaintState({
    this.status = ComplaintStatus.initial,
    this.complaints = const [],
    this.error,
  });

  ComplaintState copyWith({
    ComplaintStatus? status,
    List<Complaint>? complaints,
    String? error,
  }) {
    return ComplaintState(
      status: status ?? this.status,
      complaints: complaints ?? this.complaints,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, complaints, error];
}

