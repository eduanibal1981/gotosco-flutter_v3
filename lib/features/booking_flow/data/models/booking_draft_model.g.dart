// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_draft_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingDraftModel _$BookingDraftModelFromJson(Map<String, dynamic> json) =>
    _BookingDraftModel(
      studentId: json['studentId'] as String?,
      studentIds:
          (json['studentIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isMultiSchool: json['isMultiSchool'] as bool? ?? false,
      schoolLocations:
          (json['schoolLocations'] as List<dynamic>?)
              ?.map(
                (e) => SchoolLocationModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      tripCategory: json['tripCategory'] as String? ?? 'school',
      bookingType: json['bookingType'] as String?,
      pickupLocationText: json['pickupLocationText'] as String?,
      pickupLat: (json['pickupLat'] as num?)?.toDouble(),
      pickupLng: (json['pickupLng'] as num?)?.toDouble(),
      dropoffLocationText: json['dropoffLocationText'] as String?,
      dropoffLat: (json['dropoffLat'] as num?)?.toDouble(),
      dropoffLng: (json['dropoffLng'] as num?)?.toDouble(),
      isOneTime: json['isOneTime'] as bool? ?? false,
      isRecurring: json['isRecurring'] as bool? ?? false,
      isMonthlySubscription: json['isMonthlySubscription'] as bool? ?? true,
      scheduledPickupDatetime: json['scheduledPickupDatetime'] == null
          ? null
          : DateTime.parse(json['scheduledPickupDatetime'] as String),
      scheduledDropoffDatetime: json['scheduledDropoffDatetime'] == null
          ? null
          : DateTime.parse(json['scheduledDropoffDatetime'] as String),
      contractStartDate: json['contractStartDate'] == null
          ? null
          : DateTime.parse(json['contractStartDate'] as String),
      contractEndDate: json['contractEndDate'] == null
          ? null
          : DateTime.parse(json['contractEndDate'] as String),
      recurringDays: (json['recurringDays'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      homePickupTime: json['homePickupTime'] as String?,
      schoolPickupTime: json['schoolPickupTime'] as String?,
      driverId: json['driverId'] as String?,
      estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
      totalEstimatedDistanceKm: (json['totalEstimatedDistanceKm'] as num?)
          ?.toDouble(),
      totalEstimatedDurationMinutes:
          (json['totalEstimatedDurationMinutes'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 1,
      flowStep: json['flowStep'] as String? ?? 'draft',
    );

Map<String, dynamic> _$BookingDraftModelToJson(_BookingDraftModel instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'studentIds': instance.studentIds,
      'isMultiSchool': instance.isMultiSchool,
      'schoolLocations': instance.schoolLocations,
      'tripCategory': instance.tripCategory,
      'bookingType': instance.bookingType,
      'pickupLocationText': instance.pickupLocationText,
      'pickupLat': instance.pickupLat,
      'pickupLng': instance.pickupLng,
      'dropoffLocationText': instance.dropoffLocationText,
      'dropoffLat': instance.dropoffLat,
      'dropoffLng': instance.dropoffLng,
      'isOneTime': instance.isOneTime,
      'isRecurring': instance.isRecurring,
      'isMonthlySubscription': instance.isMonthlySubscription,
      'scheduledPickupDatetime': instance.scheduledPickupDatetime
          ?.toIso8601String(),
      'scheduledDropoffDatetime': instance.scheduledDropoffDatetime
          ?.toIso8601String(),
      'contractStartDate': instance.contractStartDate?.toIso8601String(),
      'contractEndDate': instance.contractEndDate?.toIso8601String(),
      'recurringDays': instance.recurringDays,
      'homePickupTime': instance.homePickupTime,
      'schoolPickupTime': instance.schoolPickupTime,
      'driverId': instance.driverId,
      'estimatedPrice': instance.estimatedPrice,
      'totalEstimatedDistanceKm': instance.totalEstimatedDistanceKm,
      'totalEstimatedDurationMinutes': instance.totalEstimatedDurationMinutes,
      'notes': instance.notes,
      'currentStep': instance.currentStep,
      'flowStep': instance.flowStep,
    };
