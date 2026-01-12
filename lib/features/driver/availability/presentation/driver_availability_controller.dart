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

  /// Toggle online/offline status
  Future<void> toggleOnline() async {
    final current = state.value;
    if (current == null) return;

    final newStatus = !current.isOnline;

    // Optimistic update
    state = AsyncData(current.copyWith(isOnline: newStatus));

    try {
      await ref
          .read(driverAvailabilityRepositoryProvider)
          .setOnlineStatus(newStatus);
      ref.invalidateSelf();
    } catch (e) {
      // Revert on error
      state = AsyncData(current);
      rethrow;
    }
  }

  /// Set online status directly
  Future<void> setOnline(bool isOnline) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(isOnline: isOnline));

    try {
      await ref
          .read(driverAvailabilityRepositoryProvider)
          .setOnlineStatus(isOnline);
      ref.invalidateSelf();
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
      ref.invalidateSelf();
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
      ref.invalidateSelf();
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
      ref.invalidateSelf();
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
        ref.invalidateSelf();
      }
      return result;
    } catch (e) {
      return false;
    }
  }
}
