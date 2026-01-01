import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Required for AuthState
import 'package:gotosco_v3/core/models/user_model.dart';
import 'package:gotosco_v3/features/auth/data/auth_repository.dart';

/// 1. AUTH STATE STREAM
/// Listens to Supabase (Login, Logout, Token Refresh).
/// The UI watches this to decide whether to show LoginScreen or HomeScreen.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

/// 2. CURRENT USER PROFILE
/// Fetches the full 'UserModel' (name, role, phone) from the database.
/// Smart Logic: It watches 'authStateChangesProvider', so if the user
/// logs out, this automatically updates/nullifies without extra code.
final currentUserProfileProvider = FutureProvider<UserModel?>((ref) async {
  // Dependency: Watch for auth state changes to trigger a re-fetch
  ref.watch(authStateChangesProvider);

  final authRepo = ref.watch(authRepositoryProvider);

  // Check if there is a basic Auth User (ID exists)
  final userId = authRepo.currentUser?.id;

  if (userId == null) {
    return null; // User is not logged in
  }

  // Fetch the detailed profile from 'public.users' table
  return await authRepo.getUserProfile(userId);
});
