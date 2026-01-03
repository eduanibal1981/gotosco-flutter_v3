// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

String _$favoritesHash() => r'4bf721f03e66e40819fa3211611f7cfe2ec5e2de';

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
