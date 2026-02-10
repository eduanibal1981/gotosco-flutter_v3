import 'package:gotosco_v3/features/parent/find_driver/data/repositories/location_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/driver_ad_model.dart';
import '../data/repositories/drivers_repository_impl.dart';

export '../data/repositories/drivers_repository_impl.dart';
export '../data/repositories/location_repository_impl.dart';

part 'find_driver_providers.g.dart';

@riverpod
Future<List<DriverAdModel>> nearbyDrivers(Ref ref) {
  return ref.watch(driversRepositoryProvider).getNearbyDrivers();
}

/// Controller that manages driver filters state.
@riverpod
class DriversFilterController extends _$DriversFilterController {
  static const double defaultMaxPrice = 5000.0;

  @override
  Map<String, dynamic> build() => {
    'gender': 'All',
    'maxPrice': defaultMaxPrice,
    'vehicleType': 'All',
    'cityId': null,
    'areaId': null,
    'schoolId': null,
    'searchQuery': '',
  };

  void updateFilters(Map<String, dynamic> updates) {
    state = {...state, ...updates};
  }

  void clearFilters() {
    state = {
      'gender': 'All',
      'maxPrice': defaultMaxPrice,
      'vehicleType': 'All',
      'cityId': null,
      'areaId': null,
      'schoolId': null,
      'searchQuery': '',
    };
  }

  String? get filterSummary {
    final List<String> active = [];
    if (state['searchQuery'] != null &&
        (state['searchQuery'] as String).isNotEmpty) {
      active.add("Search: ${state['searchQuery']}");
    }
    if (state['cityId'] != null || state['areaId'] != null) {
      active.add("Location");
    }
    if (state['schoolId'] != null) {
      active.add("School");
    }
    if (state['gender'] != 'All') active.add(state['gender'] as String);
    if (state['vehicleType'] != 'All') {
      active.add(state['vehicleType'] as String);
    }

    final double price = (state['maxPrice'] as num).toDouble();
    if (price < defaultMaxPrice) active.add("Price (<${price.toInt()})");

    if (active.isEmpty) return null;
    return active.join(', ');
  }

  bool get hasActiveFilters => filterSummary != null;
}

@riverpod
class DriverAds extends _$DriverAds {
  static const int _limit = 20;
  int _pageOffset = 0;
  bool _hasMore = true;

  @override
  Future<List<DriverAdModel>> build({double? lat, double? lng}) async {
    _pageOffset = 0;
    _hasMore = true;
    final filters = ref.watch(driversFilterControllerProvider);
    return _fetchPage(filters, 0);
  }

  Future<List<DriverAdModel>> _fetchPage(
    Map<String, dynamic> filters,
    int offset,
  ) async {
    final searchQuery = filters['searchQuery'] as String?;
    final isSearching = searchQuery != null && searchQuery.isNotEmpty;
    final limit = isSearching ? 1000 : _limit;
    final fetchOffset = isSearching ? 0 : offset;

    final repo = ref.read(driversRepositoryProvider);

    final results = await repo.searchDrivers(
      filters,
      limit: limit,
      offset: fetchOffset,
      parentLat: lat,
      parentLng: lng,
    );

    if (isSearching) {
      _hasMore = false;
    } else {
      if (results.length < _limit) {
        _hasMore = false;
      }
    }
    return results;
  }

  Future<void> loadNextPage() async {
    if (!_hasMore || state.isLoading || state.hasError) return;

    try {
      final filters = ref.read(driversFilterControllerProvider);
      _pageOffset += _limit;

      final newDrivers = await _fetchPage(filters, _pageOffset);

      final currentList = state.value ?? [];
      state = AsyncData([...currentList, ...newDrivers]);
    } catch (e, st) {
      state = AsyncError<List<DriverAdModel>>(e, st);
    }
  }
}

/// REFERENCE DATA PROVIDERS

@riverpod
Future<List<Map<String, dynamic>>> cities(Ref ref) {
  return ref.watch(locationRepositoryProvider).getCities();
}

@riverpod
Future<List<Map<String, dynamic>>> areas(Ref ref, {String? cityId}) {
  return ref.watch(locationRepositoryProvider).getAreas(cityId: cityId);
}

@riverpod
Future<List<Map<String, dynamic>>> schools(
  Ref ref, {
  String? cityId,
  String? areaId,
}) {
  return ref
      .watch(locationRepositoryProvider)
      .getSchools(cityId: cityId, areaId: areaId);
}

@riverpod
Future<({double min, double max})> priceRange(Ref ref) {
  return ref.watch(driversRepositoryProvider).getPriceLimits();
}

/// FAVORITES PROVIDERS

@riverpod
Future<List<DriverAdModel>> favoriteDrivers(Ref ref) {
  return ref.watch(driversRepositoryProvider).getFavoriteDrivers();
}

@riverpod
class Favorites extends _$Favorites {
  @override
  Future<List<String>> build() async {
    return ref.watch(driversRepositoryProvider).getSavedDriverIds();
  }

  Future<void> toggleFavorite(String driverId) async {
    final currentList = state.value ?? [];
    var newList = <String>[];
    if (currentList.contains(driverId)) {
      newList = currentList.where((id) => id != driverId).toList();
    } else {
      newList = [...currentList, driverId];
    }
    state = AsyncValue.data(newList);

    try {
      await ref.read(driversRepositoryProvider).toggleFavorite(driverId);
      ref.invalidate(favoriteDriversProvider);
    } catch (e) {
      ref.invalidateSelf();
    }
  }
}
