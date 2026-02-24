// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drivers_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(driversRepository)
final driversRepositoryProvider = DriversRepositoryProvider._();

final class DriversRepositoryProvider
    extends
        $FunctionalProvider<DriversContract, DriversContract, DriversContract>
    with $Provider<DriversContract> {
  DriversRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driversRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driversRepositoryHash();

  @$internal
  @override
  $ProviderElement<DriversContract> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DriversContract create(Ref ref) {
    return driversRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriversContract value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriversContract>(value),
    );
  }
}

String _$driversRepositoryHash() => r'f7bd620c420fdfec14d9b5b1e3b4ae91dd41f6ed';
