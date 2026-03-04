import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

/// Repository for fetching user profiles from Firestore.
///
/// Provides simple read access to the `users` collection.
/// Does not support creating or updating users — those operations
/// are handled by [AuthRepository].
class UserRepository {
  /// Firestore instance used for all user profile queries.
  final FirebaseFirestore _firestore;

  /// Creates the repository with an optional injectable [FirebaseFirestore] instance.
  ///
  /// Defaults to the singleton [FirebaseFirestore.instance].
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches a single user profile by their [uid] (Firebase Auth UID).
  ///
  /// Returns the [AppUser] if the document exists, or null if not found.
  /// Errors are caught and printed — returns null on failure.
  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!, uid);
      }
      return null; // Document doesn't exist
    } catch (e) {
      print('Error fetching user $uid: $e');
      return null;
    }
  }

  /// Fetches the profiles of multiple users by their UIDs.
  ///
  /// Returns an empty list if [uids] is empty.
  ///
  /// ⚠️ Implementation note: Currently fetches users individually in a loop.
  /// This is simple and works well for small lists (<10 users). For larger lists,
  /// consider batching using Firestore's `where('uid', whereIn: uids)` query
  /// (limited to 10 items per query) or parallel fetches with [Future.wait].
  Future<List<AppUser>> getUsers(List<String> uids) async {
    if (uids.isEmpty) return [];
    try {
      // Individual fetches — acceptable for small lists; see note above for alternatives
      final List<AppUser> users = [];
      for (final uid in uids) {
        final user = await getUser(uid);
        if (user != null) {
          users.add(user);
        }
      }
      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }
}
