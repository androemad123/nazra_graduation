import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../models/community.dart';
import '../../repositories/community_repository.dart';
import 'community_event.dart';
import 'community_state.dart';

/// BLoC that manages the list of communities and membership operations.
///
/// On creation, automatically dispatches [LoadCommunities] to start
/// listening to the real-time Firestore stream of all communities.
///
/// Events handled:
/// - [LoadCommunities]          : Subscribes to the communities stream.
/// - [CreateCommunityRequested] : Creates a new community in Firestore.
/// - [RequestJoinCommunity]     : Sends a join request for a community.
/// - [ApproveJoin]              : Approves a pending join request (owner only).
/// - [RejectJoin]               : Rejects a pending join request (owner only).
/// - [_CommunitiesUpdated]      : Internal — fired by the stream when data changes.
/// - [_CommunitiesError]        : Internal — fired when the stream encounters an error.
class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  /// Repository that handles all Firestore operations for communities.
  final CommunityRepository _repo;

  /// Active Firestore stream subscription to the communities collection.
  StreamSubscription<List<Community>>? _listSub;

  /// Creates the bloc, registers event handlers, and immediately loads communities.
  CommunityBloc({required CommunityRepository repo}) : _repo = repo, super(const CommunityState()) {
    on<LoadCommunities>(_onLoad);
    on<CreateCommunityRequested>(_onCreate);
    on<RequestJoinCommunity>(_onRequestJoin);
    on<ApproveJoin>(_onApprove);
    on<RejectJoin>(_onReject);
    on<_CommunitiesUpdated>(_onCommunitiesUpdated);
    on<_CommunitiesError>(_onCommunitiesError);

    // Auto-load communities when the bloc is created
    add(LoadCommunities());
  }

  /// Handles [LoadCommunities]: emits loading, then subscribes to the communities stream.
  ///
  /// Any previous subscription is cancelled before starting a new one.
  /// Stream updates and errors are forwarded via internal events.
  Future<void> _onLoad(LoadCommunities event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(status: CommunityStatus.loading));
    await _listSub?.cancel();
    _listSub = _repo.watchCommunities().listen((list) {
      add(_CommunitiesUpdated(list));
    }, onError: (e) {
      add(_CommunitiesError(e.toString()));
    });
  }

  /// Internal handler: updates the state with a new list of communities from the stream.
  void _onCommunitiesUpdated(_CommunitiesUpdated event, Emitter<CommunityState> emit) {
    emit(state.copyWith(status: CommunityStatus.success, communities: event.communities));
  }

  /// Internal handler: updates state to failure with an error message from the stream.
  void _onCommunitiesError(_CommunitiesError event, Emitter<CommunityState> emit) {
    emit(state.copyWith(status: CommunityStatus.failure, error: event.error));
  }

  /// Handles [CreateCommunityRequested]: creates a new community via the repository.
  ///
  /// The community list will be automatically refreshed by the real-time stream
  /// once Firestore writes the new document.
  Future<void> _onCreate(CreateCommunityRequested event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(status: CommunityStatus.loading));
    try {
      await _repo.createCommunity(name: event.name, description: event.description, ownerId: event.ownerId);
      emit(state.copyWith(status: CommunityStatus.success));
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.failure, error: e.toString()));
    }
  }

  /// Handles [RequestJoinCommunity]: submits a join request to Firestore.
  ///
  /// A notification is sent to the community owner by the repository.
  /// Does not change the community list state — no loading indicator is intentional.
  Future<void> _onRequestJoin(RequestJoinCommunity event, Emitter<CommunityState> emit) async {
    try {
      print("${event.communityId} ${event.userId}");
      await _repo.requestJoin(event.communityId, event.userId);
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.failure, error: e.toString()));
    }
  }

  /// Handles [ApproveJoin]: approves a user's pending join request.
  ///
  /// Uses a Firestore transaction to atomically add the user to the members list
  /// and delete the join request document. A success notification is sent to the user.
  Future<void> _onApprove(ApproveJoin event, Emitter<CommunityState> emit) async {
    try {
      await _repo.approveJoin(event.communityId, event.userId);
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.failure, error: e.toString()));
    }
  }

  /// Handles [RejectJoin]: rejects and removes a pending join request.
  Future<void> _onReject(RejectJoin event, Emitter<CommunityState> emit) async {
    try {
      await _repo.rejectJoin(event.communityId, event.userId);
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.failure, error: e.toString()));
    }
  }

  /// Cancels the Firestore communities stream when the bloc is closed.
  @override
  Future<void> close() {
    _listSub?.cancel();
    return super.close();
  }
}

// ---------------------------------------------------------------------------
// Private events used internally by the bloc to forward stream results.
// These are NOT part of the public API and should not be dispatched externally.
// ---------------------------------------------------------------------------

/// Internal event dispatched when the Firestore communities stream emits a new list.
class _CommunitiesUpdated extends CommunityEvent {
  /// The updated list of [Community] objects from Firestore.
  final List<Community> communities;
  _CommunitiesUpdated(this.communities);
  @override List<Object?> get props => [communities];
}

/// Internal event dispatched when the Firestore communities stream reports an error.
class _CommunitiesError extends CommunityEvent {
  /// The error message from the stream.
  final String error;
  _CommunitiesError(this.error);
  @override List<Object?> get props => [error];
}
