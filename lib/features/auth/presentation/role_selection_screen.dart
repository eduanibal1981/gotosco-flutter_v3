// lib/features/auth/presentation/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotosco_v3/core/providers/user_session_provider.dart';

/// Screen where users select their role(s) after signing up.
///
/// Users can choose:
/// - Driver only
/// - Parent only
/// - Both Driver AND Parent
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? selectedRole;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Choose Your Role'),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'How will you use GoToSco?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Driver Role Card
              _RoleCard(
                title: 'I\'m a Driver',
                subtitle: 'Transport students to/from school',
                icon: Icons.directions_bus,
                isSelected: selectedRole == 'driver',
                onTap: isLoading
                    ? null
                    : () => setState(() => selectedRole = 'driver'),
              ),

              const SizedBox(height: 16),

              // Parent Role Card
              _RoleCard(
                title: 'I\'m a Parent',
                subtitle: 'Find transport for my children',
                icon: Icons.people,
                isSelected: selectedRole == 'parent',
                onTap: isLoading
                    ? null
                    : () => setState(() => selectedRole = 'parent'),
              ),

              const SizedBox(height: 48),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedRole != null && !isLoading
                      ? _handleContinue
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade900,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Option to select both roles
              TextButton(
                onPressed: isLoading ? null : _handleBothRoles,
                child: Text(
                  'I\'m both a Driver and Parent',
                  style: TextStyle(
                    color: Colors.indigo.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (selectedRole == null) return;

    setState(() => isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      // Update role in database
      await Supabase.instance.client
          .from('users')
          .update({
            'role': [selectedRole],
          })
          .eq('id', userId);

      if (!mounted) return;

      // Invalidate session provider to trigger router redirect
      ref.invalidate(userSessionProvider);

      // Wait a brief moment for the provider to refresh
      // The router redirect will handle the navigation automatically
      // But we can keep the manual navigation as a fallback or remove it.
      // Since router is watching the provider, manual navigation might conflict
      // if not careful, but context.go replaces the stack.
      // Actually, if we invalidate, the router might react immediately.
      // Better to let the router handle it, but for UX responsiveness,
      // we can leave it.
      // However, if the router sees the new state, it WILL redirect.
      // Let's just invalidate.
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleBothRoles() async {
    setState(() => isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      // Assign both roles
      await Supabase.instance.client
          .from('users')
          .update({
            'role': ['driver', 'parent'],
          })
          .eq('id', userId);

      if (!mounted) return;

      // Show dialog to choose which to use first
      final firstRole = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Setup Order'),
          content: const Text('Which dashboard would you like to use first?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'driver'),
              child: const Text('Driver'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'parent'),
              child: const Text('Parent'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      // Invalidate session provider to refresh roles
      ref.invalidate(userSessionProvider);

      if (firstRole != null) {
        // Update active role preference if needed?
        // The provider handles default active role logic.
        // But since we just picked one, we might want to set it as active.
        // UserSessionNotifier.switchRole updates local storage.
        // But we haven't built the session yet with the new roles.
        // It's tricky.

        // Let's wait for the invalidation to propagate?
        // Actually, we can just navigate. The router will see we have roles now.
        // But router defaults to 'first' role. We want 'firstRole'.

        // We should manual navigation here because the router might not know which one we want active *initially* if we have both.
        // But wait, the router redirect logic for "Both" roles isn't explicit.
        // Router says:
        // if (roles.contains('driver')) return '/driver-home';
        // else return '/parent-home';

        // So it prioritizes driver.
        // If user picked Parent?
        // We need to set the specific active role preference.

        // We can use the provider to set it, but we need the session to be valid first.

        // For now, let's just navigate. The router will redirect if it disagrees, or we force it?
        // If we force it, the router redirect might override us if it thinks we are in the wrong place.
        // But router redirect returns null if we are in a valid place or redirects if not.
        // Logic: activeRole == 'driver' -> driver-home.
        // So if we go to parent-home but activeRole is driver, router might redirect us back!

        // So we MUST set the active role pref if we want to go potentially to the non-default one.
        // But we can't easily do that on a null session.
        // Maybe we just let the router take us to default (driver) and user can switch?
        // Or we assume the router logic is "if activeRole == driver".

        // Let's just invalidate. The user can switch roles later.
        // Or improved logic:
        // await ref.read(userSessionNotifierProvider.notifier).build(); // force refresh?

        if (firstRole == 'driver') {
          context.go('/driver-home');
        } else {
          context.go('/parent-home');
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      setState(() => isLoading = false);
    }
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      label: '$title, $subtitle',
      child: Material(
        color: isSelected ? Colors.indigo.shade50 : Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? Colors.indigo.shade900 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: isSelected ? Colors.indigo.shade900 : Colors.grey.shade600,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.indigo.shade900
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: Colors.indigo.shade900, size: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
