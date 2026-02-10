import 'package:gotosco_v3/core/constants/enums.dart';

import 'package:gotosco_v3/core/models/user_model.dart';
import 'package:gotosco_v3/core/services/media_service.dart';
import 'package:gotosco_v3/features/auth/domain/models/auth_user.dart';
import 'package:gotosco_v3/features/auth/domain/repositories/auth_repository.dart';
export 'package:gotosco_v3/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    sb.Supabase.instance.client,
    ref.read(mediaServiceProvider),
  );
}

class AuthRepositoryImpl implements AuthRepository {
  final sb.SupabaseClient _supabase;
  final MediaService _mediaService;

  AuthRepositoryImpl(this._supabase, this._mediaService);

  @override
  AuthUser? get currentUser => _supabase.auth.currentUser != null
      ? _toAuthUser(_supabase.auth.currentUser!)
      : null;

  @override
  Stream<AuthUser?> get authStateChanges =>
      _supabase.auth.onAuthStateChange.map(
        (state) => state.session?.user != null
            ? _toAuthUser(state.session!.user)
            : null,
      );

  AuthUser _toAuthUser(sb.User user) {
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      metadata: user.userMetadata,
    );
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) {
      throw const sb.AuthException('Sign in failed: User is null');
    }
    return _toAuthUser(response.user!);
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    UserRole? role,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        if (role != null) 'role': role.toDbString(),
      },
    );

    if (response.user != null) {
      await _createPublicProfile(
        userId: response.user!.id,
        email: email,
        fullName: fullName,
        phone: phone,
        authProvider: 'phone',
      );
      return _toAuthUser(response.user!);
    } else {
      throw const sb.AuthException('Sign up failed: User is null');
    }
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    if (kIsWeb) {
      final redirectTo = Uri.base.path.isNotEmpty
          ? Uri.base.toString().split('#').first
          : null;
      final result = await _supabase.auth.signInWithOAuth(
        sb.OAuthProvider.google,
        redirectTo: redirectTo,
      );

      if (!result) throw Exception('Failed to initiate Google Sign-In');
      return null;
    } else {
      const webClientId =
          '7285013352-0klm5l36jbmuoi8a9asqbouv8oqhaocm.apps.googleusercontent.com';

      final googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
        scopes: ['email', 'profile'],
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google Sign-In cancelled');

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) throw Exception('No ID Token found');

      final response = await _supabase.auth.signInWithIdToken(
        provider: sb.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        await _createPublicProfile(
          userId: response.user!.id,
          email: googleUser.email,
          fullName: googleUser.displayName ?? 'User',
          phone: null,
          authProvider: 'google',
        );
        return _toAuthUser(response.user!);
      }
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> _createPublicProfile({
    required String userId,
    required String email,
    required String fullName,
    String? phone,
    String authProvider = 'phone',
  }) async {
    final userData = {
      'id': userId,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': <String>[],
      'auth_provider': authProvider,
      'created_at': DateTime.now().toIso8601String(),
    };
    await _supabase.from('users').upsert(userData, ignoreDuplicates: true);
  }

  @override
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? photoUrl,
    String? locationText,
    double? locationLat,
    double? locationLng,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone.isEmpty ? null : phone;
    if (photoUrl != null) updates['photo_url'] = photoUrl;
    if (locationText != null) updates['location_text'] = locationText;
    if (locationLat != null && locationLng != null) {
      updates['location_geo'] = 'POINT($locationLng $locationLat)';
    }

    if (updates.length > 1) {
      await _supabase.from('users').update(updates).eq('id', userId);
    }
  }

  @override
  Future<String?> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      final asset = await _mediaService.uploadMedia(
        imageFile,
        MediaAssetType.avatar,
        originalFilename: imageFile.name,
      );
      return asset.url;
    } catch (e) {
      try {
        final fileExt = imageFile.name.split('.').last;
        final fileName =
            '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final bytes = await imageFile.readAsBytes();
        await _supabase.storage
            .from('avatars')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const sb.FileOptions(upsert: true),
            );
        return _supabase.storage.from('avatars').getPublicUrl(fileName);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateRoles(String userId, List<String> roles) async {
    await _supabase.from('users').update({'role': roles}).eq('id', userId);
  }
}
