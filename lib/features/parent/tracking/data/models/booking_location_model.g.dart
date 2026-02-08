// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingLocation _$BookingLocationFromJson(Map<String, dynamic> json) =>
    _BookingLocation(
      bookingId: json['booking_id'] as String,
      homeLat: (json['home_lat'] as num?)?.toDouble(),
      homeLng: (json['home_lng'] as num?)?.toDouble(),
      schoolLat: (json['school_lat'] as num?)?.toDouble(),
      schoolLng: (json['school_lng'] as num?)?.toDouble(),
      driverId: json['driver_id'] as String?,
      driverName: json['driver_name'] as String?,
      driverPhone: json['driver_phone'] as String?,
    );

Map<String, dynamic> _$BookingLocationToJson(_BookingLocation instance) =>
    <String, dynamic>{
      'booking_id': instance.bookingId,
      'home_lat': instance.homeLat,
      'home_lng': instance.homeLng,
      'school_lat': instance.schoolLat,
      'school_lng': instance.schoolLng,
      'driver_id': instance.driverId,
      'driver_name': instance.driverName,
      'driver_phone': instance.driverPhone,
    };
