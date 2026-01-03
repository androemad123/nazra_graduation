import 'package:equatable/equatable.dart';
import '../../models/community.dart';

enum CommunityStatus { initial, loading, success, failure }

class CommunityState extends Equatable {
  final CommunityStatus status;
  final List<Community> communities;
  final String? error;

  const CommunityState({
    this.status = CommunityStatus.initial,
    this.communities = const [],
    this.error,
  });

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
