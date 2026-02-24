import 'package:image_picker/image_picker.dart';

abstract class ParentProfileContract {
  Future<void> signOut();

  Future<String?> uploadProfileImage(String userId, XFile imageFile);

  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? photoUrl,
    String? locationText,
    double? locationLat,
    double? locationLng,
  });

  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  });
}
