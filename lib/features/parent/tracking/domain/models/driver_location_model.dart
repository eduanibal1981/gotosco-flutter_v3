// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'driver_location_model.freezed.dart';
part 'driver_location_model.g.dart';

@freezed
abstract class DriverLocation with _$DriverLocation {
  const DriverLocation._();

  const factory DriverLocation({
    @JsonKey(name: 'driver_id') required String driverId,
    required double latitude,
    required double longitude,
    @Default(0.0) double heading,
    @Default(0.0) double speed,
    @JsonKey(name: 'trip_type') String? tripType,
    @JsonKey(name: 'trips_started') @Default(false) bool tripsStarted,
    @JsonKey(name: 'eta_minutes') int? etaMinutes,
    @JsonKey(name: 'next_stop_id') String? nextStopId,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'is_app_online') @Default(false) bool isAppOnline,
    @JsonKey(name: 'is_profile_online') @Default(true) bool isOnlineVisible,
  }) = _DriverLocation;

  factory DriverLocation.fromJson(Map<String, dynamic> json) =>
      _$DriverLocationFromJson(json);

  // Compatibility factory
  factory DriverLocation.fromMap(Map<String, dynamic> map) =>
      DriverLocation.fromJson(map);

  Map<String, dynamic> toMap() => toJson();

  LatLng get position => LatLng(latitude, longitude);

  bool get isOnTrip =>
      tripType == 'pickup' || tripType == 'dropoff' || tripsStarted;

  double get headingRadians => heading * (3.14159265359 / 180);

  // Compatibility getter for UI that uses isOnline
  bool get isOnline => isAppOnline && isOnlineVisible;
}
