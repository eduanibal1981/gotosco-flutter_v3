// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

// Force rebuild 2

part 'driver_profile_model.freezed.dart';
part 'driver_profile_model.g.dart';

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

enum VerificationStatus { verified, pending, unverified }

@freezed
abstract class DriverProfileModel with _$DriverProfileModel {
  const DriverProfileModel._(); // Needed for custom methods/getters

  const factory DriverProfileModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'photo_url') String? photoUrl,
    String? phone,
    String? email,
    @Default(0)
    @JsonKey(name: 'experience_years', fromJson: _parseInt)
    int experienceYears,
    @JsonKey(name: 'license_number') String? licenseNumber,
    @JsonKey(name: 'license_expiry') DateTime? licenseExpiry,
    @JsonKey(name: 'license_image_url') String? licenseImageUrl,
    @JsonKey(name: 'vehicle_type') required String vehicleType,
    @JsonKey(name: 'vehicle_number') String? vehicleNumber,
    @JsonKey(name: 'vehicle_capacity', fromJson: _parseInt)
    @Default(0)
    int vehicleCapacity,
    @JsonKey(name: 'mulkia_image_url') String? mulkiaImageUrl,
    @JsonKey(name: 'vehicle_image_urls')
    @Default([])
    List<String> vehicleImageUrls,
    @JsonKey(name: 'price_monthly_two_way', fromJson: _parseDouble)
    @Default(0)
    double priceMonthlyTwoWay,
    @JsonKey(name: 'price_monthly_one_way', fromJson: _parseDouble)
    @Default(0)
    double priceMonthlyOneWay,
    @JsonKey(name: 'price_daily', fromJson: _parseDouble)
    @Default(0)
    double priceDaily,
    @Default('') String bio,
    @Default(0) @JsonKey(fromJson: _parseDouble) double rating,
    @JsonKey(name: 'total_reviews', fromJson: _parseInt)
    @Default(0)
    int totalReviews,
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
      _$DriverProfileModelFromJson(_sanitizeDriverProfileJson(json));

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

  bool get isComplete {
    final hasVehicleType = vehicleType.isNotEmpty;
    final hasVehicleNumber = vehicleNumber != null && vehicleNumber!.isNotEmpty;
    final hasVehicleCapacity = vehicleCapacity > 0;
    final hasLicenseNumber = licenseNumber != null && licenseNumber!.isNotEmpty;
    final hasLicenseImage =
        licenseImageUrl != null && licenseImageUrl!.isNotEmpty;
    final hasMulkiaImage = mulkiaImageUrl != null && mulkiaImageUrl!.isNotEmpty;

    return hasVehicleType &&
        hasVehicleNumber &&
        hasVehicleCapacity &&
        hasLicenseNumber &&
        hasLicenseImage &&
        hasMulkiaImage;
  }
}

Map<String, dynamic> _sanitizeDriverProfileJson(Map<String, dynamic> json) {
  // Sanitize null values for non-nullable fields with defaults
  final sanitized = Map<String, dynamic>.from(json);

  void setDefault(String key, dynamic value) {
    if (sanitized[key] == null) sanitized[key] = value;
  }

  // Numeric fields
  setDefault('experience_years', 0);
  setDefault('vehicle_capacity', 0);
  setDefault('price_monthly_two_way', 0.0);
  setDefault('price_monthly_one_way', 0.0);
  setDefault('price_daily', 0.0);
  setDefault('rating', 0.0);
  setDefault('total_reviews', 0);

  // Boolean fields
  setDefault('is_verified', false);
  setDefault('license_verified', false);
  setDefault('insurance_verified', false);
  setDefault('background_check_verified', false);

  // String fields (Required in model)
  setDefault('bio', '');
  setDefault('name', '');
  setDefault('phone', '');
  setDefault('email', '');
  setDefault('vehicle_type', '');
  setDefault('id', '');
  setDefault('user_id', '');

  return sanitized;
}
