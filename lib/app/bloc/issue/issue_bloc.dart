import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../models/issue_model.dart';
import '../../repositories/issue_repository.dart';
import 'issue_event.dart';
import 'issue_state.dart';

// ---------------------------------------------------------------------------
// Private internal events — forward Firestore stream results into the bloc.
// These are NOT part of the public event API.
// ---------------------------------------------------------------------------

/// Internal event dispatched when the issues stream emits a new list.
class _IssuesUpdated extends IssueEvent {
  /// The refreshed list of [Issue] objects from Firestore.
  final List<Issue> issues;
  _IssuesUpdated(this.issues);
  @override
  List<Object?> get props => [issues];
}

/// Internal event dispatched when the issues stream encounters an error.
class _IssuesError extends IssueEvent {
  /// The error message from the stream.
  final String error;
  _IssuesError(this.error);
  @override
  List<Object?> get props => [error];
}

/// BLoC that manages the lifecycle of community issues (reports/problems).
///
/// Handles loading issues for a specific community in real time, plus
/// create, vote, unvote, escalate, and resolve operations.
///
/// After any mutating operation (create, vote, etc.), the state is updated
/// automatically via the Firestore stream — so those handlers don't need to
/// manually emit a success state.
///
/// Events handled:
/// - [LoadCommunityIssues]    : Subscribes to the issues stream for a community.
/// - [CreateIssueRequested]   : Creates a new issue document in Firestore.
/// - [VoteIssueRequested]     : Adds the current user's vote to an issue.
/// - [UnvoteIssueRequested]   : Removes the current user's vote from an issue.
/// - [EscalateIssueRequested] : Changes an issue's status to 'escalated'.
/// - [ResolveIssueRequested]  : Changes an issue's status to 'resolved'.
/// - [_IssuesUpdated]         : Internal — refreshes state from stream data.
/// - [_IssuesError]           : Internal — transitions to failure state on stream error.
class IssueBloc extends Bloc<IssueEvent, IssueState> {
  /// Repository handling all Firestore operations for issues.
  final IssueRepository _repo;

  /// Active Firestore stream subscription for the current community's issues.
  StreamSubscription<List<Issue>>? _issuesSub;

  /// Creates the bloc and registers all event handlers.
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

  /// Handles [LoadCommunityIssues]: subscribes to real-time issues for a given community.
  ///
  /// Cancels any previous subscription before starting a new one.
  /// Issues are ordered by creation date (newest first) by the repository.
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

  /// Internal handler: updates state with a fresh list of issues from Firestore.
  void _onIssuesUpdated(_IssuesUpdated event, Emitter<IssueState> emit) {
    emit(state.copyWith(
      status: IssueStatus.success,
      issues: event.issues,
    ));
  }

  /// Internal handler: transitions state to failure with the stream's error message.
  void _onIssuesError(_IssuesError event, Emitter<IssueState> emit) {
    emit(state.copyWith(
      status: IssueStatus.failure,
      error: event.error,
    ));
  }

  /// Handles [CreateIssueRequested]: creates a new issue document in Firestore.
  ///
  /// Passes along all provided fields including optional ML analysis result,
  /// location, and address. The new issue will appear automatically via the
  /// active stream — no manual state update is needed here.
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
      // State will be updated via the real-time stream automatically
    } catch (e) {
      emit(state.copyWith(
        status: IssueStatus.failure,
        error: e.toString(),
      ));
    }
  }

  /// Handles [VoteIssueRequested]: records the current user's upvote on an issue.
  ///
  /// Uses a Firestore transaction to safely add the user's UID to the votes list.
  /// Also sends a notification to the issue owner and logs the activity.
  /// The updated vote count will appear via the real-time stream.
  Future<void> _onVoteIssue(
      VoteIssueRequested event, Emitter<IssueState> emit) async {
    try {
      await _repo.voteIssue(event.issueId);
      // State will be updated via the real-time stream automatically
    } catch (e) {
      emit(state.copyWith(
        status: IssueStatus.failure,
        error: e.toString(),
      ));
    }
  }

  /// Handles [UnvoteIssueRequested]: removes the current user's vote from an issue.
  ///
  /// Uses Firestore's [FieldValue.arrayRemove] to safely remove the user's UID.
  Future<void> _onUnvoteIssue(
      UnvoteIssueRequested event, Emitter<IssueState> emit) async {
    try {
      await _repo.unvoteIssue(event.issueId);
      // State will be updated via the real-time stream automatically
    } catch (e) {
      emit(state.copyWith(
        status: IssueStatus.failure,
        error: e.toString(),
      ));
    }
  }

  /// Handles [EscalateIssueRequested]: marks an issue as 'escalated' in Firestore.
  ///
  /// An optional [note] can be attached. A notification is sent to the issue owner.
  Future<void> _onEscalateIssue(
      EscalateIssueRequested event, Emitter<IssueState> emit) async {
    try {
      await _repo.escalateIssue(event.issueId, note: event.note);
      // State will be updated via the real-time stream automatically
    } catch (e) {
      emit(state.copyWith(
        status: IssueStatus.failure,
        error: e.toString(),
      ));
    }
  }

  /// Handles [ResolveIssueRequested]: marks an issue as 'resolved' in Firestore.
  ///
  /// An optional [note] can be attached. A notification is sent to the issue owner.
  Future<void> _onResolveIssue(
      ResolveIssueRequested event, Emitter<IssueState> emit) async {
    try {
      await _repo.resolveIssue(event.issueId, note: event.note);
      // State will be updated via the real-time stream automatically
    } catch (e) {
      emit(state.copyWith(
        status: IssueStatus.failure,
        error: e.toString(),
      ));
    }
  }

  /// Cancels the active Firestore subscription when the bloc is closed.
  @override
  Future<void> close() {
    _issuesSub?.cancel();
    return super.close();
  }
}
