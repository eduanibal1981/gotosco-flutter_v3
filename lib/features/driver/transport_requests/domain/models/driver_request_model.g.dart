// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverRequest _$DriverRequestFromJson(Map<String, dynamic> json) =>
    _DriverRequest(
      id: json['id'] as String,
      parentId: json['parent_id'] as String,
      driverId: json['driver_id'] as String?,
      status: json['status'] as String?,
      bookingType: json['booking_type'] as String?,
      notes: json['notes'] as String?,
      parentName: json['parent_name'] as String?,
      parentPhoto: json['parent_photo'] as String?,
      parentPhone: json['parent_phone'] as String?,
      homeLocation: json['hometxt_location'] as String?,
      schoolLocation: json['schooltxt_location'] as String?,
      homeGeoLocation: json['homegeo_location'] as String?,
      schoolGeoLocation: json['schoolgeo_location'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      pickupTime: json['home_pickup_time'] as String?,
      recurringDays:
          (json['recurring_days'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      proposalPrice: json['proposal_price'],
      studentsInfo:
          (json['students_info'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      schoolsInfo:
          (json['schools_info'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      isMonthlySubscription: json['is_monthly_subscription'] as bool? ?? false,
      isRecurring: json['is_recurring'] as bool? ?? false,
      isMultiSchool: json['is_multi_school'] as bool? ?? false,
      schoolName: json['school_name'] as String?,
    );

Map<String, dynamic> _$DriverRequestToJson(_DriverRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parent_id': instance.parentId,
      'driver_id': instance.driverId,
      'status': instance.status,
      'booking_type': instance.bookingType,
      'notes': instance.notes,
      'parent_name': instance.parentName,
      'parent_photo': instance.parentPhoto,
      'parent_phone': instance.parentPhone,
      'hometxt_location': instance.homeLocation,
      'schooltxt_location': instance.schoolLocation,
      'homegeo_location': instance.homeGeoLocation,
      'schoolgeo_location': instance.schoolGeoLocation,
      'created_at': instance.createdAt?.toIso8601String(),
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'home_pickup_time': instance.pickupTime,
      'recurring_days': instance.recurringDays,
      'proposal_price': instance.proposalPrice,
      'students_info': instance.studentsInfo,
      'schools_info': instance.schoolsInfo,
      'is_monthly_subscription': instance.isMonthlySubscription,
      'is_recurring': instance.isRecurring,
      'is_multi_school': instance.isMultiSchool,
      'school_name': instance.schoolName,
    };
