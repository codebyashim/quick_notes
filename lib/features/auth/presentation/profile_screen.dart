import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_notes/core/utils/date_utils.dart';
import 'package:quick_notes/features/auth/providers/auth_providers.dart';
import 'package:quick_notes/shared/widgets/confirm_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final isLoggingOut = ref.watch(authNotifierProvider).isLoading;
    final midnight = AppDateUtils.getNextMidnight();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not signed in'));
          }
          final initials = user.username
              .substring(
                  0, user.username.length >= 2 ? 2 : 1)
              .toUpperCase();

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: const Color(0xFF5865F2),
                      child: Text(
                        initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(user.username,
                        style:
                            Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Member since ${AppDateUtils.formatDate(user.createdAt)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _InfoCard(
                icon: Icons.access_time_rounded,
                title: 'Session Expires',
                value:
                    'Today at midnight (${AppDateUtils.formatTime(midnight)})',
                subtitle: 'You will be signed out automatically at midnight',
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.login_rounded,
                title: 'Last Sign In',
                value: AppDateUtils.formatDateTime(user.lastLoginAt),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Security',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isLoggingOut
                      ? null
                      : () async {
                          final confirmed = await showConfirmDialog(
                            context,
                            title: 'Sign Out All Devices',
                            message:
                                'This will immediately sign out your account on ALL devices. You will need to sign in again.',
                            confirmLabel: 'Sign Out All',
                            destructive: true,
                          );
                          if (confirmed && context.mounted) {
                            await ref
                                .read(authNotifierProvider.notifier)
                                .logout();
                            if (context.mounted) context.go('/login');
                          }
                        },
                  icon: isLoggingOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.logout),
                  label: const Text('Sign Out All Devices'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFED4245),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Center(
                child: Text(
                  'Quick Notes v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF5865F2), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 2),
                  Text(value,
                      style: Theme.of(context).textTheme.bodyLarge),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
