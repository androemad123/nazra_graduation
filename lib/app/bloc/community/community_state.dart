import 'package:equatable/equatable.dart';
import '../../models/community.dart';

/// Represents all possible statuses of the community data loading lifecycle.
///
/// - [initial] : No data has been requested yet.
/// - [loading] : A Firestore operation is in progress.
/// - [success] : Data has been successfully loaded or written.
/// - [failure] : A Firestore operation failed.
enum CommunityStatus { initial, loading, success, failure }

/// Immutable state object for the [CommunityBloc].
///
/// Holds the current list of communities, the load status, and any error message.
/// Uses [copyWith] to produce modified copies rather than mutating in place.
class CommunityState extends Equatable {
  /// The current data loading/operation status.
  final CommunityStatus status;

  /// The list of communities fetched from Firestore. Empty until first load.
  final List<Community> communities;

  /// An error message — set when [status] is [CommunityStatus.failure].
  final String? error;

  const CommunityState({
    this.status = CommunityStatus.initial,
    this.communities = const [],
    this.error,
  });

  /// Creates a modified copy of this state with selective field overrides.
  ///
  /// Any field not provided defaults to the current value.
  CommunityState copyWith({
    CommunityStatus? status,
    List<Community>? communities,
    String? error,
  }) {
    return CommunityState(
      status: status ?? this.status,
      communities: communities ?? this.communities,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, communities, error];
}
