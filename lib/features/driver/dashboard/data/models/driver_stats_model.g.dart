// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverStats _$DriverStatsFromJson(Map<String, dynamic> json) => _DriverStats(
  driverId: json['driver_id'] as String,
  activeStudents: (json['active_students'] as num?)?.toInt() ?? 0,
  pendingRequests: (json['pending_requests'] as num?)?.toInt() ?? 0,
  activeBookings: (json['active_bookings'] as num?)?.toInt() ?? 0,
  monthlyEarnings: (json['monthly_earnings'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$DriverStatsToJson(_DriverStats instance) =>
    <String, dynamic>{
      'driver_id': instance.driverId,
      'active_students': instance.activeStudents,
      'pending_requests': instance.pendingRequests,
      'active_bookings': instance.activeBookings,
      'monthly_earnings': instance.monthlyEarnings,
    };
