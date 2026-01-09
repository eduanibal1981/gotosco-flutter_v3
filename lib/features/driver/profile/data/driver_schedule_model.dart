// lib/features/driver/profile/data/driver_schedule_model.dart

/// Model for driver weekly schedules
class DriverScheduleModel {
  final String id;
  final String driverId;
  final String dayOfWeek;
  final String shiftType;
  final String availableFrom; // Time as string HH:MM
  final String availableUntil; // Time as string HH:MM
  final int maxCapacity;
  final bool isActive;

  DriverScheduleModel({
    required this.id,
    required this.driverId,
    required this.dayOfWeek,
    required this.shiftType,
    required this.availableFrom,
    required this.availableUntil,
    this.maxCapacity = 8,
    this.isActive = true,
  });

  factory DriverScheduleModel.fromMap(Map<String, dynamic> map) {
    return DriverScheduleModel(
      id: map['id'] ?? '',
      driverId: map['driver_id'] ?? '',
      dayOfWeek: map['day_of_week'] ?? '',
      shiftType: map['shift_type'] ?? '',
      availableFrom: map['available_from'] ?? '',
      availableUntil: map['available_until'] ?? '',
      maxCapacity: map['max_capacity'] ?? 8,
      isActive: map['is_active'] ?? true,
    );
  }

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
