import 'package:gotosco_v3/core/models/user_model.dart';
import 'package:gotosco_v3/core/models/user_session.dart';
import 'package:gotosco_v3/features/auth/application/user_provider.dart';
import 'package:gotosco_v3/features/auth/application/user_session_provider.dart';
import 'package:gotosco_v3/features/parent/bookings/data/bookings_repository.dart';
import 'package:gotosco_v3/features/parent/children/data/children_repository.dart';
import 'package:gotosco_v3/features/parent/children/domain/models/child_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'parent_profile_providers.g.dart';

@riverpod
Future<UserModel?> parentProfileUser(Ref ref) async {
  return ref.watch(currentUserProfileProvider.future);
}

@riverpod
Future<List<ChildModel>> parentProfileChildren(Ref ref) async {
  return ref.watch(myChildrenProvider.future);
}

@riverpod
Stream<List<Map<String, dynamic>>> parentProfileBookings(Ref ref) {
  return myBookings(ref);
}

@riverpod
Future<UserSession?> parentProfileSession(Ref ref) async {
  return ref.watch(userSessionProvider.future);
}
