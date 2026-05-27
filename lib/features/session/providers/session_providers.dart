import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_notes/core/utils/date_utils.dart';
import 'package:quick_notes/features/session/data/session_repository.dart';

class SessionNotifier extends StateNotifier<AsyncValue<String?>> {
  final Ref _ref;
  Timer? _midnightTimer;

  SessionNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await refreshSession();
    _scheduleMidnightTimer();
  }

  Future<void> refreshSession() async {
    state = const AsyncValue.loading();
    try {
      final uid =
          await _ref.read(sessionRepositoryProvider).validateSession();
      state = AsyncValue.data(uid);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _scheduleMidnightTimer() {
    _midnightTimer?.cancel();
    final midnight = AppDateUtils.getNextMidnight();
    final delay = midnight.difference(DateTime.now());
    _midnightTimer = Timer(delay, () {
      // Session expired at midnight - force re-validation (will return null)
      refreshSession();
      _scheduleMidnightTimer();
    });
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, AsyncValue<String?>>(
  (ref) => SessionNotifier(ref),
);

final isSessionValidProvider = Provider<bool>((ref) {
  final session = ref.watch(sessionProvider);
  return session.maybeWhen(
    data: (uid) => uid != null,
    orElse: () => false,
  );
});
