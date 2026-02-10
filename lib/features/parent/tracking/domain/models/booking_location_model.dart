// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'booking_location_model.freezed.dart';
part 'booking_location_model.g.dart';

@freezed
abstract class BookingLocation with _$BookingLocation {
  const BookingLocation._();

  const factory BookingLocation({
    // booking_id is primary key of view
    @JsonKey(name: 'booking_id') required String bookingId,
    @JsonKey(name: 'home_lat') double? homeLat,
    @JsonKey(name: 'home_lng') double? homeLng,
    @JsonKey(name: 'school_lat') double? schoolLat,
    @JsonKey(name: 'school_lng') double? schoolLng,
    @JsonKey(name: 'driver_id') String? driverId,
    @JsonKey(name: 'driver_name') String? driverName,
    @JsonKey(name: 'driver_phone') String? driverPhone,
  }) = _BookingLocation;

  factory BookingLocation.fromJson(Map<String, dynamic> json) =>
      _$BookingLocationFromJson(json);

  bool get hasLocations =>
      (homeLat != null && homeLng != null) ||
      (schoolLat != null && schoolLng != null);

  LatLng? get home =>
      (homeLat != null && homeLng != null) ? LatLng(homeLat!, homeLng!) : null;
  LatLng? get school => (schoolLat != null && schoolLng != null)
      ? LatLng(schoolLat!, schoolLng!)
      : null;
}
