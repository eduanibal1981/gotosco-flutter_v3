// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_stats_model.freezed.dart';
part 'driver_stats_model.g.dart';

@freezed
abstract class DriverStats with _$DriverStats {
  const DriverStats._();

  const factory DriverStats({
    @JsonKey(name: 'driver_id') required String driverId,
    @JsonKey(name: 'active_students') @Default(0) int activeStudents,
    @JsonKey(name: 'pending_requests') @Default(0) int pendingRequests,
    @JsonKey(name: 'active_bookings') @Default(0) int activeBookings,
    @JsonKey(name: 'monthly_earnings') @Default(0) double monthlyEarnings,
  }) = _DriverStats;

  factory DriverStats.fromJson(Map<String, dynamic> json) =>
      _$DriverStatsFromJson(json);

  Map<String, dynamic> toLegacyMap() {
    return {
      'active_students': activeStudents,
      'pending_requests': pendingRequests,
      'active_bookings': activeBookings,
      'monthly_earnings': monthlyEarnings.toInt(), // Legacy expected int
    };
  }
}
