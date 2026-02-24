import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../auth/data/repositories/auth_repository_impl.dart';
import '../../domain/contracts/parent_profile_contract.dart';
import '../datasources/parent_profile_remote_datasource.dart';

part 'parent_profile_repository_impl.g.dart';

@riverpod
ParentProfileContract parentProfileRepository(Ref ref) {
  return ParentProfileRepositoryImpl(
    authRepository: ref.watch(authRepositoryProvider),
    remoteDatasource: ParentProfileRemoteDatasource(),
  );
}

class ParentProfileRepositoryImpl implements ParentProfileContract {
  ParentProfileRepositoryImpl({
    required AuthContract authRepository,
    required ParentProfileRemoteDatasource remoteDatasource,
  }) : _authRepository = authRepository,
       _remoteDatasource = remoteDatasource;

  final AuthContract _authRepository;
  final ParentProfileRemoteDatasource _remoteDatasource;

  @override
  Future<void> signOut() {
    return _authRepository.signOut();
  }

  @override
  Future<String?> uploadProfileImage(String userId, XFile imageFile) {
    return _authRepository.uploadProfileImage(userId, imageFile);
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
  }) {
    return _authRepository.updateProfile(
      userId: userId,
      fullName: fullName,
      phone: phone,
      photoUrl: photoUrl,
      locationText: locationText,
      locationLat: locationLat,
      locationLng: locationLng,
    );
  }

  @override
  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) {
    return _remoteDatasource.reverseGeocode(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
