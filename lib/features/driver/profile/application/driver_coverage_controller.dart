import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/driver_coverage_repository.dart';
import '../data/driver_profile_repository.dart';
import '../../dashboard/application/driver_dashboard_providers.dart';

part 'driver_coverage_controller.g.dart';

@riverpod
class DriverCoverageController extends _$DriverCoverageController {
  @override
  Future<void> build() async {}

  Future<void> saveCoverage({
    required Set<String> areaIds,
    required Set<String> schoolIds,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(driverCoverageRepositoryProvider)
          .setDriverCoverage(
            driverId: userId,
            areaIds: areaIds,
            schoolIds: schoolIds,
          );
      _invalidateProviders();
    });
  }

  Future<void> saveAreas(Set<String> areaIds) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(driverCoverageRepositoryProvider)
          .saveAreaCoverage(driverId: userId, areaIds: areaIds);
      ref.invalidate(driverCoverageAreaIdsProvider);
      ref.invalidate(currentDriverProfileProvider);
      ref.invalidate(driverProfileProvider);
      ref.invalidate(driverDashboardStateProvider);
    });
  }

  Future<void> saveSchools(Set<String> schoolIds) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(driverCoverageRepositoryProvider)
          .saveSchoolCoverage(driverId: userId, schoolIds: schoolIds);
      ref.invalidate(driverCoverageSchoolIdsProvider);
      ref.invalidate(currentDriverProfileProvider);
      ref.invalidate(driverProfileProvider);
      ref.invalidate(driverDashboardStateProvider);
    });
  }

  void _invalidateProviders() {
    ref.invalidate(driverCoverageAreaIdsProvider);
    ref.invalidate(driverCoverageSchoolIdsProvider);
    ref.invalidate(currentDriverProfileProvider);
    ref.invalidate(driverProfileProvider);
    ref.invalidate(driverDashboardStateProvider);
  }
}
