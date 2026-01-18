// lib/core/providers/user_session_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_session.dart';
import 'shared_preferences_provider.dart';

part 'user_session_provider.g.dart';

/// Provider for the current user session.
///
/// Loads user data from the database and provides role switching functionality.
/// Automatically refreshes when auth state changes.
@riverpod
class UserSessionNotifier extends _$UserSessionNotifier {
  @override
  Future<UserSession?> build() async {
    // Listen to auth state changes to rebuild
    ref.listen(_authStateProvider, (_, __) => ref.invalidateSelf());

    // Preload shared preferences
    final prefs = await ref.watch(sharedPreferencesProvider.future);

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    try {
      final userData = await Supabase.instance.client
          .from('users')
          .select('*')
          .eq('id', user.id)
          .single();

      final roles = List<String>.from(userData['role'] ?? []);

      // If user has no roles, return null to trigger role selection
      if (roles.isEmpty) return null;

      // Get the last active role from local storage or default to first role
      final activeRole = _getLastActiveRole(roles, prefs);

      return UserSession(
        userId: user.id,
        fullName: userData['full_name'] ?? 'User',
        email: userData['email'],
        phone: userData['phone'],
        photoUrl: userData['photo_url'],
        roles: roles,
        activeRole: activeRole,
        authProvider: userData['auth_provider'] ?? 'phone',
      );
    } catch (e) {
      // If user doesn't exist in public.users yet, return null
      return null;
    }
  }

  /// Switch to a different role.
  /// Only works if the user has the target role.
  Future<void> switchRole(String newRole) async {
    final session = state.value;
    if (session == null || !session.roles.contains(newRole)) return;

    state = AsyncData(session.copyWith(activeRole: newRole));

    // Save to local storage for persistence
    await _saveLastActiveRole(newRole);
  }

  /// Add a new role to the user's account.
  Future<void> addRole(String newRole) async {
    final session = state.value;
    if (session == null || session.roles.contains(newRole)) return;

    final updatedRoles = [...session.roles, newRole];

    await Supabase.instance.client
        .from('users')
        .update({'role': updatedRoles})
        .eq('id', session.userId);

    state = AsyncData(session.copyWith(roles: updatedRoles));
  }

  /// Get the last active role from local storage
  String _getLastActiveRole(List<String> roles, SharedPreferences prefs) {
    try {
      final lastRole = prefs.getString('last_active_role');

      // If we have a saved role and it's still valid, use it
      if (lastRole != null && roles.contains(lastRole)) {
        return lastRole;
      }
    } catch (e) {
      // If there's an error reading preferences, just continue
      print('Error reading last active role: $e');
    }

    // Default to first role if no saved preference or error
    return roles.first;
  }

  /// Save the active role to local storage
  Future<void> _saveLastActiveRole(String role) async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString('last_active_role', role);
    } catch (e) {
      print('Error saving last active role: $e');
    }
  }
}

/// Internal provider to watch auth state changes
@riverpod
Stream<AuthState> _authState(Ref ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
}
