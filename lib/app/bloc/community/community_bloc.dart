import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../models/community.dart';
import '../../repositories/community_repository.dart';
import 'community_event.dart';
import 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final CommunityRepository _repo;
  StreamSubscription<List<Community>>? _listSub;

  CommunityBloc({required CommunityRepository repo}) : _repo = repo, super(const CommunityState()) {
    on<LoadCommunities>(_onLoad);
    on<CreateCommunityRequested>(_onCreate);
    on<RequestJoinCommunity>(_onRequestJoin);
    on<ApproveJoin>(_onApprove);
    on<RejectJoin>(_onReject);
    on<_CommunitiesUpdated>(_onCommunitiesUpdated);
    on<_CommunitiesError>(_onCommunitiesError);

    add(LoadCommunities());
  }

  Future<void> _onLoad(LoadCommunities event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(status: CommunityStatus.loading));
    await _listSub?.cancel();
    _listSub = _repo.watchCommunities().listen((list) {
      add(_CommunitiesUpdated(list));
    }, onError: (e) {
      add(_CommunitiesError(e.toString()));
    });
  }

  // internal events for stream updates
  void _onCommunitiesUpdated(_CommunitiesUpdated event, Emitter<CommunityState> emit) {
    emit(state.copyWith(status: CommunityStatus.success, communities: event.communities));
  }
  void _onCommunitiesError(_CommunitiesError event, Emitter<CommunityState> emit) {
    emit(state.copyWith(status: CommunityStatus.failure, error: event.error));
  }

  Future<void> _onCreate(CreateCommunityRequested event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(status: CommunityStatus.loading));
    try {
      await _repo.createCommunity(name: event.name, description: event.description, ownerId: event.ownerId);
      emit(state.copyWith(status: CommunityStatus.success));
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onRequestJoin(RequestJoinCommunity event, Emitter<CommunityState> emit) async {
    try {
      print("${event.communityId} ${event.userId}");
      await _repo.requestJoin(event.communityId, event.userId);
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onApprove(ApproveJoin event, Emitter<CommunityState> emit) async {
    try {
      await _repo.approveJoin(event.communityId, event.userId);
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onReject(RejectJoin event, Emitter<CommunityState> emit) async {
    try {
      await _repo.rejectJoin(event.communityId, event.userId);
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.failure, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _listSub?.cancel();
    return super.close();
  }
}

// Private events to handle stream updates (not exported)
class _CommunitiesUpdated extends CommunityEvent {
  final List<Community> communities;
  _CommunitiesUpdated(this.communities);
  @override List<Object?> get props => [communities];
}
class _CommunitiesError extends CommunityEvent {
  final String error;
  _CommunitiesError(this.error);
  @override List<Object?> get props => [error];
}
