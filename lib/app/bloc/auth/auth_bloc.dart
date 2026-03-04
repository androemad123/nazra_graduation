// auth_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../repositories/auth_repository.dart';
import '../../models/app_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC that manages the authentication lifecycle of the app.
///
/// Listens to Firebase Auth state changes via a stream subscription and maps them
/// to [AuthState] values. All auth operations (login, sign-up, logout, password reset)
/// are delegated to [AuthRepository].
///
/// On creation, immediately dispatches [AuthAppStarted] to begin listening for
/// auth state changes from Firebase.
///
/// Events handled:
/// - [AuthAppStarted]            : Starts listening to the auth stream.
/// - [AuthUserChanged]           : Fires whenever Firebase reports an auth change (login/logout).
/// - [AuthLoginRequested]        : Initiates the sign-in flow with email & password.
/// - [AuthSignUpRequested]       : Initiates the registration flow.
/// - [AuthLogoutRequested]       : Signs the current user out.
/// - [AuthPasswordResetRequested]: Sends a password reset email.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Repository that abstracts all Firebase Auth and Firestore user profile calls.
  final AuthRepository _authRepository;

  /// Subscription to the Firebase auth state stream.
  /// Cancelled on [close] to prevent memory leaks.
  StreamSubscription<AppUser?>? _userSub;

  /// Creates the bloc, registers event handlers, and immediately starts
  /// listening to auth state changes by dispatching [AuthAppStarted].
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unknown()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);

    // Kick off the auth stream as soon as the bloc is created
    add(AuthAppStarted());
  }

  /// Handles [AuthAppStarted]: subscribes to the repository's auth state stream.
  ///
  /// Each time Firebase emits a new user (or null on logout), an [AuthUserChanged]
  /// event is dispatched to update the state.
  Future<void> _onAppStarted(AuthAppStarted event, Emitter<AuthState> emit) async {
    await _userSub?.cancel();
    _userSub = _authRepository.authStateChanges().listen((appUser) {
      add(AuthUserChanged(user: appUser));
    });
  }

  /// Handles [AuthUserChanged]: updates the state based on whether a user is present.
  ///
  /// - User is non-null → emits [AuthState.authenticated].
  /// - User is null     → emits [AuthState.unauthenticated].
  Future<void> _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) async {
    final user = event.user;
    if (user != null) {
      emit(AuthState.authenticated(user));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  /// Handles [AuthLoginRequested]: signs the user in with email and password.
  ///
  /// Emits [AuthState.loading] while the request is in flight.
  /// On success, emits [AuthState.authenticated].
  /// On [AuthFailure] or any other error, emits [AuthState.failure] followed by
  /// [AuthState.unauthenticated] to reset the UI.
  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.signInWithEmail(email: event.email.trim(), password: event.password);
      emit(AuthState.authenticated(user));
    } on AuthFailure catch (e) {
      emit(AuthState.failure(e.message));
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(const AuthState.failure('Unknown login error'));
      emit(const AuthState.unauthenticated());
    }
  }

  /// Handles [AuthSignUpRequested]: creates a new user account with email and password.
  ///
  /// Also stores the user's display name in Firebase Auth and Firestore.
  /// Emits [AuthState.loading] → [AuthState.authenticated] on success.
  /// Emits [AuthState.failure] → [AuthState.unauthenticated] on any error.
  Future<void> _onSignUpRequested(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.signUpWithEmail(
          email: event.email.trim(), password: event.password, displayName: event.displayName);
      emit(AuthState.authenticated(user));
    } on AuthFailure catch (e) {
      emit(AuthState.failure(e.message));
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(const AuthState.failure('Unknown sign up error'));
      emit(const AuthState.unauthenticated());
    }
  }

  /// Handles [AuthLogoutRequested]: signs the current user out of Firebase.
  ///
  /// Emits [AuthState.loading] while the sign-out request is in flight.
  /// On success, emits [AuthState.unauthenticated].
  /// On failure, emits [AuthState.failure] (remains in failure state so UI can show error).
  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.signOut();
      emit(const AuthState.unauthenticated());
    } on AuthFailure catch (e) {
      emit(AuthState.failure(e.message));
    } catch (e) {
      emit(const AuthState.failure('Unknown logout error'));
    }
  }

  /// Handles [AuthPasswordResetRequested]: sends a password reset email.
  ///
  /// Emits [AuthState.loading] → [AuthState.unauthenticated] on success
  /// (treated as "done", user should check their email).
  /// Emits [AuthState.failure] if the email is invalid or the request fails.
  Future<void> _onPasswordResetRequested(AuthPasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.sendPasswordResetEmail(email: event.email.trim());
      emit(const AuthState.unauthenticated());
    } on AuthFailure catch (e) {
      emit(AuthState.failure(e.message));
    } catch (e) {
      emit(const AuthState.failure('Unknown password reset error'));
    }
  }

  /// Cancels the Firebase auth stream subscription when the bloc is disposed.
  @override
  Future<void> close() {
    _userSub?.cancel();
    return super.close();
  }
}
