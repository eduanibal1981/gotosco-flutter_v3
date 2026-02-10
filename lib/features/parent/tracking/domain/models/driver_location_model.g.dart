// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverLocation _$DriverLocationFromJson(Map<String, dynamic> json) =>
    _DriverLocation(
      driverId: json['driver_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      tripType: json['trip_type'] as String?,
      tripsStarted: json['trips_started'] as bool? ?? false,
      etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
      nextStopId: json['next_stop_id'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isAppOnline: json['is_app_online'] as bool? ?? false,
      isOnlineVisible: json['is_profile_online'] as bool? ?? true,
    );

Map<String, dynamic> _$DriverLocationToJson(_DriverLocation instance) =>
    <String, dynamic>{
      'driver_id': instance.driverId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'heading': instance.heading,
      'speed': instance.speed,
      'trip_type': instance.tripType,
      'trips_started': instance.tripsStarted,
      'eta_minutes': instance.etaMinutes,
      'next_stop_id': instance.nextStopId,
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_app_online': instance.isAppOnline,
      'is_profile_online': instance.isOnlineVisible,
    };
