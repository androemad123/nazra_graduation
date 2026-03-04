// app_user.dart

/// Represents a signed-in user of the application.
///
/// [AppUser] is the app-level user model — distinct from Firebase's own [User] class.
/// It holds fields fetched from (or written to) the `users` Firestore collection,
/// including the user's role which determines their permissions in the app.
///
/// Roles:
/// - `'user'`   : Regular citizen — can file complaints and join communities.
/// - `'officer'`: Municipal officer — can view all complaints and update their status.
/// - `'admin'`  : Administrator — full access.
class AppUser {
  /// Firebase Authentication UID — used as the Firestore document ID in `users`.
  final String uid;

  /// The user's email address, sourced from Firebase Auth.
  final String email;

  /// Optional display name shown in the UI (e.g., on complaints and community posts).
  final String? displayName;

  /// Optional phone number (reserved for future use or profile display).
  final String? phoneNumber;

  /// The user's role in the system. Defaults to `'user'`.
  final String role;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.role = 'user',
  });

  /// Serialises this [AppUser] to a Firestore-compatible map.
  ///
  /// Used when creating or updating the user's document in the `users` collection.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'role': role,
    };
  }

  /// Creates an [AppUser] from a Firestore document map.
  ///
  /// [map] is the raw `data()` from the `users` document snapshot.
  /// [uid] is the Firestore document ID (same as the Firebase Auth UID).
  ///
  /// [role] defaults to `'user'` if not present in the document.
  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      phoneNumber: map['phoneNumber'],
      role: map['role'] ?? 'user',
    );
  }
}
