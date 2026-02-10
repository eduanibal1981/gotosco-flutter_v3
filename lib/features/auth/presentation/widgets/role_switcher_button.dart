import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotosco_v3/features/auth/application/user_session_provider.dart';

/// AppBar button that allows dual-role users to switch between dashboards.
///
/// Only displays if the user has multiple roles (both parent and driver).
class RoleSwitcherButton extends ConsumerWidget {
  const RoleSwitcherButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(userSessionProvider);

    return sessionAsync.when(
      data: (session) {
        if (session == null || !session.isDualRole) {
          return const SizedBox.shrink();
        }

        // Determine the other role (the one NOT currently active)
        final otherRole = session.activeRole == 'driver' ? 'parent' : 'driver';
        final otherRoleName = otherRole == 'driver' ? 'Driver' : 'Parent';

        return IconButton(
          icon: Icon(
            otherRole == 'driver' ? Icons.directions_bus : Icons.people,
          ),
          tooltip: 'Switch to $otherRoleName Mode',
          onPressed: () => _switchRole(context, ref, otherRole),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _switchRole(
    BuildContext context,
    WidgetRef ref,
    String newRole,
  ) async {
    // Update the active role in the provider
    await ref.read(userSessionProvider.notifier).switchRole(newRole);

    // Navigate to the new dashboard
    if (!context.mounted) return;

    if (newRole == 'driver') {
      context.go('/driver-home');
    } else {
      context.go('/parent-home');
    }

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Switched to ${newRole == 'driver' ? 'Driver' : 'Parent'} mode',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
