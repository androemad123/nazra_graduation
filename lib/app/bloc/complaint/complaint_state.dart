import 'package:equatable/equatable.dart';
import '../../models/complaint_model.dart';

/// Represents all possible statuses of the complaint data loading lifecycle.
///
/// - [initial] : No data requested yet (default on bloc creation).
/// - [loading] : A Firestore stream is being set up or data is being fetched.
/// - [success] : Data has been successfully loaded from Firestore.
/// - [failure] : An error occurred while loading or streaming data.
enum ComplaintStatus { initial, loading, success, failure }

/// Immutable state for the [ComplaintBloc].
///
/// Holds the list of complaints, the current loading status, and any error message.
///
/// Use [copyWith] to produce updated copies without mutating the original state.

class ComplaintState extends Equatable {
  /// Current status of the complaints data operation.
  final ComplaintStatus status;

  /// The list of complaints loaded from Firestore. Empty until first successful load.
  final List<Complaint> complaints;

  /// An error message — set when [status] is [ComplaintStatus.failure].
  final String? error;

  const ComplaintState({
    this.status = ComplaintStatus.initial,
    this.complaints = const [],
    this.error,
  });

  /// Creates a new state with selective field overrides.
  ///
  /// Fields not provided retain their current values.
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