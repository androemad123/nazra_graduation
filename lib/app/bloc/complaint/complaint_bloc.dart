import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/complaint_model.dart';
import '../../repositories/complaint_repository.dart';
import 'complaint_event.dart';
import 'complaint_state.dart';

// Internal events for stream updates
class _ComplaintsUpdated extends ComplaintEvent {
  final List<Complaint> complaints;
  _ComplaintsUpdated(this.complaints);
  @override
  List<Object?> get props => [complaints];
}

class _ComplaintsError extends ComplaintEvent {
  final String error;
  _ComplaintsError(this.error);
  @override
  List<Object?> get props => [error];
}

class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  final ComplaintRepository _repo;
  StreamSubscription<QuerySnapshot>? _complaintsSub;

  ComplaintBloc({required ComplaintRepository repo})
      : _repo = repo,
        super(const ComplaintState()) {
    on<LoadUserComplaints>(_onLoadUserComplaints);
    on<LoadAllComplaints>(_onLoadAllComplaints);
    on<_ComplaintsUpdated>(_onComplaintsUpdated);
    on<_ComplaintsError>(_onComplaintsError);
  }

  Future<void> _onLoadUserComplaints(
      LoadUserComplaints event, Emitter<ComplaintState> emit) async {
    emit(state.copyWith(status: ComplaintStatus.loading));
    await _complaintsSub?.cancel();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(state.copyWith(
        status: ComplaintStatus.failure,
        error: 'User not authenticated',
      ));
      return;
    }

    _complaintsSub = FirebaseFirestore.instance
        .collection('complaints')
        .where('userId', isEqualTo: user.uid)
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

  Future<void> _onLoadAllComplaints(
      LoadAllComplaints event, Emitter<ComplaintState> emit) async {
    emit(state.copyWith(status: ComplaintStatus.loading));
    await _complaintsSub?.cancel();

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

  void _onComplaintsUpdated(
      _ComplaintsUpdated event, Emitter<ComplaintState> emit) {
    emit(state.copyWith(
      status: ComplaintStatus.success,
      complaints: event.complaints,
    ));
  }

  void _onComplaintsError(
      _ComplaintsError event, Emitter<ComplaintState> emit) {
    emit(state.copyWith(
      status: ComplaintStatus.failure,
      error: event.error,
    ));
  }

  @override
  Future<void> close() {
    _complaintsSub?.cancel();
    return super.close();
  }
}

