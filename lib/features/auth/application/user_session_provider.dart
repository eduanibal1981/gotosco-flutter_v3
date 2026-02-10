import 'package:gotosco_v3/core/models/user_session.dart';
import 'package:gotosco_v3/core/providers/shared_preferences_provider.dart';
import 'package:gotosco_v3/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gotosco_v3/features/auth/domain/models/auth_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_session_provider.g.dart';

/// Provider for the current user session.
/// Loads user data from the database and provides role switching functionality.
/// Automatically refreshes when auth state changes.
@riverpod
class UserSessionNotifier extends _$UserSessionNotifier {
  @override
  Future<UserSession?> build() async {
    // Listen to auth state changes to rebuild
    // We bind to the stream value. If it changes, this provider rebuilds
    // based on ref.watch below.

    final authState = ref.watch(authStateChangesProvider);

    // If loading or error, we might propagate that or return null.
    // If data is null (logged out), return null.
    final authUser = authState.asData?.value;

    if (authUser == null) return null;

    final repo = ref.read(authRepositoryProvider);

    // Preload shared preferences
    final prefs = await ref.watch(sharedPreferencesProvider.future);

    try {
      final userData = await repo.getUserProfile(authUser.id);

      if (userData == null) return null;

      final roles = userData.roles;
      // If user has no roles, return null to trigger role selection
      if (roles.isEmpty) return null;

      // Get the last active role from local storage or default to first role
      final activeRole = _getLastActiveRole(roles, prefs);

      return UserSession(
        userId: userData.id,
        fullName: userData.fullName,
        email: userData.email,
        phone: userData.phone,
        photoUrl: userData.photoUrl,
        roles: roles,
        activeRole: activeRole,
        authProvider:
            'phone', // TODO: Add authProvider to UserModel or AuthUser
        locationText: userData.locationText,
        locationLat: userData.locationLat,
        locationLng: userData.locationLng,
      );
    } catch (e) {
      return null;
    }
  }

  /// Switch to a different role.
  Future<void> switchRole(String newRole) async {
    final session = state.value;
    if (session == null || !session.roles.contains(newRole)) return;

    state = AsyncData(session.copyWith(activeRole: newRole));

    await _saveLastActiveRole(newRole);
  }

  String _getLastActiveRole(List<String> roles, SharedPreferences prefs) {
    try {
      final lastRole = prefs.getString('last_active_role');
      if (lastRole != null && roles.contains(lastRole)) {
        return lastRole;
      }
    } catch (_) {}
    return roles.first;
  }

  Future<void> _saveLastActiveRole(String role) async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString('last_active_role', role);
    } catch (_) {}
  }
}

/// Internal provider to watch auth state changes
@riverpod
Stream<AuthUser?> authStateChanges(Ref ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
}
