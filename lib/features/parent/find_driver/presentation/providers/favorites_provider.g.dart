// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches the full details of favorite drivers.

@ProviderFor(favoriteDrivers)
final favoriteDriversProvider = FavoriteDriversProvider._();

/// Fetches the full details of favorite drivers.

final class FavoriteDriversProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DriverAdModel>>,
          List<DriverAdModel>,
          FutureOr<List<DriverAdModel>>
        >
    with
        $FutureModifier<List<DriverAdModel>>,
        $FutureProvider<List<DriverAdModel>> {
  /// Fetches the full details of favorite drivers.
  FavoriteDriversProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteDriversProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteDriversHash();

  @$internal
  @override
  $FutureProviderElement<List<DriverAdModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DriverAdModel>> create(Ref ref) {
    return favoriteDrivers(ref);
  }
}

String _$favoriteDriversHash() => r'efd2c448209c780eee8230bb7819eacf1e21f119';

/// Manages the list of favorite driver IDs for the current user.
/// Uses AsyncNotifier pattern for proper async state management.

@ProviderFor(Favorites)
final favoritesProvider = FavoritesProvider._();

/// Manages the list of favorite driver IDs for the current user.
/// Uses AsyncNotifier pattern for proper async state management.
final class FavoritesProvider
    extends $AsyncNotifierProvider<Favorites, List<String>> {
  /// Manages the list of favorite driver IDs for the current user.
  /// Uses AsyncNotifier pattern for proper async state management.
  FavoritesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesHash();

  @$internal
  @override
  Favorites create() => Favorites();
}

String _$favoritesHash() => r'b805137b1440a0c0758cb67ec10e49d8f0328904';

/// Manages the list of favorite driver IDs for the current user.
/// Uses AsyncNotifier pattern for proper async state management.

abstract class _$Favorites extends $AsyncNotifier<List<String>> {
  FutureOr<List<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
