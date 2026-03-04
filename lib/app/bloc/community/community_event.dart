import 'package:equatable/equatable.dart';

/// Base class for all community events.
///
/// All events extend [Equatable] for efficient equality comparisons in the BLoC.
abstract class CommunityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to start (or restart) loading the communities list from Firestore.
///
/// Automatically dispatched when the [CommunityBloc] is created.
class LoadCommunities extends CommunityEvent {}

/// Event to create a new community.
///
/// [name] and [description] define the community.
/// [ownerId] is the Firebase UID of the user creating the community.
/// The owner is automatically added as the first member.
class CreateCommunityRequested extends CommunityEvent {
  /// Display name of the community.
  final String name;

  /// A brief description of the community's purpose.
  final String description;

  /// Firebase UID of the user creating the community (automatically becomes a member).
  final String ownerId;

  CreateCommunityRequested({required this.name, required this.description, required this.ownerId});

  @override List<Object?> get props => [name, description, ownerId];
}

/// Event for a user to request joining a community.
///
/// Sends a join request document to Firestore and notifies the community owner.
class RequestJoinCommunity extends CommunityEvent {
  /// The Firestore document ID of the community to join.
  final String communityId;

  /// The Firebase UID of the user requesting to join.
  final String userId;

  RequestJoinCommunity(this.communityId, this.userId);
  @override List<Object?> get props => [communityId, userId];
}

/// Event for a community owner to approve a pending join request.
///
/// Uses a Firestore transaction to atomically add the user to the members list
/// and delete their join request.
class ApproveJoin extends CommunityEvent {
  /// The Firestore document ID of the community.
  final String communityId;

  /// The Firebase UID of the user whose request is being approved.
  final String userId;

  ApproveJoin(this.communityId, this.userId);
  @override List<Object?> get props => [communityId, userId];
}

/// Event for a community owner to reject a pending join request.
///
/// Deletes the join request document from Firestore.
class RejectJoin extends CommunityEvent {
  /// The Firestore document ID of the community.
  final String communityId;

  /// The Firebase UID of the user whose request is being rejected.
  final String userId;

  RejectJoin(this.communityId, this.userId);
  @override List<Object?> get props => [communityId, userId];
}
