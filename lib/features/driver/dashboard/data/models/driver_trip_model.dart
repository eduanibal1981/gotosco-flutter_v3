// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_trip_model.freezed.dart';
part 'driver_trip_model.g.dart';

@freezed
abstract class DriverTrip with _$DriverTrip {
  const DriverTrip._();

  const factory DriverTrip({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'driver_id') required String driverId,
    @JsonKey(name: 'trip_date')
    required String tripDate, // Date as string YYYY-MM-DD
    @JsonKey(name: 'trip_type') required String tripType,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'planned_start_time') DateTime? plannedStartTime,
    @JsonKey(name: 'actual_start_time') DateTime? actualStartTime,
    @JsonKey(name: 'actual_end_time') DateTime? actualEndTime,
    @JsonKey(name: 'total_distance_km') double? totalDistanceKm,
    @JsonKey(name: 'route_stops') @Default([]) List<RouteStop> routeStops,
  }) = _DriverTrip;

  factory DriverTrip.fromJson(Map<String, dynamic> json) =>
      _$DriverTripFromJson(json);
}

@freezed
abstract class RouteStop with _$RouteStop {
  const RouteStop._();

  const factory RouteStop({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'stop_type') String? stopType,
    @JsonKey(name: 'latitude') double? latitude,
    @JsonKey(name: 'longitude') double? longitude,
    @JsonKey(name: 'sequence_order') int? sequenceOrder,
    @JsonKey(name: 'actual_arrival_time') DateTime? actualArrivalTime,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'child_name') String? childName,
    @JsonKey(name: 'student_id') String? studentId,
    @JsonKey(name: 'booking_id') String? bookingId,
    @JsonKey(name: 'home_location') String? homeLocation,
    @JsonKey(name: 'school_location') String? schoolLocation,
  }) = _RouteStop;

  factory RouteStop.fromJson(Map<String, dynamic> json) =>
      _$RouteStopFromJson(json);
}
