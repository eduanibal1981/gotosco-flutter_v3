// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(locationRepository)
final locationRepositoryProvider = LocationRepositoryProvider._();

final class LocationRepositoryProvider
    extends
        $FunctionalProvider<
          LocationContract,
          LocationContract,
          LocationContract
        >
    with $Provider<LocationContract> {
  LocationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationRepositoryHash();

  @$internal
  @override
  $ProviderElement<LocationContract> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationContract create(Ref ref) {
    return locationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationContract value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationContract>(value),
    );
  }
}

String _$locationRepositoryHash() =>
    r'066c086106f63df7a04f343cdb98b7c440b9b270';
