// auth_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

/// Custom exception type for authentication failures.
///
/// Wraps Firebase error messages into a consistent, user-friendly format.
/// Thrown by [AuthRepository] methods so that [AuthBloc] can distinguish
/// auth-specific failures from unexpected runtime errors.
class AuthFailure implements Exception {
  /// A human-readable description of what went wrong.
  final String message;
  AuthFailure(this.message);

  @override
  String toString() => 'AuthFailure: $message';
}

/// Repository that abstracts all Firebase Authentication and user profile operations.
///
/// Acts as the single source of truth for auth state and user data.
/// All Firebase API calls are wrapped here so the rest of the app (BLoC layer)
/// can remain independent of the Firebase SDK.
///
/// Responsibilities:
/// - Listen to auth state changes and map them to [AppUser] objects.
/// - Sign users up and save their profile to Firestore.
/// - Sign users in and retrieve their Firestore profile.
/// - Sign users out.
/// - Send password reset and email verification links.
class AuthRepository {
  /// Firebase Authentication instance used for all auth operations.
  final FirebaseAuth _auth;

  /// Firestore instance used to read/write user profiles in the `users` collection.
  final FirebaseFirestore _firestore;

  /// Creates the repository with optional injectable dependencies.
  ///
  /// Defaults to the singleton instances, enabling easy substitution in tests.
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Returns a stream that emits an [AppUser] when a user is signed in,
  /// or null when signed out.
  ///
  /// Internally maps Firebase's [User] to our [AppUser] by looking up (or creating)
  /// the user's Firestore profile document on every auth state change.
  ///
  /// If the Firestore document does not exist (e.g., first sign-in via a
  /// different auth provider), a minimal profile is created automatically.
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!, user.uid);
      } else {
        // Create a minimal profile if the Firestore document is missing
        final profile = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          role: 'user',
        );
        await _firestore.collection('users').doc(user.uid).set(profile.toMap());
        return profile;
      }
    });
  }

  /// Creates a new Firebase Auth user with [email] and [password],
  /// updates their display name, and saves a profile to Firestore.
  ///
  /// Returns the newly created [AppUser] on success.
  /// Throws [AuthFailure] on any Firebase or unexpected error.
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) throw AuthFailure('Failed to create user.');

      // Update the Firebase Auth display name
      if (displayName != null && displayName.trim().isNotEmpty) {
        await user.updateDisplayName(displayName);
      }

      // Persist the user profile to Firestore
      final appUser = AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: displayName ?? '',
        role: 'user',
      );
      await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseAuthException(e));
    } catch (e) {
      throw AuthFailure('Unknown error during sign up.');
    }
  }

  /// Signs in an existing user with [email] and [password].
  ///
  /// Fetches the user's Firestore profile after a successful sign-in.
  /// Creates a minimal profile if one doesn't exist yet (defensive fallback).
  ///
  /// Returns the [AppUser] on success.
  /// Throws [AuthFailure] with a user-friendly message on any error.
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) throw AuthFailure('Failed to sign in.');

      // Try to fetch the existing Firestore profile
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!, user.uid);
      } else {
        // Defensive: create a profile if it somehow doesn't exist
        final appUser = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          role: 'user',
        );
        await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
        return appUser;
      }
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseAuthException(e));
    } catch (e) {
      throw AuthFailure('Unknown error during sign in.');
    }
  }

  /// Signs the current user out of Firebase Auth.
  ///
  /// Throws [AuthFailure] if the sign-out call fails unexpectedly.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthFailure('Failed to sign out.');
    }
  }

  /// Sends a password reset email to the given [email] address.
  ///
  /// Throws [AuthFailure] if the email is not registered or the request fails.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseAuthException(e));
    } catch (e) {
      throw AuthFailure('Failed to send password reset email.');
    }
  }

  /// Returns the currently signed-in [AppUser] by fetching their Firestore profile,
  /// or null if no user is signed in.
  ///
  /// Falls back to a minimal [AppUser] if the Firestore document is missing.
  Future<AppUser?> get currentUser async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data()!, user.uid);
    }
    // Defensive fallback — should rarely happen in practice
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      role: 'user',
    );
  }

  /// Sends an email verification link to the currently signed-in user.
  ///
  /// Throws [AuthFailure] if no user is logged in or the send fails.
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw AuthFailure('No logged in user.');
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseAuthException(e));
    } catch (e) {
      throw AuthFailure('Failed to send email verification.');
    }
  }

  /// Checks whether the currently signed-in user has verified their email address.
  ///
  /// Forces a Firebase token refresh ([user.reload]) to get the latest server state.
  /// Returns false if no user is signed in.
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload(); // Refresh user data from Firebase to get latest verification status
    return user.emailVerified;
  }

  /// Converts a [FirebaseAuthException] error code into a user-friendly message.
  ///
  /// This keeps Firebase-specific error codes out of the UI layer.
  String _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Check Firebase console.';
      default:
        return e.message ?? 'Authentication error: ${e.code}';
    }
  }
}
