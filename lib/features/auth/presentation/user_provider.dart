import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotosco_v3/core/models/user_model.dart';
import 'package:gotosco_v3/features/auth/data/auth_repository.dart';

part 'user_provider.g.dart';

/// AUTH STATE STREAM
/// Listens to Supabase (Login, Logout, Token Refresh).
/// The UI watches this to decide whether to show LoginScreen or HomeScreen.
@riverpod
Stream<AuthState> authStateChanges(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
}

/// CURRENT USER PROFILE
/// Fetches the full 'UserModel' (name, role, phone) from the database.
/// Smart Logic: It watches 'authStateChangesProvider', so if the user
/// logs out, this automatically updates/nullifies without extra code.
@riverpod
Future<UserModel?> currentUserProfile(Ref ref) async {
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
}
