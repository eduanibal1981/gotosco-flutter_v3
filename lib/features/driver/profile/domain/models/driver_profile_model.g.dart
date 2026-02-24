// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverProfileModel _$DriverProfileModelFromJson(
  Map<String, dynamic> json,
) => _DriverProfileModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  photoUrl: json['photo_url'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  experienceYears: json['experience_years'] == null
      ? 0
      : _parseInt(json['experience_years']),
  licenseNumber: json['license_number'] as String?,
  licenseExpiry: json['license_expiry'] == null
      ? null
      : DateTime.parse(json['license_expiry'] as String),
  licenseImageUrl: json['license_image_url'] as String?,
  vehicleType: json['vehicle_type'] as String,
  vehicleNumber: json['vehicle_number'] as String?,
  vehicleCapacity: json['vehicle_capacity'] == null
      ? 0
      : _parseInt(json['vehicle_capacity']),
  mulkiaImageUrl: json['mulkia_image_url'] as String?,
  vehicleImageUrls:
      (json['vehicle_image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  priceMonthlyTwoWay: json['price_monthly_two_way'] == null
      ? 0
      : _parseDouble(json['price_monthly_two_way']),
  priceMonthlyOneWay: json['price_monthly_one_way'] == null
      ? 0
      : _parseDouble(json['price_monthly_one_way']),
  priceDaily: json['price_daily'] == null
      ? 0
      : _parseDouble(json['price_daily']),
  bio: json['bio'] as String? ?? '',
  rating: json['rating'] == null ? 0 : _parseDouble(json['rating']),
  totalReviews: json['total_reviews'] == null
      ? 0
      : _parseInt(json['total_reviews']),
  isVerified: json['is_verified'] as bool? ?? false,
  licenseVerified: json['license_verified'] as bool? ?? false,
  insuranceVerified: json['insurance_verified'] as bool? ?? false,
  backgroundCheckVerified: json['background_check_verified'] as bool? ?? false,
  serviceAreas:
      (json['service_areas'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  schools:
      (json['schools'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  locationText: json['location_text'] as String?,
  locationLat: (json['location_lat'] as num?)?.toDouble(),
  locationLng: (json['location_lng'] as num?)?.toDouble(),
  startLocationText: json['start_location_text'] as String?,
  startLocationLat: (json['start_location_lat'] as num?)?.toDouble(),
  startLocationLng: (json['start_location_lng'] as num?)?.toDouble(),
);

Map<String, dynamic> _$DriverProfileModelToJson(_DriverProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'photo_url': instance.photoUrl,
      'phone': instance.phone,
      'email': instance.email,
      'experience_years': instance.experienceYears,
      'license_number': instance.licenseNumber,
      'license_expiry': instance.licenseExpiry?.toIso8601String(),
      'license_image_url': instance.licenseImageUrl,
      'vehicle_type': instance.vehicleType,
      'vehicle_number': instance.vehicleNumber,
      'vehicle_capacity': instance.vehicleCapacity,
      'mulkia_image_url': instance.mulkiaImageUrl,
      'vehicle_image_urls': instance.vehicleImageUrls,
      'price_monthly_two_way': instance.priceMonthlyTwoWay,
      'price_monthly_one_way': instance.priceMonthlyOneWay,
      'price_daily': instance.priceDaily,
      'bio': instance.bio,
      'rating': instance.rating,
      'total_reviews': instance.totalReviews,
      'is_verified': instance.isVerified,
      'license_verified': instance.licenseVerified,
      'insurance_verified': instance.insuranceVerified,
      'background_check_verified': instance.backgroundCheckVerified,
      'service_areas': instance.serviceAreas,
      'schools': instance.schools,
      'location_text': instance.locationText,
      'location_lat': instance.locationLat,
      'location_lng': instance.locationLng,
      'start_location_text': instance.startLocationText,
      'start_location_lat': instance.startLocationLat,
      'start_location_lng': instance.startLocationLng,
    };
