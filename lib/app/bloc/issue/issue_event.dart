import 'package:equatable/equatable.dart';

import 'package:geolocator/geolocator.dart';

/// Base class for all issue-related events.
///
/// Extends [Equatable] for efficient BLoC event comparison.
abstract class IssueEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to start loading all issues for a specific community.
///
/// Dispatching this event subscribes to a real-time Firestore stream
/// of issues filtered by [communityId], ordered by date (newest first).
class LoadCommunityIssues extends IssueEvent {
  /// The Firestore document ID of the community whose issues should be loaded.
  final String communityId;
  LoadCommunityIssues(this.communityId);
  @override
  List<Object?> get props => [communityId];
}

/// Event to create a new community issue report.
///
/// Includes all necessary fields to build an [Issue] document in Firestore,
/// with optional ML analysis result, geographic location, and address.
class CreateIssueRequested extends IssueEvent {
  /// The community this issue belongs to.
  final String communityId;

  /// A short title summarising the issue.
  final String title;

  /// A detailed description of the issue.
  final String description;

  /// Cloudinary URLs of images attached to the issue.
  final List<String> imageUrls;

  /// The issue category (e.g., 'Roads', 'Sanitation').
  final String category;

  /// Optional ML analysis result from the backend — used to set priority and AI fields.
  final Map<String, dynamic>? mlAnalysisResult;

  /// Optional GPS position of the issue location.
  final Position? location;

  /// Optional human-readable address string for the issue location.
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

/// Event to add the current user's upvote to an issue.
///
/// The user's UID is added to the issue's `votes` array atomically.
/// A notification is sent to the issue owner, and the activity is logged.
class VoteIssueRequested extends IssueEvent {
  /// The Firestore document ID of the issue to vote on.
  final String issueId;
  VoteIssueRequested(this.issueId);
  @override
  List<Object?> get props => [issueId];
}

/// Event to remove the current user's vote from an issue.
///
/// The user's UID is removed from the issue's `votes` array.
class UnvoteIssueRequested extends IssueEvent {
  /// The Firestore document ID of the issue to remove the vote from.
  final String issueId;
  UnvoteIssueRequested(this.issueId);
  @override
  List<Object?> get props => [issueId];
}

/// Event to escalate a community issue to authorities.
///
/// Changes the issue's status to 'escalated' and notifies the issue owner.
class EscalateIssueRequested extends IssueEvent {
  /// The Firestore document ID of the issue to escalate.
  final String issueId;

  /// An optional message explaining why the issue was escalated.
  final String? note;
  EscalateIssueRequested(this.issueId, {this.note});
  @override
  List<Object?> get props => [issueId, note];
}

/// Event to mark a community issue as resolved.
///
/// Changes the issue's status to 'resolved' and notifies the issue owner.
class ResolveIssueRequested extends IssueEvent {
  /// The Firestore document ID of the issue to resolve.
  final String issueId;

  /// An optional message describing how the issue was resolved.
  final String? note;
  ResolveIssueRequested(this.issueId, {this.note});
  @override
  List<Object?> get props => [issueId, note];
}
