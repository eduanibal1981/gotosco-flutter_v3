import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gotosco_v3/core/constants/enums.dart'; // From the 'Core' structure I gave you
import 'package:gotosco_v3/core/models/user_model.dart'; // We will define this small model below
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Dependency Injection (The "Service Container")
// This allows any widget to say `ref.watch(authRepositoryProvider)` to get this instance.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

class AuthRepository {
  final SupabaseClient _supabase;

  // Constructor Injection
  AuthRepository(this._supabase);

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
    required String phone,
    required UserRole role, // Enum: parent or driver
  }) async {
    // 1. Create the Auth User (in Supabase's secure auth system)
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      // We store metadata for quick access without querying the DB
      data: {'full_name': fullName, 'role': role.toDbString()},
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
        role: role,
      );
    }

    return response;
  }

  /// Signs in with Google.
  /// On WEB: Uses Supabase OAuth redirect flow.
  /// On NATIVE (Android/iOS): Uses native Google Sign-In + ID token.
  Future<AuthResponse?> signInWithGoogle() async {
    if (kIsWeb) {
      // WEB: Use Supabase OAuth - this will redirect to Google
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            'http://localhost:${Uri.base.port}', // Adjust for production
      );
      // Note: On web, this returns immediately and the page redirects.
      // Auth state will be handled when user returns via onAuthStateChange.
      // Return null since auth is pending redirect
      return null;
    } else {
      // NATIVE: Use native Google Sign-In plugin (v6.x API)
      const webClientId =
          '426305775558-v3997naridrfaquv79d8t7ca9f0a05a8.apps.googleusercontent.com';

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
        final existingProfile = await getUserProfile(response.user!.id);
        if (existingProfile == null) {
          await _createPublicProfile(
            userId: response.user!.id,
            email: googleUser.email,
            fullName: googleUser.displayName ?? 'User',
            phone: '',
            role: UserRole.parent,
          );
        }
      }

      return response;
    }
  }

  /// Signs out the current user and clears session.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Helper to insert a row into the 'public.users' table.
  Future<void> _createPublicProfile({
    required String userId,
    required String email,
    required String fullName,
    required String phone,
    required UserRole role,
  }) async {
    // Map<String, dynamic> is like Dictionary<string, object> or a JObject in C#
    final userData = {
      'id': userId,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role.toDbString(),
      'created_at': DateTime.now().toIso8601String(),
    };

    // 'upsert' means "Insert, or Update if it already exists"
    await _supabase.from('users').upsert(userData);
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

      return UserModel.fromMap(response);
    } catch (e) {
      // In C#, you might catch SqlException. Here we catch Supabase errors.
      print('Error fetching profile: $e');
      return null;
    }
  }
}
