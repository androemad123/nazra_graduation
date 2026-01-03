import 'package:equatable/equatable.dart';

abstract class CommunityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCommunities extends CommunityEvent {}

class CreateCommunityRequested extends CommunityEvent {
  final String name;
  final String description;
  final String ownerId;
  CreateCommunityRequested({required this.name, required this.description, required this.ownerId});
  @override List<Object?> get props => [name, description, ownerId];
}

class RequestJoinCommunity extends CommunityEvent {
  final String communityId;
  final String userId;
  RequestJoinCommunity(this.communityId, this.userId);
  @override List<Object?> get props => [communityId, userId];
}

class ApproveJoin extends CommunityEvent {
  final String communityId;
  final String userId;
  ApproveJoin(this.communityId, this.userId);
  @override List<Object?> get props => [communityId, userId];
}

class RejectJoin extends CommunityEvent {
  final String communityId;
  final String userId;
  RejectJoin(this.communityId, this.userId);
  @override List<Object?> get props => [communityId, userId];
}
