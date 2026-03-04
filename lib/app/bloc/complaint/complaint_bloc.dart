import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/complaint_model.dart';
import '../../repositories/complaint_repository.dart';
import 'complaint_event.dart';
import 'complaint_state.dart';

// ---------------------------------------------------------------------------
// Private internal events for forwarding Firestore stream results.
// These must be defined before [ComplaintBloc] so the bloc can register them.
// ---------------------------------------------------------------------------

/// Internal event dispatched when the complaints stream emits new data.
/// Not part of the public API — only dispatched from within the bloc.
class _ComplaintsUpdated extends ComplaintEvent {
  /// The refreshed list of [Complaint] objects from Firestore.
  final List<Complaint> complaints;
  _ComplaintsUpdated(this.complaints);
  @override
  List<Object?> get props => [complaints];
}

/// Internal event dispatched when the complaints stream encounters an error.
/// Not part of the public API — only dispatched from within the bloc.
class _ComplaintsError extends ComplaintEvent {
  /// The error message from the stream.
  final String error;
  _ComplaintsError(this.error);
  @override
  List<Object?> get props => [error];
}

/// BLoC that manages loading and displaying complaints from Firestore.
///
/// Supports two streaming modes:
/// - **User mode** ([LoadUserComplaints]): fetches complaints filed by the currently signed-in user.
/// - **Admin mode** ([LoadAllComplaints]): fetches all complaints in the collection.
///
/// Events handled:
/// - [LoadUserComplaints]  : Starts a stream filtered to the current user's complaints.
/// - [LoadAllComplaints]   : Starts a stream of all complaints (admin view).
/// - [_ComplaintsUpdated]  : Internal — updates the state with new data from the stream.
/// - [_ComplaintsError]    : Internal — updates the state with a stream error.
class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  /// Repository used for higher-level complaint operations (if needed in the future).
  final ComplaintRepository _repo;

  /// Active Firestore snapshot subscription. Cancelled before starting a new one,
  /// and again when the bloc is closed.
  StreamSubscription<QuerySnapshot>? _complaintsSub;

  /// Creates the bloc and registers event handlers.
  ComplaintBloc({required ComplaintRepository repo})
      : _repo = repo,
        super(const ComplaintState()) {
    on<LoadUserComplaints>(_onLoadUserComplaints);
    on<LoadAllComplaints>(_onLoadAllComplaints);
    on<_ComplaintsUpdated>(_onComplaintsUpdated);
    on<_ComplaintsError>(_onComplaintsError);
  }

  /// Handles [LoadUserComplaints]: streams complaints for the currently logged-in user.
  ///
  /// Requires the user to be authenticated; emits [ComplaintStatus.failure] if not.
  /// Filters the Firestore `complaints` collection by the current user's UID,
  /// ordered by creation date (newest first).
  Future<void> _onLoadUserComplaints(
      LoadUserComplaints event, Emitter<ComplaintState> emit) async {
    emit(state.copyWith(status: ComplaintStatus.loading));
    await _complaintsSub?.cancel();

    // Guard: ensure a user is signed in before querying
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(state.copyWith(
        status: ComplaintStatus.failure,
        error: 'User not authenticated',
      ));
      return;
    }

    // Subscribe to Firestore snapshot for the current user's complaints
    _complaintsSub = FirebaseFirestore.instance
        .collection('complaints')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        try {
          // Map each document to a [Complaint] model object
          final complaints = snapshot.docs
              .map((doc) => Complaint.fromMap(doc.data(), doc.id))
              .toList();
          add(_ComplaintsUpdated(complaints));
        } catch (e) {
          add(_ComplaintsError(e.toString()));
        }
      },
      onError: (e) {
        add(_ComplaintsError(e.toString()));
      },
    );
  }

  /// Handles [LoadAllComplaints]: streams the entire complaints collection.
  ///
  /// Intended for admin/officer screens. Ordered by creation date (newest first).
  /// No user filter is applied — all complaints from all users are included.
  Future<void> _onLoadAllComplaints(
      LoadAllComplaints event, Emitter<ComplaintState> emit) async {
    emit(state.copyWith(status: ComplaintStatus.loading));
    await _complaintsSub?.cancel();

    // Subscribe to the full complaints collection without user filter
    _complaintsSub = FirebaseFirestore.instance
        .collection('complaints')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        try {
          final complaints = snapshot.docs
              .map((doc) => Complaint.fromMap(doc.data(), doc.id))
              .toList();
          add(_ComplaintsUpdated(complaints));
        } catch (e) {
          add(_ComplaintsError(e.toString()));
        }
      },
      onError: (e) {
        add(_ComplaintsError(e.toString()));
      },
    );
  }

  /// Internal handler: updates the state with a fresh list of complaints.
  void _onComplaintsUpdated(
      _ComplaintsUpdated event, Emitter<ComplaintState> emit) {
    emit(state.copyWith(
      status: ComplaintStatus.success,
      complaints: event.complaints,
    ));
  }

  /// Internal handler: transitions the state to failure with the given error message.
  void _onComplaintsError(
      _ComplaintsError event, Emitter<ComplaintState> emit) {
    emit(state.copyWith(
      status: ComplaintStatus.failure,
      error: event.error,
    ));
  }

  /// Cancels the Firestore snapshot subscription when the bloc is disposed
  /// to prevent memory leaks and ghost callbacks.
  @override
  Future<void> close() {
    _complaintsSub?.cancel();
    return super.close();
  }
}
