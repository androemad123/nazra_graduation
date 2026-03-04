// auth_state.dart
import 'package:equatable/equatable.dart';
import '../../models/app_user.dart';

/// Represents the possible authentication statuses of the app.
///
/// - [unknown]         : Initial state before Firebase has reported the auth status.
/// - [authenticated]   : A user is signed in.
/// - [unauthenticated] : No user is signed in.
/// - [loading]         : An auth operation (login, sign-up, logout…) is in progress.
/// - [failure]         : The last auth operation failed.
enum AuthStatus { unknown, authenticated, unauthenticated, loading, failure }

/// Represents the complete authentication state of the app.
///
/// Uses named constructors (factory-style constant constructors) for each
/// possible scenario, keeping state creation readable and intentional.
class AuthState extends Equatable {
  /// The current authentication status.
  final AuthStatus status;

  /// The signed-in user — only non-null when [status] is [AuthStatus.authenticated].
  final AppUser? user;

  /// An error message — only non-null when [status] is [AuthStatus.failure].
  final String? error;

  /// Private constructor used by the named constructors below.
  const AuthState._({
    required this.status,
    this.user,
    this.error,
  });

  /// Initial state before Firebase has returned any auth information.
  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  /// State indicating a user is signed in.
  /// [user] is the authenticated [AppUser] profile fetched from Firestore.
  const AuthState.authenticated(AppUser user)
      : this._(status: AuthStatus.authenticated, user: user);

  /// State indicating no user is currently signed in.
  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  /// State indicating an auth operation is currently in progress.
  /// The UI should show a loading indicator in this state.
  const AuthState.loading() : this._(status: AuthStatus.loading);

  /// State indicating the last auth operation failed.
  /// [error] contains a human-readable message describing what went wrong.
  const AuthState.failure(String error)
      : this._(status: AuthStatus.failure, error: error);

  @override
  List<Object?> get props => [status, user, error];
}
