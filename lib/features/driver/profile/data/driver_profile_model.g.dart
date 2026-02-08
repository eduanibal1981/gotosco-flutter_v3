// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverProfileModel _$DriverProfileModelFromJson(
  Map<String, dynamic> json,
) => _DriverProfileModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  photoUrl: json['photoUrl'] as String?,
  phone: json['phone'] as String,
  email: json['email'] as String,
  experienceYears: (json['experience_years'] as num?)?.toInt() ?? 0,
  licenseNumber: json['license_number'] as String?,
  licenseExpiry: json['license_expiry'] == null
      ? null
      : DateTime.parse(json['license_expiry'] as String),
  licenseImageUrl: json['license_image_url'] as String?,
  vehicleType: json['vehicle_type'] as String,
  vehicleNumber: json['vehicle_number'] as String?,
  vehicleCapacity: (json['vehicle_capacity'] as num?)?.toInt() ?? 0,
  mulkiaImageUrl: json['mulkia_image_url'] as String?,
  vehicleImageUrls:
      (json['vehicle_image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  priceMonthlyTwoWay: (json['price_monthly_two_way'] as num?)?.toDouble() ?? 0,
  priceMonthlyOneWay: (json['price_monthly_one_way'] as num?)?.toDouble() ?? 0,
  priceDaily: (json['price_daily'] as num?)?.toDouble() ?? 0,
  bio: json['bio'] as String? ?? '',
  rating: (json['rating'] as num?)?.toDouble() ?? 0,
  totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
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
      'userId': instance.userId,
      'name': instance.name,
      'photoUrl': instance.photoUrl,
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
