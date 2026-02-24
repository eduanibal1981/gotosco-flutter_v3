import 'package:gotosco_v3/core/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/application/user_provider.dart';
import '../../../auth/application/user_session_provider.dart';
import '../data/repositories/parent_profile_repository_impl.dart';

part 'parent_profile_controller.g.dart';

@riverpod
class ParentProfileController extends _$ParentProfileController {
  @override
  Future<void> build() async {}

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(parentProfileRepositoryProvider).signOut();
    });
  }

  Future<void> switchRole(String role) async {
    await ref.read(userSessionProvider.notifier).switchRole(role);
  }

  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) {
    return ref
        .read(parentProfileRepositoryProvider)
        .reverseGeocode(latitude: latitude, longitude: longitude);
  }

  Future<void> saveProfile({
    required UserModel user,
    required String fullName,
    required String phone,
    required String locationText,
    double? locationLat,
    double? locationLng,
    XFile? imageFile,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      String? photoUrl;
      if (imageFile != null) {
        photoUrl = await ref
            .read(parentProfileRepositoryProvider)
            .uploadProfileImage(user.id, imageFile);
      }

      await ref
          .read(parentProfileRepositoryProvider)
          .updateProfile(
            userId: user.id,
            fullName: fullName,
            phone: phone,
            photoUrl: photoUrl,
            locationText: locationText,
            locationLat: locationLat,
            locationLng: locationLng,
          );

      ref.invalidate(currentUserProfileProvider);
    });
  }
}
