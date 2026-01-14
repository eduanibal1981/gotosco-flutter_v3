import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/driver_ad_model.dart';
import '../data/drivers_repository.dart';

part 'drivers_controller.g.dart';

/// Provider for searching driver ads with pagination support.
/// Replaces the simple FutureProvider to handle infinite scrolling.
@riverpod
class DriverAds extends _$DriverAds {
  static const int _limit = 20;

  // Internal state for pagination
  int _pageOffset = 0;
  bool _hasMore = true;

  @override
  Future<List<DriverAdModel>> build({double? lat, double? lng}) async {
    // 1. Reset pagination state whenever the provider is fully rebuilt
    // (This happens when arguments change OR when watched dependencies change)
    _pageOffset = 0;
    _hasMore = true;

    // 2. Watch filters. If filters change, this build() method runs again,
    // automatically resetting the list and starting from offset 0.
    final filters = ref.watch(driversFilterControllerProvider);

    return _fetchPage(filters, 0);
  }

  /// Helper to fetch a single page
  Future<List<DriverAdModel>> _fetchPage(
    Map<String, dynamic> filters,
    int offset,
  ) async {
    final results = await ref
        .read(driversRepositoryProvider)
        .searchDrivers(
          filters,
          limit: _limit,
          offset: offset,
          parentLat: lat,
          parentLng: lng,
        );

    // If we got fewer items than limit, we've reached the end.
    if (results.length < _limit) {
      _hasMore = false;
    }
    return results;
  }

  /// Public method to load the next page
  Future<void> loadNextPage() async {
    // Guard clauses
    if (!_hasMore || state.isLoading || state.hasError) return;

    // Show loading state while keeping previous data
    state = const AsyncLoading<List<DriverAdModel>>().copyWithPrevious(state);

    try {
      final filters = ref.read(driversFilterControllerProvider);
      _pageOffset += _limit;

      final newDrivers = await _fetchPage(filters, _pageOffset);

      // Append new items to the existing list
      final currentList = state.value ?? [];
      state = AsyncData([...currentList, ...newDrivers]);
    } catch (e, st) {
      // Revert to error state, but keep previous data if possible
      state = AsyncError<List<DriverAdModel>>(e, st).copyWithPrevious(state);
    }
  }
}

/// Providers for reference data
@riverpod
Future<List<Map<String, dynamic>>> cities(Ref ref) {
  return ref.watch(driversRepositoryProvider).getCities();
}

@riverpod
Future<List<Map<String, dynamic>>> areas(Ref ref, {String? cityId}) {
  return ref.watch(driversRepositoryProvider).getAreas(cityId: cityId);
}

@riverpod
Future<List<Map<String, dynamic>>> schools(Ref ref, {String? cityId}) {
  return ref.watch(driversRepositoryProvider).getSchools(cityId: cityId);
}

@riverpod
Future<({double min, double max})> priceRange(Ref ref) {
  return ref.watch(driversRepositoryProvider).getPriceLimits();
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
