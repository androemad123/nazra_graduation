import 'package:equatable/equatable.dart';
import '../../models/issue_model.dart';

/// Represents the possible statuses of issue data operations.
///
/// - [initial] : No data has been requested yet (default on bloc creation).
/// - [loading] : A Firestore stream is being set up or data is in flight.
/// - [success] : The latest data from Firestore has been applied.
/// - [failure] : An error occurred during the operation.
enum IssueStatus { initial, loading, success, failure }

/// Immutable state for the [IssueBloc].
///
/// Holds the current list of issues for the selected community,
/// the load status, and any error message.
///
/// Uses [copyWith] to produce modified copies without mutating in place.
class IssueState extends Equatable {
  /// Current status of the issues data operation.
  final IssueStatus status;

  /// The list of issues for the currently watched community.
  /// Empty until the first successful load.
  final List<Issue> issues;

  /// An error message set when [status] is [IssueStatus.failure].
  final String? error;

  const IssueState({
    this.status = IssueStatus.initial,
    this.issues = const [],
    this.error,
  });

  /// Creates a new state with selective field overrides.
  ///
  /// Fields not provided retain their current values.
  IssueState copyWith({
    IssueStatus? status,
    List<Issue>? issues,
    String? error,
  }) {
    return IssueState(
      status: status ?? this.status,
      issues: issues ?? this.issues,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, issues, error];
}
