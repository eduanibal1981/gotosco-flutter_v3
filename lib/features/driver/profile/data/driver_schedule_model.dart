// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_schedule_model.freezed.dart';
part 'driver_schedule_model.g.dart';

/// Model for driver weekly schedules
@freezed
abstract class DriverScheduleModel with _$DriverScheduleModel {
  const DriverScheduleModel._();

  const factory DriverScheduleModel({
    @JsonKey(name: 'id')
    @Default('')
    String
    id, // id might be omitted in creates? No, usually id exists on fetch.
    // If creates, it might be null? The original model required id.
    // I'll make it default to empty string if missing?
    // Original had required id.
    // On create, we don't need id? `createSchedule` takes model.
    // If create, id might be empty string.
    @JsonKey(name: 'driver_id') required String driverId,
    @JsonKey(name: 'day_of_week') required String dayOfWeek,
    @JsonKey(name: 'shift_type') required String shiftType,
    @JsonKey(name: 'available_from') required String availableFrom,
    @JsonKey(name: 'available_until') required String availableUntil,
    @JsonKey(name: 'max_capacity') @Default(8) int maxCapacity,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _DriverScheduleModel;

  factory DriverScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$DriverScheduleModelFromJson(json);

  Map<String, dynamic> toMap() {
    return {
      'driver_id': driverId,
      'day_of_week': dayOfWeek,
      'shift_type': shiftType,
      'available_from': availableFrom,
      'available_until': availableUntil,
      'max_capacity': maxCapacity,
      'is_active': isActive,
    };
  }

  /// Get display name for day of week
  String get dayDisplayName {
    if (dayOfWeek.isEmpty) return '';
    return dayOfWeek[0].toUpperCase() + dayOfWeek.substring(1);
  }

  /// Get display name for shift type
  String get shiftDisplayName {
    switch (shiftType) {
      case 'Go to School(s)':
        return '🏫 To School';
      case 'Return from School(s)':
        return '🏠 From School';
      case 'custom':
        return '⚙️ Custom';
      default:
        return shiftType;
    }
  }

  /// Get formatted time range
  String get timeRange => '$availableFrom - $availableUntil';

  /// Get day index for sorting (Sunday = 0, Monday = 1, etc.)
  int get dayIndex => validDays.indexOf(dayOfWeek.toLowerCase());

  /// Valid days of week (ordered starting from Sunday)
  static const List<String> validDays = [
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
  ];

  /// Valid shift types
  static const List<String> validShiftTypes = [
    'Go to School(s)',
    'Return from School(s)',
    'custom',
  ];

  /// Shift type display names for UI
  static const Map<String, String> shiftTypeDisplayNames = {
    'Go to School(s)': '🏫 Go to School(s)',
    'Return from School(s)': '🏠 Return from School(s)',
    'custom': '⚙️ Custom Schedule',
  };
}
