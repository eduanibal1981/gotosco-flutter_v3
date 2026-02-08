// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_profile_model.freezed.dart';
part 'driver_profile_model.g.dart';

enum VerificationStatus { verified, pending, unverified }

@freezed
abstract class DriverProfileModel with _$DriverProfileModel {
  const DriverProfileModel._(); // Needed for custom methods/getters

  const factory DriverProfileModel({
    required String id,
    required String userId,
    required String name,
    String? photoUrl,
    required String phone,
    required String email,
    @Default(0) @JsonKey(name: 'experience_years') int experienceYears,
    @JsonKey(name: 'license_number') String? licenseNumber,
    @JsonKey(name: 'license_expiry') DateTime? licenseExpiry,
    @JsonKey(name: 'license_image_url') String? licenseImageUrl,
    @JsonKey(name: 'vehicle_type') required String vehicleType,
    @JsonKey(name: 'vehicle_number') String? vehicleNumber,
    @JsonKey(name: 'vehicle_capacity') @Default(0) int vehicleCapacity,
    @JsonKey(name: 'mulkia_image_url') String? mulkiaImageUrl,
    @JsonKey(name: 'vehicle_image_urls')
    @Default([])
    List<String> vehicleImageUrls,
    @JsonKey(name: 'price_monthly_two_way')
    @Default(0)
    double priceMonthlyTwoWay,
    @JsonKey(name: 'price_monthly_one_way')
    @Default(0)
    double priceMonthlyOneWay,
    @JsonKey(name: 'price_daily') @Default(0) double priceDaily,
    @Default('') String bio,
    @Default(0) double rating,
    @JsonKey(name: 'total_reviews') @Default(0) int totalReviews,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'license_verified') @Default(false) bool licenseVerified,
    @JsonKey(name: 'insurance_verified') @Default(false) bool insuranceVerified,
    @JsonKey(name: 'background_check_verified')
    @Default(false)
    bool backgroundCheckVerified,
    @JsonKey(name: 'service_areas') @Default([]) List<String> serviceAreas,
    @Default([]) List<String> schools,
    @JsonKey(name: 'location_text') String? locationText,
    @JsonKey(name: 'location_lat') double? locationLat,
    @JsonKey(name: 'location_lng') double? locationLng,
    @JsonKey(name: 'start_location_text') String? startLocationText,
    @JsonKey(name: 'start_location_lat') double? startLocationLat,
    @JsonKey(name: 'start_location_lng') double? startLocationLng,
  }) = _DriverProfileModel;

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileModelFromJson(json);

  Map<String, dynamic> toUpdateMap() {
    return {
      'experience_years': experienceYears,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry?.toIso8601String().split('T').first,
      'license_image_url': licenseImageUrl,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'vehicle_capacity': vehicleCapacity,
      'mulkia_image_url': mulkiaImageUrl,
      'vehicle_image_urls': vehicleImageUrls,
      'price_monthly_two_way': priceMonthlyTwoWay,
      'price_monthly_one_way': priceMonthlyOneWay,
      'price_daily': priceDaily,
      'bio': bio,
    };
  }

  VerificationStatus get verificationStatus {
    if (isVerified) return VerificationStatus.verified;

    final hasLicenseImage =
        licenseImageUrl != null && licenseImageUrl!.isNotEmpty;
    final hasMulkiaImage = mulkiaImageUrl != null && mulkiaImageUrl!.isNotEmpty;

    if (hasLicenseImage && hasMulkiaImage) return VerificationStatus.pending;

    return VerificationStatus.unverified;
  }
}
