import 'package:gotosco_v3/core/constants/enums.dart';
import 'package:gotosco_v3/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

/// State representing the result of an auth operation
class AuthResult {
  final bool success;
  final String? role; // 'parent' or 'driver'
  final String? error;

  const AuthResult({required this.success, this.role, this.error});

  factory AuthResult.success(String? role) =>
      AuthResult(success: true, role: role);
  factory AuthResult.failure(String error) =>
      AuthResult(success: false, error: error);
}

/// Controller that encapsulates all authentication business logic.
/// This keeps the UI widgets thin and focused only on presentation.
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<AuthResult?> build() => null;

  /// Signs in with email and password.
  /// Returns the user's role on success for navigation.
  Future<AuthResult> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.signIn(email: email, password: password);

      final role = user.metadata?['role'] as String?;
      final result = AuthResult.success(role);
      state = AsyncData(result);
      return result;
    } catch (e) {
      final result = AuthResult.failure(e.toString());
      state = AsyncData(result);
      return result;
    }
  }

  /// Signs up a new user with the given details.
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    UserRole? role,
  }) async {
    state = const AsyncLoading();

    try {
      // Validation
      if (email.trim().isEmpty) {
        final result = AuthResult.failure('Email is required');
        state = AsyncData(result);
        return result;
      }
      if (password.length < 6) {
        final result = AuthResult.failure(
          'Password must be at least 6 characters',
        );
        state = AsyncData(result);
        return result;
      }
      if (fullName.trim().isEmpty) {
        final result = AuthResult.failure('Full name is required');
        state = AsyncData(result);
        return result;
      }

      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
      );

      final result = AuthResult.success(role?.toDbString());
      state = AsyncData(result);
      return result;
    } catch (e) {
      final result = AuthResult.failure(e.toString());
      state = AsyncData(result);
      return result;
    }
  }

  /// Signs in with Google OAuth.
  /// On web, returns null as the page redirects. On native, returns the role.
  Future<AuthResult?> signInWithGoogle() async {
    state = const AsyncLoading();

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.signInWithGoogle();

      // Web OAuth redirects, so response is null
      if (user == null) {
        state = const AsyncData(null);
        return null;
      }

      // For Google Sign-In, role might not be in userMetadata
      // So we need to read it from the database profile
      String? role = user.metadata?['role'] as String?;

      if (role == null || role.isEmpty) {
        // Fetch role from database profile using repo
        try {
          final userProfile = await authRepo.getUserProfile(user.id);
          if (userProfile != null && userProfile.roles.isNotEmpty) {
            role = userProfile.roles.first;
          } else {
            role = '';
          }
        } catch (_) {
          role = '';
        }
      }

      final result = AuthResult.success(role);
      state = AsyncData(result);
      return result;
    } catch (e) {
      final result = AuthResult.failure(e.toString());
      state = AsyncData(result);
      return result;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  /// Update user roles
  Future<void> updateRoles(List<String> roles) async {
    // We don't change state to loading here? Or we should?
    // Doing so might clear the current "Success" state from signin?
    // Let's keep state as is or ensure we don't break existing UI relying on build state.
    // The role selection screen manages isLoading locally, so maybe we don't need to touch state here heavily, but for consistency we might.
    // However, if we set state = AsyncLoading, validation of user role downstream might be affected if user is watching this controller for auth status?
    // This controller rebuilds AuthResult?

    try {
      final repo = ref.read(authRepositoryProvider);
      final user = repo.currentUser;
      if (user == null) throw Exception('User not logged in');

      await repo.updateRoles(user.id, roles);
    } catch (e) {
      rethrow;
    }
  }
}
