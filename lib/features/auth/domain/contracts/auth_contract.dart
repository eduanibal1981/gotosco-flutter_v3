import 'package:gotosco_v3/core/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gotosco_v3/core/constants/enums.dart';

import '../models/auth_user.dart';

abstract class AuthContract {
  /// Current authenticated user
  AuthUser? get currentUser;

  /// Stream of auth state changes
  Stream<AuthUser?> get authStateChanges;

  /// Sign in with email and password
  Future<AuthUser> signIn({required String email, required String password});

  /// Sign up with email, password, and additional info
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    UserRole? role,
  });

  /// Sign in with Google (returns null on web redirect)
  Future<AuthUser?> signInWithGoogle();

  /// Sign out
  Future<void> signOut();

  /// Update user profile
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? photoUrl,
    String? locationText,
    double? locationLat,
    double? locationLng,
  });

  /// Upload profile image
  Future<String?> uploadProfileImage(String userId, XFile imageFile);

  /// Get full user profile
  Future<UserModel?> getUserProfile(String userId);

  /// Update user roles
  Future<void> updateRoles(String userId, List<String> roles);
}
