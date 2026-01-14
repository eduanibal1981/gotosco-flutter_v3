// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_ad_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverAdModel _$DriverAdModelFromJson(Map<String, dynamic> json) =>
    _DriverAdModel(
      driverId: json['driver_id'] as String,
      name: json['name'] as String? ?? 'Driver',
      photoUrl: json['photo_url'] as String?,
      gender: json['gender'] as String? ?? 'male',
      vehicleType: json['vehicle_type'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      priceMonthlyTwoWay:
          (json['price_monthly_two_way'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['is_verified'] as bool? ?? false,
      bio: json['bio'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      isOnline: json['is_online'] as bool? ?? false,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      coveredSchools:
          (json['coveredSchools'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      coveredAreas:
          (json['coveredAreas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      vehicleCapacity: (json['vehicle_capacity'] as num?)?.toInt() ?? 0,
      otherPrices:
          (json['otherPrices'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      adPhotos:
          (json['adPhotos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DriverAdModelToJson(_DriverAdModel instance) =>
    <String, dynamic>{
      'driver_id': instance.driverId,
      'name': instance.name,
      'photo_url': instance.photoUrl,
      'gender': instance.gender,
      'vehicle_type': instance.vehicleType,
      'rating': instance.rating,
      'total_reviews': instance.totalReviews,
      'price_monthly_two_way': instance.priceMonthlyTwoWay,
      'is_verified': instance.isVerified,
      'bio': instance.bio,
      'phone': instance.phone,
      'is_online': instance.isOnline,
      'distance_km': instance.distanceKm,
      'coveredSchools': instance.coveredSchools,
      'coveredAreas': instance.coveredAreas,
      'vehicle_capacity': instance.vehicleCapacity,
      'otherPrices': instance.otherPrices,
      'adPhotos': instance.adPhotos,
    };
