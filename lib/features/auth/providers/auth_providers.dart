import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_notes/features/auth/data/auth_repository.dart';
import 'package:quick_notes/features/auth/domain/user_model.dart';
import 'package:quick_notes/features/session/providers/session_providers.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = await ref.watch(authStateProvider.future);
  if (authState == null) return null;
  return ref.read(authRepositoryProvider).getCurrentUser();
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(authRepositoryProvider).login(username, password);
      await _ref.read(sessionProvider.notifier).refreshSession();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> register(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      await _ref
          .read(authRepositoryProvider)
          .register(username, password);
      await _ref.read(sessionProvider.notifier).refreshSession();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(authRepositoryProvider).logout();
      await _ref.read(sessionProvider.notifier).refreshSession();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
  (ref) => AuthNotifier(ref),
);
