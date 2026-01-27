// lib/features/driver/availability/data/driver_availability_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'driver_availability_model.dart';

part 'driver_availability_repository.g.dart';

@riverpod
DriverAvailabilityRepository driverAvailabilityRepository(Ref ref) {
  return DriverAvailabilityRepository(Supabase.instance.client);
}

/// Provider for current availability settings
@riverpod
Future<DriverAvailabilitySettings> driverAvailabilitySettings(Ref ref) async {
  return ref.watch(driverAvailabilityRepositoryProvider).getSettings();
}

class DriverAvailabilityRepository {
  final SupabaseClient _supabase;
  DriverAvailabilityRepository(this._supabase);

  /// Get current driver availability settings
  Future<DriverAvailabilitySettings> getSettings() async {
    try {
      final response = await _supabase.rpc('get_driver_availability_settings');

      if (response is List && response.isNotEmpty) {
        return DriverAvailabilitySettings.fromMap(
          Map<String, dynamic>.from(response.first),
        );
      }

      // Return defaults if no settings found
      return const DriverAvailabilitySettings();
    } catch (e) {
      print('Error fetching availability settings: $e');
      return const DriverAvailabilitySettings();
    }
  }

  /// Update availability settings
  Future<void> updateSettings({
    bool? autoOfflineAfterTrip,
    bool? autoOnlineBeforeTrip,
    int? autoOnlineMinutesBefore,
    String? availabilityMode,
  }) async {
    await _supabase.rpc(
      'update_driver_availability_settings',
      params: {
        'p_auto_offline_after_trip': autoOfflineAfterTrip,
        'p_auto_online_before_trip': autoOnlineBeforeTrip,
        'p_auto_online_minutes_before': autoOnlineMinutesBefore,
        'p_availability_mode': availabilityMode,
      },
    );
  }

  /// Set driver profile online status (Advertisement visibility)
  Future<void> setProfileOnlineStatus(bool isOnline) async {
    await _supabase.rpc(
      'set_profile_online_status',
      params: {'p_is_online': isOnline},
    );
  }

  /// Set driver tracking status (Live location sharing)
  Future<void> setTrackingStatus(bool isTracking) async {
    await _supabase.rpc(
      'set_tracking_status',
      params: {'p_is_tracking': isTracking},
    );
  }

  /// Check if driver should auto-go-online based on schedule
  /// Returns true if driver was set online
  Future<bool> checkAndAutoOnline() async {
    try {
      final result = await _supabase.rpc('check_auto_online');
      return result as bool? ?? false;
    } catch (e) {
      print('Error checking auto-online: $e');
      return false;
    }
  }

  /// Complete trip with smart auto-offline handling
  Future<void> completeTripWithAutoOffline(
    String tripId, {
    double? lat,
    double? lng,
  }) async {
    await _supabase.rpc(
      'complete_trip_with_auto_offline',
      params: {'trip_id_input': tripId, 'driver_lat': lat, 'driver_lng': lng},
    );
  }
}
