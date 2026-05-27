import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_notes/core/constants/app_constants.dart';
import 'package:quick_notes/core/errors/app_exception.dart';
import 'package:quick_notes/features/auth/domain/user_model.dart';
import 'package:quick_notes/features/session/data/session_repository.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final Ref _ref;

  AuthRepository(this._auth, this._firestore, this._ref);

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(AppConstants.usersCollection);

  String _toEmail(String username) =>
      '${username.toLowerCase().trim()}${AppConstants.syntheticEmailDomain}';

  Future<bool> checkUsernameAvailable(String username) async {
    final q =
        await _usersRef
            .where('username', isEqualTo: username.toLowerCase().trim())
            .limit(1)
            .get();
    return q.docs.isEmpty;
  }

  Future<UserModel> register(String username, String password) async {
    final clean = username.toLowerCase().trim();

    if (clean.length < 3 || clean.length > 20) {
      throw const ValidationException(
        'Username must be between 3 and 20 characters',
      );
    }
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(clean)) {
      throw const ValidationException(
        'Username can only contain letters, numbers, and underscores',
      );
    }
    if (password.length < 6) {
      throw const ValidationException('Password must be at least 6 characters');
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _toEmail(clean),
        password: password,
      );
      final uid = credential.user!.uid;
      final now = DateTime.now();

      final user = UserModel(
        uid: uid,
        username: clean,
        sessionVersion: 1,
        createdAt: now,
        lastLoginAt: now,
      );

      await _usersRef.doc(uid).set(user.toMap());
      await _ref.read(sessionRepositoryProvider).createSession(uid, 1);

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  Future<UserModel> login(String username, String password) async {
    final clean = username.toLowerCase().trim();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _toEmail(clean),
        password: password,
      );
      final uid = credential.user!.uid;

      final userDoc = await _usersRef.doc(uid).get();
      if (!userDoc.exists) {
        throw const AuthException(
          'Account data not found. Please contact support.',
        );
      }

      final user = UserModel.fromMap(userDoc.data()!);

      await _usersRef.doc(uid).update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });

      await _ref
          .read(sessionRepositoryProvider)
          .createSession(uid, user.sessionVersion);

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  Future<void> logout() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _ref
            .read(sessionRepositoryProvider)
            .invalidateAllSessions(user.uid);
      } catch (_) {}
    }
    await _ref.read(sessionRepositoryProvider).clearLocalSession();
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;
    try {
      final doc = await _usersRef.doc(fbUser.uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid username or password';
      case 'invalid-email':
        return 'Invalid username. Do not include @ or email address.';
      case 'email-already-in-use':
        return 'Username is already taken';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance, ref);
});
