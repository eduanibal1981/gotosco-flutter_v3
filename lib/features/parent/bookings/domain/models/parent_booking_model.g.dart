// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParentBooking _$ParentBookingFromJson(Map<String, dynamic> json) =>
    _ParentBooking(
      id: json['id'] as String,
      parentId: json['parent_id'] as String,
      driverId: json['driver_id'] as String?,
      bookingType: json['booking_type'] as String,
      status: json['status'] as String?,
      hometxtLocation: json['hometxt_location'] as String?,
      schooltxtLocation: json['schooltxt_location'] as String?,
      homePickupTime: json['home_pickup_time'] as String?,
      schoolPickupTime: json['school_pickup_time'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      proposalPrice: (json['proposal_price'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurrencePattern: json['recurrence_pattern'] as Map<String, dynamic>?,
      subscriptionStatus: json['subscription_status'] as String?,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      recurringDays: (json['recurring_days'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isMonthlySubscription: json['is_monthly_subscription'] as bool? ?? false,
      homegeoLocationText: json['homegeo_location_text'] as String?,
      schoolgeoLocationText: json['schoolgeo_location_text'] as String?,
      homeLat: (json['home_lat'] as num?)?.toDouble(),
      homeLng: (json['home_lng'] as num?)?.toDouble(),
      schoolLat: (json['school_lat'] as num?)?.toDouble(),
      schoolLng: (json['school_lng'] as num?)?.toDouble(),
      routegoOrder: (json['routego_order'] as num?)?.toInt(),
      routeretOrder: (json['routeret_order'] as num?)?.toInt(),
      studentId: json['student_id'] as String?,
      schoolId: json['school_id'] as String?,
      schoolName: json['school_name'] as String?,
      schoolIds: (json['school_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isMultiSchool: json['is_multi_school'] as bool? ?? false,
      paymentStatus: json['payment_status'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
      cancellationType: json['cancellation_type'] as String?,
      cancellationFee: (json['cancellation_fee'] as num?)?.toDouble(),
      cancelRequestedAt: json['cancel_requested_at'] == null
          ? null
          : DateTime.parse(json['cancel_requested_at'] as String),
      contractStartDate: json['contract_start_date'] == null
          ? null
          : DateTime.parse(json['contract_start_date'] as String),
      contractEndDate: json['contract_end_date'] == null
          ? null
          : DateTime.parse(json['contract_end_date'] as String),
      pauseStartDate: json['pause_start_date'] == null
          ? null
          : DateTime.parse(json['pause_start_date'] as String),
      pauseEndDate: json['pause_end_date'] == null
          ? null
          : DateTime.parse(json['pause_end_date'] as String),
      tripCategory: json['trip_category'] as String?,
      isOneTime: json['is_one_time'] as bool? ?? false,
      scheduledPickupDatetime: json['scheduled_pickup_datetime'] == null
          ? null
          : DateTime.parse(json['scheduled_pickup_datetime'] as String),
      scheduledDropoffDatetime: json['scheduled_dropoff_datetime'] == null
          ? null
          : DateTime.parse(json['scheduled_dropoff_datetime'] as String),
      customPickupLocationText: json['custom_pickup_location_text'] as String?,
      customPickupGeoText: json['custom_pickup_geo_text'] as String?,
      customDropoffLocationText:
          json['custom_dropoff_location_text'] as String?,
      customDropoffGeoText: json['custom_dropoff_geo_text'] as String?,
      customPickupLat: (json['custom_pickup_lat'] as num?)?.toDouble(),
      customPickupLng: (json['custom_pickup_lng'] as num?)?.toDouble(),
      customDropoffLat: (json['custom_dropoff_lat'] as num?)?.toDouble(),
      customDropoffLng: (json['custom_dropoff_lng'] as num?)?.toDouble(),
      bookingFlowStep: json['booking_flow_step'] as String?,
      totalEstimatedDistanceKm: (json['total_estimated_distance_km'] as num?)
          ?.toDouble(),
      totalEstimatedDurationMinutes:
          (json['total_estimated_duration_minutes'] as num?)?.toInt(),
      isForParent: json['is_for_parent'] as bool? ?? false,
      driverName: json['driver_name'] as String?,
      driverPhoto: json['driver_photo'] as String?,
      driverPhone: json['driver_phone'] as String?,
      schoolNameLookup: json['school_name_lookup'] as String?,
      schoolAddress: json['school_address'] as String?,
      kidsCount: (json['kids_count'] as num?)?.toInt() ?? 0,
      childNames:
          (json['child_names'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      studentsInfo:
          (json['students_info'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ParentBookingToJson(
  _ParentBooking instance,
) => <String, dynamic>{
  'id': instance.id,
  'parent_id': instance.parentId,
  'driver_id': instance.driverId,
  'booking_type': instance.bookingType,
  'status': instance.status,
  'hometxt_location': instance.hometxtLocation,
  'schooltxt_location': instance.schooltxtLocation,
  'home_pickup_time': instance.homePickupTime,
  'school_pickup_time': instance.schoolPickupTime,
  'price': instance.price,
  'proposal_price': instance.proposalPrice,
  'notes': instance.notes,
  'created_at': instance.createdAt?.toIso8601String(),
  'is_recurring': instance.isRecurring,
  'recurrence_pattern': instance.recurrencePattern,
  'subscription_status': instance.subscriptionStatus,
  'start_date': instance.startDate?.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'recurring_days': instance.recurringDays,
  'is_monthly_subscription': instance.isMonthlySubscription,
  'homegeo_location_text': instance.homegeoLocationText,
  'schoolgeo_location_text': instance.schoolgeoLocationText,
  'home_lat': instance.homeLat,
  'home_lng': instance.homeLng,
  'school_lat': instance.schoolLat,
  'school_lng': instance.schoolLng,
  'routego_order': instance.routegoOrder,
  'routeret_order': instance.routeretOrder,
  'student_id': instance.studentId,
  'school_id': instance.schoolId,
  'school_name': instance.schoolName,
  'school_ids': instance.schoolIds,
  'is_multi_school': instance.isMultiSchool,
  'payment_status': instance.paymentStatus,
  'cancellation_reason': instance.cancellationReason,
  'cancelled_at': instance.cancelledAt?.toIso8601String(),
  'cancellation_type': instance.cancellationType,
  'cancellation_fee': instance.cancellationFee,
  'cancel_requested_at': instance.cancelRequestedAt?.toIso8601String(),
  'contract_start_date': instance.contractStartDate?.toIso8601String(),
  'contract_end_date': instance.contractEndDate?.toIso8601String(),
  'pause_start_date': instance.pauseStartDate?.toIso8601String(),
  'pause_end_date': instance.pauseEndDate?.toIso8601String(),
  'trip_category': instance.tripCategory,
  'is_one_time': instance.isOneTime,
  'scheduled_pickup_datetime': instance.scheduledPickupDatetime
      ?.toIso8601String(),
  'scheduled_dropoff_datetime': instance.scheduledDropoffDatetime
      ?.toIso8601String(),
  'custom_pickup_location_text': instance.customPickupLocationText,
  'custom_pickup_geo_text': instance.customPickupGeoText,
  'custom_dropoff_location_text': instance.customDropoffLocationText,
  'custom_dropoff_geo_text': instance.customDropoffGeoText,
  'custom_pickup_lat': instance.customPickupLat,
  'custom_pickup_lng': instance.customPickupLng,
  'custom_dropoff_lat': instance.customDropoffLat,
  'custom_dropoff_lng': instance.customDropoffLng,
  'booking_flow_step': instance.bookingFlowStep,
  'total_estimated_distance_km': instance.totalEstimatedDistanceKm,
  'total_estimated_duration_minutes': instance.totalEstimatedDurationMinutes,
  'is_for_parent': instance.isForParent,
  'driver_name': instance.driverName,
  'driver_photo': instance.driverPhoto,
  'driver_phone': instance.driverPhone,
  'school_name_lookup': instance.schoolNameLookup,
  'school_address': instance.schoolAddress,
  'kids_count': instance.kidsCount,
  'child_names': instance.childNames,
  'students_info': instance.studentsInfo,
};
