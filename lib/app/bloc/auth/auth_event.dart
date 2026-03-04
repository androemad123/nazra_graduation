// auth_event.dart
import 'package:equatable/equatable.dart';
import '../../models/app_user.dart';

/// Base class for all authentication events.
///
/// All events extend [Equatable] so the BLoC can efficiently compare them.
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Fired once when the app starts to begin watching the Firebase auth state stream.
///
/// Triggers [AuthBloc] to subscribe to [AuthRepository.authStateChanges].
class AuthAppStarted extends AuthEvent {}

/// Fired when the user wants to sign in with an email and password.
///
/// [email] and [password] are required. The email is trimmed before use.
class AuthLoginRequested extends AuthEvent {
  /// The user's email address (will be trimmed before the API call).
  final String email;

  /// The user's plain-text password (never stored locally).
  final String password;

  AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email];
}

/// Fired when the user wants to create a new account.
///
/// [email] and [password] are required. [displayName] is optional.
class AuthSignUpRequested extends AuthEvent {
  /// The user's desired email address.
  final String email;

  /// The user's chosen password.
  final String password;

  /// Optional display name shown on their profile.
  final String? displayName;

  AuthSignUpRequested({required this.email, required this.password, this.displayName});

  @override
  List<Object?> get props => [email];
}

/// Fired when the user wants to sign out.
class AuthLogoutRequested extends AuthEvent {}

/// Fired when the user requests a password reset link to their email.
class AuthPasswordResetRequested extends AuthEvent {
  /// The email address to send the password reset link to.
  final String email;
  AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Internal event dispatched by the bloc whenever the Firebase auth stream
/// reports a change in the currently signed-in user.
///
/// [user] is null if the user signed out, or a valid [AppUser] if signed in.
/// This event should NOT be dispatched from outside the bloc.
class AuthUserChanged extends AuthEvent {
  /// The new auth state — null means logged out, non-null means logged in.
  final AppUser? user;
  AuthUserChanged({required this.user});

  @override
  List<Object?> get props => [user];
}
