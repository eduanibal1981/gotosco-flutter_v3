// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_flow_child_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingFlowChildModel _$BookingFlowChildModelFromJson(
  Map<String, dynamic> json,
) => _BookingFlowChildModel(
  id: json['id'] as String,
  name: json['name'] as String,
  schoolName: json['schoolName'] as String? ?? '',
  grade: json['grade'] as String? ?? '',
  photoUrl: json['photoUrl'] as String?,
  gender: json['gender'] as String?,
  dob: json['dob'] == null ? null : DateTime.parse(json['dob'] as String),
  medicalConditions: json['medicalConditions'] as String?,
  notes: json['notes'] as String?,
  schoolId: json['schoolId'] as String?,
  cityName: json['cityName'] as String?,
);

Map<String, dynamic> _$BookingFlowChildModelToJson(
  _BookingFlowChildModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'schoolName': instance.schoolName,
  'grade': instance.grade,
  'photoUrl': instance.photoUrl,
  'gender': instance.gender,
  'dob': instance.dob?.toIso8601String(),
  'medicalConditions': instance.medicalConditions,
  'notes': instance.notes,
  'schoolId': instance.schoolId,
  'cityName': instance.cityName,
};
