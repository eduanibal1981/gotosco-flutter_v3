// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverScheduleModel _$DriverScheduleModelFromJson(Map<String, dynamic> json) =>
    _DriverScheduleModel(
      id: json['id'] as String? ?? '',
      driverId: json['driver_id'] as String,
      dayOfWeek: json['day_of_week'] as String,
      shiftType: json['shift_type'] as String,
      availableFrom: json['available_from'] as String,
      availableUntil: json['available_until'] as String,
      maxCapacity: (json['max_capacity'] as num?)?.toInt() ?? 8,
      isActive: json['is_schedactive'] as bool? ?? true,
    );

Map<String, dynamic> _$DriverScheduleModelToJson(
  _DriverScheduleModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'driver_id': instance.driverId,
  'day_of_week': instance.dayOfWeek,
  'shift_type': instance.shiftType,
  'available_from': instance.availableFrom,
  'available_until': instance.availableUntil,
  'max_capacity': instance.maxCapacity,
  'is_schedactive': instance.isActive,
};
