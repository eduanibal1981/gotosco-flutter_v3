import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gotosco_v3/core/constants/dev_config.dart';
import 'package:gotosco_v3/core/constants/enums.dart';
import '../data/auth_repository.dart';

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
      final response = await authRepo.signIn(email: email, password: password);

      if (response.user == null) {
        final result = AuthResult.failure(
          'Login failed. Please check your credentials.',
        );
        state = AsyncData(result);
        return result;
      }

      final role = response.user!.userMetadata?['role'] as String?;
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
    required String phone,
    required UserRole role,
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
      final response = await authRepo.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
      );

      if (response.user == null) {
        final result = AuthResult.failure('Sign up failed. Please try again.');
        state = AsyncData(result);
        return result;
      }

      final result = AuthResult.success(role.toDbString());
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
      final response = await authRepo.signInWithGoogle();

      // Web OAuth redirects, so response is null
      if (response == null) {
        state = const AsyncData(null);
        return null;
      }

      if (response.user == null) {
        final result = AuthResult.failure('Google sign-in failed');
        state = AsyncData(result);
        return result;
      }

      final role = response.user!.userMetadata?['role'] as String?;
      final result = AuthResult.success(role);
      state = AsyncData(result);
      return result;
    } catch (e) {
      final result = AuthResult.failure(e.toString());
      state = AsyncData(result);
      return result;
    }
  }

  /// DEV MODE: Signs in with test credentials for quick testing.
  Future<AuthResult> devSignIn(String role) async {
    state = const AsyncLoading();

    try {
      final testUser = role == 'driver'
          ? DevConfig.testDriver
          : DevConfig.testParent;

      final authRepo = ref.read(authRepositoryProvider);
      final response = await authRepo.signIn(
        email: testUser['email'] as String,
        password: DevConfig.testPassword,
      );

      if (response.user == null) {
        final result = AuthResult.failure('DEV sign-in failed');
        state = AsyncData(result);
        return result;
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
}
