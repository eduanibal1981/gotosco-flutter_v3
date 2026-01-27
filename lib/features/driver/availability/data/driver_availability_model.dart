// lib/features/driver/availability/data/driver_availability_model.dart

/// Model for driver availability settings
class DriverAvailabilitySettings {
  final bool autoOfflineAfterTrip;
  final bool autoOnlineBeforeTrip;
  final int autoOnlineMinutesBefore;
  final String availabilityMode; // 'smart' | 'manual'
  final bool isProfileOnline;
  final bool isTrackingActive;

  const DriverAvailabilitySettings({
    this.autoOfflineAfterTrip = true,
    this.autoOnlineBeforeTrip = true,
    this.autoOnlineMinutesBefore = 15,
    this.availabilityMode = 'smart',
    this.isProfileOnline = false,
    this.isTrackingActive = false,
  });

  /// Creates settings from Supabase RPC response
  factory DriverAvailabilitySettings.fromMap(Map<String, dynamic> map) {
    return DriverAvailabilitySettings(
      autoOfflineAfterTrip: map['auto_offline_after_trip'] as bool? ?? true,
      autoOnlineBeforeTrip: map['auto_online_before_trip'] as bool? ?? true,
      autoOnlineMinutesBefore: map['auto_online_minutes_before'] as int? ?? 15,
      availabilityMode: map['availability_mode'] as String? ?? 'smart',
      isProfileOnline: map['is_profile_online'] as bool? ?? false,
      isTrackingActive: map['is_tracking_active'] as bool? ?? false,
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
    bool? isProfileOnline,
    bool? isTrackingActive,
  }) {
    return DriverAvailabilitySettings(
      autoOfflineAfterTrip: autoOfflineAfterTrip ?? this.autoOfflineAfterTrip,
      autoOnlineBeforeTrip: autoOnlineBeforeTrip ?? this.autoOnlineBeforeTrip,
      autoOnlineMinutesBefore:
          autoOnlineMinutesBefore ?? this.autoOnlineMinutesBefore,
      availabilityMode: availabilityMode ?? this.availabilityMode,
      isProfileOnline: isProfileOnline ?? this.isProfileOnline,
      isTrackingActive: isTrackingActive ?? this.isTrackingActive,
    );
  }

  @override
  String toString() =>
      'DriverAvailabilitySettings(mode: $availabilityMode, profileOnline: $isProfileOnline, tracking: $isTrackingActive)';
}
