import 'package:gotosco_v3/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gotosco_v3/features/auth/domain/models/auth_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gotosco_v3/core/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gotosco_v3/features/auth/application/user_session_provider.dart';

part 'user_provider.g.dart';

// AUTH STATE STREAM is provided by user_session_provider.dart

@riverpod
String? currentUserId(Ref ref) {
  ref.watch(authStateChangesProvider);
  return Supabase.instance.client.auth.currentUser?.id;
}

/// CURRENT USER PROFILE
/// Fetches the full 'UserModel' (name, role, phone) from the database.
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
