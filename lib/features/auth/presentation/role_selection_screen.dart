// lib/features/auth/presentation/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

      // Navigate to appropriate dashboard
      if (selectedRole == 'driver') {
        context.go('/driver-home');
      } else {
        context.go('/parent-home');
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

      if (firstRole != null) {
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.indigo.shade900 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? Colors.indigo.shade50 : Colors.white,
        ),
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
    );
  }
}
