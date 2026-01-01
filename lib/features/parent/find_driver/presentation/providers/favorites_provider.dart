import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/drivers_repository.dart';

// 1. The Provider: Holds a List of Strings (Driver IDs)
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, AsyncValue<List<String>>>((ref) {
      return FavoritesNotifier(ref.watch(driversRepositoryProvider));
    });

// 2. The Notifier: Manages the logic
class FavoritesNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final DriversRepository _repository;

  FavoritesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final ids = await _repository.getSavedDriverIds();
      state = AsyncValue.data(ids);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavorite(String driverId) async {
    // Optimistic Update: Update UI immediately before API call finishes
    final currentList = state.value ?? [];
    if (currentList.contains(driverId)) {
      state = AsyncValue.data(
        currentList.where((id) => id != driverId).toList(),
      );
    } else {
      state = AsyncValue.data([...currentList, driverId]);
    }

    // Call API
    try {
      await _repository.toggleFavorite(driverId);
    } catch (e) {
      // Revert if API fails
      _loadFavorites();
    }
  }
}
