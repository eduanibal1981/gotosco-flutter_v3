// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_flow_school_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingFlowSchoolModel _$BookingFlowSchoolModelFromJson(
  Map<String, dynamic> json,
) => _BookingFlowSchoolModel(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String?,
  cityId: json['cityId'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$BookingFlowSchoolModelToJson(
  _BookingFlowSchoolModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'cityId': instance.cityId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
