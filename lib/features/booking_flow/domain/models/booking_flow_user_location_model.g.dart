// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_flow_user_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingFlowUserLocationModel _$BookingFlowUserLocationModelFromJson(
  Map<String, dynamic> json,
) => _BookingFlowUserLocationModel(
  locationText: json['locationText'] as String?,
  locationLat: (json['locationLat'] as num?)?.toDouble(),
  locationLng: (json['locationLng'] as num?)?.toDouble(),
);

Map<String, dynamic> _$BookingFlowUserLocationModelToJson(
  _BookingFlowUserLocationModel instance,
) => <String, dynamic>{
  'locationText': instance.locationText,
  'locationLat': instance.locationLat,
  'locationLng': instance.locationLng,
};
