// lib/features/driver/availability/presentation/driver_availability_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/driver_availability_model.dart';
import '../data/driver_availability_repository.dart';

part 'driver_availability_controller.g.dart';

@riverpod
class DriverAvailabilityController extends _$DriverAvailabilityController {
  @override
  Future<DriverAvailabilitySettings> build() async {
    return ref.watch(driverAvailabilitySettingsProvider.future);
  }

  /// Toggle profile visibility (Ad online/offline)
  Future<void> toggleProfileVisibility() async {
    final current = state.value;
    if (current == null) return;

    final newStatus = !current.isProfileOnline;

    // Optimistic update
    state = AsyncData(current.copyWith(isProfileOnline: newStatus));

    try {
      await ref
          .read(driverAvailabilityRepositoryProvider)
          .setProfileOnlineStatus(newStatus);
      ref.invalidate(driverAvailabilitySettingsProvider);
    } catch (e) {
      // Revert on error
      state = AsyncData(current);
      rethrow;
    }
  }

  /// Toggle tracking status
  Future<void> toggleTracking() async {
    final current = state.value;
    if (current == null) return;

    final newStatus = !current.isTrackingActive;

    // Optimistic update
    state = AsyncData(current.copyWith(isTrackingActive: newStatus));

    try {
      await ref
          .read(driverAvailabilityRepositoryProvider)
          .setTrackingStatus(newStatus);
      ref.invalidate(driverAvailabilitySettingsProvider);
    } catch (e) {
      // Revert on error
      state = AsyncData(current);
      rethrow;
    }
  }

  /// Set tracking status directly
  Future<void> setTracking(bool isTracking) async {
    final current = state.value;
    if (current == null) return;

    // Optimistic update
    state = AsyncData(current.copyWith(isTrackingActive: isTracking));

    try {
      await ref
          .read(driverAvailabilityRepositoryProvider)
          .setTrackingStatus(isTracking);
      ref.invalidate(driverAvailabilitySettingsProvider);
    } catch (e) {
      state = AsyncData(current);
      rethrow;
    }
  }

  /// Update availability mode (smart/manual)
  Future<void> setMode(String mode) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(availabilityMode: mode));

    try {
      await ref
          .read(driverAvailabilityRepositoryProvider)
          .updateSettings(availabilityMode: mode);
      ref.invalidate(driverAvailabilitySettingsProvider);
    } catch (e) {
      state = AsyncData(current);
      rethrow;
    }
  }

  /// Update auto-offline setting
  Future<void> setAutoOffline(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(autoOfflineAfterTrip: enabled));

    try {
      await ref
          .read(driverAvailabilityRepositoryProvider)
          .updateSettings(autoOfflineAfterTrip: enabled);
      ref.invalidate(driverAvailabilitySettingsProvider);
    } catch (e) {
      state = AsyncData(current);
      rethrow;
    }
  }

  /// Update auto-online settings
  Future<void> setAutoOnline({bool? enabled, int? minutesBefore}) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        autoOnlineBeforeTrip: enabled ?? current.autoOnlineBeforeTrip,
        autoOnlineMinutesBefore:
            minutesBefore ?? current.autoOnlineMinutesBefore,
      ),
    );

    try {
      await ref
          .read(driverAvailabilityRepositoryProvider)
          .updateSettings(
            autoOnlineBeforeTrip: enabled,
            autoOnlineMinutesBefore: minutesBefore,
          );
      ref.invalidate(driverAvailabilitySettingsProvider);
    } catch (e) {
      state = AsyncData(current);
      rethrow;
    }
  }

  /// Check and trigger auto-online if within schedule window
  Future<bool> checkAutoOnline() async {
    try {
      final result = await ref
          .read(driverAvailabilityRepositoryProvider)
          .checkAndAutoOnline();
      if (result) {
        ref.invalidate(driverAvailabilitySettingsProvider);
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Set user app online status (App lifecycle)
  Future<void> setUserAppOnline(bool isOnline) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(isAppOnline: isOnline));

    try {
      await ref
          .read(driverAvailabilityRepositoryProvider)
          .setUserOnlineStatus(isOnline);
    } catch (e) {
      state = AsyncData(current);
      // Don't rethrow for lifecycle updates to avoid crashing
      print('Error setting app online status: $e');
    }
  }

  /// Toggle online visibility preference
  Future<void> toggleOnlineVisibilityPreference() async {
    final current = state.value;
    if (current == null) return;

    final newStatus = !current.isOnlineVisible;
    state = AsyncData(current.copyWith(isOnlineVisible: newStatus));

    try {
      await ref
          .read(driverAvailabilityRepositoryProvider)
          .setOnlineVisibility(newStatus);
      ref.invalidate(driverAvailabilitySettingsProvider);
    } catch (e) {
      state = AsyncData(current);
      rethrow;
    }
  }
}
