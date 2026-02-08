// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverTrip _$DriverTripFromJson(Map<String, dynamic> json) => _DriverTrip(
  id: json['id'] as String,
  driverId: json['driver_id'] as String,
  tripDate: json['trip_date'] as String,
  tripType: json['trip_type'] as String,
  status: json['status'] as String?,
  plannedStartTime: json['planned_start_time'] == null
      ? null
      : DateTime.parse(json['planned_start_time'] as String),
  actualStartTime: json['actual_start_time'] == null
      ? null
      : DateTime.parse(json['actual_start_time'] as String),
  actualEndTime: json['actual_end_time'] == null
      ? null
      : DateTime.parse(json['actual_end_time'] as String),
  totalDistanceKm: (json['total_distance_km'] as num?)?.toDouble(),
  routeStops:
      (json['route_stops'] as List<dynamic>?)
          ?.map((e) => RouteStop.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$DriverTripToJson(_DriverTrip instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driver_id': instance.driverId,
      'trip_date': instance.tripDate,
      'trip_type': instance.tripType,
      'status': instance.status,
      'planned_start_time': instance.plannedStartTime?.toIso8601String(),
      'actual_start_time': instance.actualStartTime?.toIso8601String(),
      'actual_end_time': instance.actualEndTime?.toIso8601String(),
      'total_distance_km': instance.totalDistanceKm,
      'route_stops': instance.routeStops,
    };

_RouteStop _$RouteStopFromJson(Map<String, dynamic> json) => _RouteStop(
  id: json['id'] as String,
  stopType: json['stop_type'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  sequenceOrder: (json['sequence_order'] as num?)?.toInt(),
  actualArrivalTime: json['actual_arrival_time'] == null
      ? null
      : DateTime.parse(json['actual_arrival_time'] as String),
  status: json['status'] as String?,
  childName: json['child_name'] as String?,
  studentId: json['student_id'] as String?,
  bookingId: json['booking_id'] as String?,
  homeLocation: json['home_location'] as String?,
  schoolLocation: json['school_location'] as String?,
);

Map<String, dynamic> _$RouteStopToJson(_RouteStop instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stop_type': instance.stopType,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'sequence_order': instance.sequenceOrder,
      'actual_arrival_time': instance.actualArrivalTime?.toIso8601String(),
      'status': instance.status,
      'child_name': instance.childName,
      'student_id': instance.studentId,
      'booking_id': instance.bookingId,
      'home_location': instance.homeLocation,
      'school_location': instance.schoolLocation,
    };
