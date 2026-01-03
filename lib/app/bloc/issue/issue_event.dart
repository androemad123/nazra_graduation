import 'package:equatable/equatable.dart';

import 'package:geolocator/geolocator.dart';

abstract class IssueEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCommunityIssues extends IssueEvent {
  final String communityId;
  LoadCommunityIssues(this.communityId);
  @override
  List<Object?> get props => [communityId];
}

class CreateIssueRequested extends IssueEvent {
  final String communityId;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String category;
  final Map<String, dynamic>? mlAnalysisResult;
  final Position? location;
  final String? address;

  CreateIssueRequested({
    required this.communityId,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.category,
    this.mlAnalysisResult,
    this.location,
    this.address,
  });

  @override
  List<Object?> get props => [communityId, title, description, imageUrls, category, mlAnalysisResult, location, address];
}

class VoteIssueRequested extends IssueEvent {
  final String issueId;
  VoteIssueRequested(this.issueId);
  @override
  List<Object?> get props => [issueId];
}

class UnvoteIssueRequested extends IssueEvent {
  final String issueId;
  UnvoteIssueRequested(this.issueId);
  @override
  List<Object?> get props => [issueId];
}

class EscalateIssueRequested extends IssueEvent {
  final String issueId;
  final String? note;
  EscalateIssueRequested(this.issueId, {this.note});
  @override
  List<Object?> get props => [issueId, note];
}

class ResolveIssueRequested extends IssueEvent {
  final String issueId;
  final String? note;
  ResolveIssueRequested(this.issueId, {this.note});
  @override
  List<Object?> get props => [issueId, note];
}

