import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/drivers_repository.dart';

part 'favorites_provider.g.dart';

/// Manages the list of favorite driver IDs for the current user.
/// Uses AsyncNotifier pattern for proper async state management.
@riverpod
class Favorites extends _$Favorites {
  @override
  Future<List<String>> build() async {
    return ref.watch(driversRepositoryProvider).getSavedDriverIds();
  }

  /// Toggles a driver's favorite status with optimistic update.
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
      await ref.read(driversRepositoryProvider).toggleFavorite(driverId);
    } catch (e) {
      // Revert if API fails by re-fetching
      ref.invalidateSelf();
    }
  }
}
