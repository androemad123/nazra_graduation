import 'package:equatable/equatable.dart';
import '../../models/issue_model.dart';

enum IssueStatus { initial, loading, success, failure }

class IssueState extends Equatable {
  final IssueStatus status;
  final List<Issue> issues;
  final String? error;

  const IssueState({
    this.status = IssueStatus.initial,
    this.issues = const [],
    this.error,
  });

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

