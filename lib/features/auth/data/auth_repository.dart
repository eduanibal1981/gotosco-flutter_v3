import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gotosco_v3/core/constants/enums.dart';
import 'package:gotosco_v3/core/models/user_model.dart';
import 'package:gotosco_v3/core/services/media_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
part 'auth_repository.g.dart';

/// Provides the AuthRepository instance via dependency injection.
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    Supabase.instance.client,
    ref.read(mediaServiceProvider),
  );
}

class AuthRepository {
  final SupabaseClient _supabase;
  final MediaService _mediaService;

  // Constructor Injection
  AuthRepository(this._supabase, this._mediaService);

  // --- Properties ---

  // C#: public User? CurrentUser => _supabase.Auth.CurrentUser;
  User? get currentUser => _supabase.auth.currentUser;

  // C#: public Session? CurrentSession => _supabase.Auth.CurrentSession;
  Session? get currentSession => _supabase.auth.currentSession;

  // C#: public IObservable<AuthState> AuthStateChanges => ...
  // This stream fires every time the user logs in, logs out, or token refreshes.
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // --- Methods ---

  /// Signs in a user with Email and Password.
  /// Returns a Supabase [AuthResponse].
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    // Await is exactly like C# await
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Registers a new user.
  /// CRITICAL: Also creates a row in the 'public.users' table.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    UserRole? role, // Enum: parent or driver (Optional now)
  }) async {
    // 1. Create the Auth User (in Supabase's secure auth system)
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      // We store metadata for quick access without querying the DB
      data: {
        'full_name': fullName,
        if (role != null) 'role': role.toDbString(),
      },
    );

    // 2. Create the Public Profile (in your 'users' table)
    // If the auth was successful (user != null), we assume we can write to the DB.
    // Note: In a perfect production env, a Database Trigger usually does this.
    // But doing it here is easier for development.
    if (response.user != null) {
      await _createPublicProfile(
        userId: response.user!.id,
        email: email,
        fullName: fullName,
        phone: phone,
        authProvider: 'phone', // Email/password signup uses phone auth flow
      );
    }

    return response;
  }

  /// Signs in with Google.
  /// On WEB: Uses Supabase OAuth redirect flow.
  /// On NATIVE (Android/iOS): Uses native Google Sign-In + ID token.
  Future<AuthResponse?> signInWithGoogle() async {
    if (kIsWeb) {
      // WEB: Use Supabase OAuth
      // Uses the current URL but strips the hash (e.g. https://domain.com/path/)
      // effectively preserving subdirectories like /gotosco-flutter_v3/
      final redirectTo = kIsWeb ? Uri.base.toString().split('#').first : null;

      final result = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo,
      );

      if (!result) {
        throw Exception('Failed to initiate Google Sign-In');
      }

      // Return null since auth completes after redirect
      return null;
    } else {
      // NATIVE: Use native Google Sign-In plugin (v6.x API)
      // Web Client ID from Google Cloud Console - must match what's configured in Supabase
      const webClientId =
          '7285013352-0klm5l36jbmuoi8a9asqbouv8oqhaocm.apps.googleusercontent.com';

      final googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
        scopes: ['email', 'profile'],
      ); // Trigger the Google Sign-In flow
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled by user');
      }

      // Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('No ID Token found from Google Sign-In');
      }

      // Sign in to Supabase with the Google ID token
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Create/Update public profile if this is a new user
      if (response.user != null) {
        // OPTIMIZATION: We use upsert in _createPublicProfile with ignoreDuplicates: true
        // to handle the existence check atomically. This avoids an extra round-trip
        // to check if the user exists (getUserProfile) before creating them.
        await _createPublicProfile(
          userId: response.user!.id,
          email: googleUser.email,
          fullName: googleUser.displayName ?? 'User',
          phone: null, // Google users may not have phone
          authProvider: 'google',
        );
      }

      return response;
    }
  }

  /// Signs out the current user and clears session.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Helper to insert a row into the 'public.users' table.
  /// Creates user with empty role array - they must select role(s) after signup.
  Future<void> _createPublicProfile({
    required String userId,
    required String email,
    required String fullName,
    String? phone,
    String authProvider = 'phone',
  }) async {
    // Map<String, dynamic> is like Dictionary<string, object> or a JObject in C#
    final userData = {
      'id': userId,
      'email': email,
      'full_name': fullName,
      'phone': phone, // Can be null for Google sign-in
      'role': <String>[], // Empty array - user must select role(s)
      'auth_provider': authProvider,
      'created_at': DateTime.now().toIso8601String(),
    };

    // 'upsert' means "Insert, or Update if it already exists"
    // ignoreDuplicates: true means "Insert if not exists, otherwise do nothing"
    await _supabase.from('users').upsert(userData, ignoreDuplicates: true);
  }

  /// Fetches the full profile from the database.
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      // select() is like a LINQ query. .single() ensures we get 1 row.
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      // In C#, you might catch Supabase errors. Here we catch Supabase errors.
      print('Error fetching profile: $e');
      return null;
    }
  }

  /// Updates the user's profile in 'public.users'.
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
      // PostGIS format: POINT(lng lat)
      updates['location_geo'] = 'POINT($locationLng $locationLat)';
    }

    if (updates.length > 1) {
      // > 1 because updated_at is always there
      await _supabase.from('users').update(updates).eq('id', userId);
    }
  }

  /// Uploads a profile image using R2 hybrid storage with WebP compression
  /// Falls back to Supabase Storage if R2 fails
  Future<String?> uploadProfileImage(
    String userId,
    XFile imageFile, {
    void Function(UploadProgress)? onProgress,
  }) async {
    try {
      // Use MediaService for R2 upload with compression
      final asset = await _mediaService.uploadMedia(
        imageFile,
        MediaAssetType.avatar,
        originalFilename: imageFile.name,
        onProgress: onProgress,
      );

      debugPrint('Profile image uploaded successfully: ${asset.url}');
      return asset.url;
    } catch (e) {
      debugPrint('Error uploading via R2, falling back to Supabase: $e');
      // Fallback to legacy Supabase Storage
      return _uploadProfileImageLegacy(userId, imageFile);
    }
  }

  /// Legacy upload to Supabase Storage (fallback)
  Future<String?> _uploadProfileImageLegacy(
    String userId,
    XFile imageFile,
  ) async {
    try {
      final fileExt = imageFile.name.split('.').last;
      final fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName;

      final bytes = await imageFile.readAsBytes();
      await _supabase.storage
          .from('avatars')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image (legacy): $e');
      return null;
    }
  }
}
