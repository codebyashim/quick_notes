import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quick_notes/features/auth/presentation/login_screen.dart';
import 'package:quick_notes/features/auth/presentation/register_screen.dart';
import 'package:quick_notes/features/auth/presentation/profile_screen.dart';
import 'package:quick_notes/features/auth/providers/auth_providers.dart';
import 'package:quick_notes/features/notes/presentation/notes_screen.dart';
import 'package:quick_notes/features/notes/presentation/note_editor_screen.dart';
import 'package:quick_notes/features/files/presentation/files_screen.dart';
import 'package:quick_notes/features/session/providers/session_providers.dart';
import 'package:quick_notes/shared/widgets/app_scaffold.dart';

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF313338),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.note_alt_rounded,
                size: 64, color: Color(0xFF5865F2)),
            SizedBox(height: 16),
            Text(
              'Quick Notes',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF2F3F5),
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: Color(0xFF5865F2),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    _ref.listen(sessionProvider, (_, __) => notifyListeners());
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final session = _ref.read(sessionProvider);
    final location = state.matchedLocation;

    // Still loading - stay on splash
    if (session.isLoading) {
      return location == '/splash' ? null : '/splash';
    }

    final isValid = session.maybeWhen(
      data: (uid) => uid != null,
      orElse: () => false,
    );

    final isAuthRoute =
        location == '/login' || location == '/register';

    if (!isValid && !isAuthRoute) return '/login';
    if (isValid && (isAuthRoute || location == '/splash')) {
      return '/dashboard/notes';
    }

    return null;
  }
}

final _routerNotifierProvider = Provider<_RouterNotifier>(
  (ref) => _RouterNotifier(ref),
);

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/notes/new',
        builder: (_, __) => const NoteEditorScreen(noteId: null),
      ),
      GoRoute(
        path: '/notes/:noteId',
        builder: (_, state) =>
            NoteEditorScreen(noteId: state.pathParameters['noteId']!),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard/notes',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: NotesScreen()),
          ),
          GoRoute(
            path: '/dashboard/files',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: FilesScreen()),
          ),
          GoRoute(
            path: '/dashboard/profile',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
    ],
  );
});
