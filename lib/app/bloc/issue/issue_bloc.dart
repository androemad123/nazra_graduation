import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../models/issue_model.dart';
import '../../repositories/issue_repository.dart';
import 'issue_event.dart';
import 'issue_state.dart';

// Internal events for stream updates
class _IssuesUpdated extends IssueEvent {
  final List<Issue> issues;
  _IssuesUpdated(this.issues);
  @override
  List<Object?> get props => [issues];
}

class _IssuesError extends IssueEvent {
  final String error;
  _IssuesError(this.error);
  @override
  List<Object?> get props => [error];
}

class IssueBloc extends Bloc<IssueEvent, IssueState> {
  final IssueRepository _repo;
  StreamSubscription<List<Issue>>? _issuesSub;

  IssueBloc({required IssueRepository repo})
      : _repo = repo,
        super(const IssueState()) {
    on<LoadCommunityIssues>(_onLoadIssues);
    on<CreateIssueRequested>(_onCreateIssue);
    on<VoteIssueRequested>(_onVoteIssue);
    on<UnvoteIssueRequested>(_onUnvoteIssue);
    on<EscalateIssueRequested>(_onEscalateIssue);
    on<ResolveIssueRequested>(_onResolveIssue);
    on<_IssuesUpdated>(_onIssuesUpdated);
    on<_IssuesError>(_onIssuesError);
  }

  Future<void> _onLoadIssues(
      LoadCommunityIssues event, Emitter<IssueState> emit) async {
    emit(state.copyWith(status: IssueStatus.loading));
    await _issuesSub?.cancel();
    _issuesSub = _repo.watchCommunityIssues(event.communityId).listen(
      (issues) {
        add(_IssuesUpdated(issues));
      },
      onError: (e) {
        add(_IssuesError(e.toString()));
      },
    );
  }

  void _onIssuesUpdated(_IssuesUpdated event, Emitter<IssueState> emit) {
    emit(state.copyWith(
      status: IssueStatus.success,
      issues: event.issues,
    ));
  }

  void _onIssuesError(_IssuesError event, Emitter<IssueState> emit) {
    emit(state.copyWith(
      status: IssueStatus.failure,
      error: event.error,
    ));
  }

  Future<void> _onCreateIssue(
      CreateIssueRequested event, Emitter<IssueState> emit) async {
    try {
      await _repo.createIssue(
        communityId: event.communityId,
        title: event.title,
        description: event.description,
        imageUrls: event.imageUrls,
        category: event.category,
        mlAnalysisResult: event.mlAnalysisResult,
        location: event.location,
        address: event.address,
      );
      // State will be updated via stream
    } catch (e) {
      emit(state.copyWith(
        status: IssueStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onVoteIssue(
      VoteIssueRequested event, Emitter<IssueState> emit) async {
    try {
      await _repo.voteIssue(event.issueId);
      // State will be updated via stream
    } catch (e) {
      emit(state.copyWith(
        status: IssueStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUnvoteIssue(
      UnvoteIssueRequested event, Emitter<IssueState> emit) async {
    try {
      await _repo.unvoteIssue(event.issueId);
      // State will be updated via stream
    } catch (e) {
      emit(state.copyWith(
        status: IssueStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onEscalateIssue(
      EscalateIssueRequested event, Emitter<IssueState> emit) async {
    try {
      await _repo.escalateIssue(event.issueId, note: event.note);
      // State will be updated via stream
    } catch (e) {
      emit(state.copyWith(
        status: IssueStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onResolveIssue(
      ResolveIssueRequested event, Emitter<IssueState> emit) async {
    try {
      await _repo.resolveIssue(event.issueId, note: event.note);
      // State will be updated via stream
    } catch (e) {
      emit(state.copyWith(
        status: IssueStatus.failure,
        error: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _issuesSub?.cancel();
    return super.close();
  }
}

