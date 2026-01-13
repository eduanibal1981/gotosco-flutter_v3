import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/driver_ad_model.dart';
import '../data/drivers_repository.dart';

part 'drivers_controller.g.dart';

/// Provider for searching driver ads.
/// watches [driversFilterControllerProvider] internally for filters.
/// Accepts [lat] and [lng] as arguments to avoid Maps in family.
@riverpod
Future<List<DriverAdModel>> driverAds(Ref ref, {double? lat, double? lng}) {
  final filters = ref.watch(driversFilterControllerProvider);
  return ref
      .watch(driversRepositoryProvider)
      .searchDrivers(filters, parentLat: lat, parentLng: lng);
}

/// Controller that manages driver filters state.
/// Provides filter summary and clear functionality.
@riverpod
class DriversFilterController extends _$DriversFilterController {
  static const double defaultMaxPrice = 200.0;

  @override
  Map<String, dynamic> build() => {
    'gender': 'All',
    'maxPrice': defaultMaxPrice,
    'vehicleType': 'All',
    'cityId': null,
    'areaId': null,
    'schoolId': null,
  };

  /// Updates filters with new values.
  void updateFilters(Map<String, dynamic> updates) {
    state = {...state, ...updates};
  }

  /// Resets all filters to defaults.
  void clearFilters() {
    state = {
      'gender': 'All',
      'maxPrice': defaultMaxPrice,
      'vehicleType': 'All',
      'cityId': null,
      'areaId': null,
      'schoolId': null,
    };
  }

  /// Returns a summary of active filters, or null if no filters applied.
  String? get filterSummary {
    final List<String> active = [];

    if (state['cityId'] != null || state['areaId'] != null) {
      active.add("Location");
    }
    if (state['schoolId'] != null) active.add("School");
    if (state['gender'] != 'All') active.add(state['gender'] as String);
    if (state['vehicleType'] != 'All')
      active.add(state['vehicleType'] as String);

    final double price = (state['maxPrice'] as num).toDouble();
    if (price < defaultMaxPrice) active.add("Price (<${price.toInt()})");

    if (active.isEmpty) return null;
    return active.join(', ');
  }

  /// Checks if any filters are active.
  bool get hasActiveFilters => filterSummary != null;
}
