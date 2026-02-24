// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverBooking _$DriverBookingFromJson(Map<String, dynamic> json) =>
    _DriverBooking(
      id: json['id'] as String,
      driverId: json['driver_id'] as String,
      parentId: json['parent_id'] as String,
      status: json['status'] as String? ?? 'pending',
      bookingType: json['booking_type'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      proposalPrice: (json['proposal_price'] as num?)?.toDouble(),
      homeLocation: json['hometxt_location'] as String? ?? '',
      schoolLocation: json['schooltxt_location'] as String? ?? '',
      homeLat: (json['home_lat'] as num?)?.toDouble(),
      homeLng: (json['home_lng'] as num?)?.toDouble(),
      schoolLat: (json['school_lat'] as num?)?.toDouble(),
      schoolLng: (json['school_lng'] as num?)?.toDouble(),
      schoolId: json['school_id'] as String?,
      schoolIds: (json['school_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      schoolName: json['school_name'] as String?,
      homePickupTime: json['home_pickup_time'] as String?,
      schoolPickupTime: json['school_pickup_time'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurringDays:
          (json['recurring_days'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isMonthlySubscription: json['is_monthly_subscription'] as bool? ?? false,
      subscriptionStatus: json['subscription_status'] as String?,
      contractStartDate: json['contract_start_date'] as String?,
      contractEndDate: json['contract_end_date'] as String?,
      pauseStartDate: json['pause_start_date'] as String?,
      pauseEndDate: json['pause_end_date'] as String?,
      cancellationType: json['cancellation_type'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      cancelRequestedAt: json['cancel_requested_at'] as String?,
      cancelledAt: json['cancelled_at'] as String?,
      routegoOrder: (json['routego_order'] as num?)?.toInt(),
      routeretOrder: (json['routeret_order'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      parentName: json['parent_name'] as String?,
      parentPhoto: json['parent_photo'] as String?,
      parentPhone: json['parent_phone'] as String?,
      children:
          (json['children'] as List<dynamic>?)
              ?.map((e) => BookingChild.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DriverBookingToJson(_DriverBooking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driver_id': instance.driverId,
      'parent_id': instance.parentId,
      'status': instance.status,
      'booking_type': instance.bookingType,
      'price': instance.price,
      'proposal_price': instance.proposalPrice,
      'hometxt_location': instance.homeLocation,
      'schooltxt_location': instance.schoolLocation,
      'home_lat': instance.homeLat,
      'home_lng': instance.homeLng,
      'school_lat': instance.schoolLat,
      'school_lng': instance.schoolLng,
      'school_id': instance.schoolId,
      'school_ids': instance.schoolIds,
      'school_name': instance.schoolName,
      'home_pickup_time': instance.homePickupTime,
      'school_pickup_time': instance.schoolPickupTime,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'created_at': instance.createdAt,
      'is_recurring': instance.isRecurring,
      'recurring_days': instance.recurringDays,
      'is_monthly_subscription': instance.isMonthlySubscription,
      'subscription_status': instance.subscriptionStatus,
      'contract_start_date': instance.contractStartDate,
      'contract_end_date': instance.contractEndDate,
      'pause_start_date': instance.pauseStartDate,
      'pause_end_date': instance.pauseEndDate,
      'cancellation_type': instance.cancellationType,
      'cancellation_reason': instance.cancellationReason,
      'cancel_requested_at': instance.cancelRequestedAt,
      'cancelled_at': instance.cancelledAt,
      'routego_order': instance.routegoOrder,
      'routeret_order': instance.routeretOrder,
      'notes': instance.notes,
      'parent_name': instance.parentName,
      'parent_photo': instance.parentPhoto,
      'parent_phone': instance.parentPhone,
      'children': instance.children,
    };

_BookingChild _$BookingChildFromJson(Map<String, dynamic> json) =>
    _BookingChild(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      schoolName: json['school_name'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
    );

Map<String, dynamic> _$BookingChildToJson(_BookingChild instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'school_name': instance.schoolName,
      'grade': instance.grade,
      'age': instance.age,
      'gender': instance.gender,
    };
