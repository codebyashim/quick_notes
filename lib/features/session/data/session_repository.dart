import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:quick_notes/core/constants/app_constants.dart';
import 'package:quick_notes/core/utils/date_utils.dart';
import 'package:quick_notes/features/session/data/session_model.dart';
import 'package:quick_notes/services/storage_service.dart';

class SessionRepository {
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;

  SessionRepository(this._firestore, this._prefs);

  CollectionReference<Map<String, dynamic>> get _sessionsRef =>
      _firestore.collection(AppConstants.sessionsCollection);

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(AppConstants.usersCollection);

  Future<String> createSession(String uid, int sessionVersion) async {
    final sessionId = const Uuid().v4();
    final now = DateTime.now();
    final expiresAt = AppDateUtils.getNextMidnight();

    final session = SessionModel(
      sessionId: sessionId,
      uid: uid,
      sessionVersion: sessionVersion,
      createdAt: now,
      expiresAt: expiresAt,
    );

    await _sessionsRef.doc(sessionId).set(session.toMap());
    await _prefs.setString(AppConstants.sessionIdKey, sessionId);
    return sessionId;
  }

  /// Returns uid if session is valid, null otherwise.
  Future<String?> validateSession() async {
    final sessionId = _prefs.getString(AppConstants.sessionIdKey);
    if (sessionId == null || sessionId.isEmpty) return null;

    try {
      final doc = await _sessionsRef.doc(sessionId).get();
      if (!doc.exists || doc.data() == null) {
        await clearLocalSession();
        return null;
      }

      final session = SessionModel.fromMap(doc.data()!);

      if (AppDateUtils.isExpired(session.expiresAt)) {
        await clearLocalSession();
        return null;
      }

      // Verify sessionVersion against current user doc (cross-device logout check)
      final userDoc = await _usersRef.doc(session.uid).get();
      if (!userDoc.exists || userDoc.data() == null) {
        await clearLocalSession();
        return null;
      }

      final currentVersion =
          (userDoc.data()!['sessionVersion'] as num).toInt();
      if (session.sessionVersion != currentVersion) {
        await clearLocalSession();
        return null;
      }

      return session.uid;
    } catch (_) {
      return null;
    }
  }

  /// Increment sessionVersion to invalidate ALL active sessions on all devices.
  Future<void> invalidateAllSessions(String uid) async {
    await _firestore.runTransaction((tx) async {
      final userRef = _usersRef.doc(uid);
      final snap = await tx.get(userRef);
      if (!snap.exists) return;
      final currentVersion =
          (snap.data()!['sessionVersion'] as num).toInt();
      tx.update(userRef, {'sessionVersion': currentVersion + 1});
    });
  }

  Future<void> deleteCurrentSession() async {
    final sessionId = _prefs.getString(AppConstants.sessionIdKey);
    if (sessionId != null && sessionId.isNotEmpty) {
      try {
        await _sessionsRef.doc(sessionId).delete();
      } catch (_) {}
    }
    await clearLocalSession();
  }

  Future<void> clearLocalSession() async {
    await _prefs.remove(AppConstants.sessionIdKey);
  }

  String? getLocalSessionId() =>
      _prefs.getString(AppConstants.sessionIdKey);
}

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(
    FirebaseFirestore.instance,
    ref.watch(sharedPreferencesProvider),
  );
});
