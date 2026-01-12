// lib/features/driver/availability/data/driver_availability_model.dart

/// Model for driver availability settings
class DriverAvailabilitySettings {
  final bool autoOfflineAfterTrip;
  final bool autoOnlineBeforeTrip;
  final int autoOnlineMinutesBefore;
  final String availabilityMode; // 'smart' | 'manual'
  final bool isOnline;

  const DriverAvailabilitySettings({
    this.autoOfflineAfterTrip = true,
    this.autoOnlineBeforeTrip = true,
    this.autoOnlineMinutesBefore = 15,
    this.availabilityMode = 'smart',
    this.isOnline = false,
  });

  /// Creates settings from Supabase RPC response
  factory DriverAvailabilitySettings.fromMap(Map<String, dynamic> map) {
    return DriverAvailabilitySettings(
      autoOfflineAfterTrip: map['auto_offline_after_trip'] as bool? ?? true,
      autoOnlineBeforeTrip: map['auto_online_before_trip'] as bool? ?? true,
      autoOnlineMinutesBefore: map['auto_online_minutes_before'] as int? ?? 15,
      availabilityMode: map['availability_mode'] as String? ?? 'smart',
      isOnline: map['is_online'] as bool? ?? false,
    );
  }

  /// Whether smart mode is enabled
  bool get isSmartMode => availabilityMode == 'smart';

  /// Whether manual mode is enabled
  bool get isManualMode => availabilityMode == 'manual';

  /// Creates a copy with updated fields
  DriverAvailabilitySettings copyWith({
    bool? autoOfflineAfterTrip,
    bool? autoOnlineBeforeTrip,
    int? autoOnlineMinutesBefore,
    String? availabilityMode,
    bool? isOnline,
  }) {
    return DriverAvailabilitySettings(
      autoOfflineAfterTrip: autoOfflineAfterTrip ?? this.autoOfflineAfterTrip,
      autoOnlineBeforeTrip: autoOnlineBeforeTrip ?? this.autoOnlineBeforeTrip,
      autoOnlineMinutesBefore:
          autoOnlineMinutesBefore ?? this.autoOnlineMinutesBefore,
      availabilityMode: availabilityMode ?? this.availabilityMode,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  String toString() =>
      'DriverAvailabilitySettings(mode: $availabilityMode, online: $isOnline, autoOff: $autoOfflineAfterTrip, autoOn: $autoOnlineBeforeTrip @ $autoOnlineMinutesBefore min)';
}
