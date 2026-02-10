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
        $FunctionalProvider<
          DriversRepository,
          DriversRepository,
          DriversRepository
        >
    with $Provider<DriversRepository> {
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
  $ProviderElement<DriversRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DriversRepository create(Ref ref) {
    return driversRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriversRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriversRepository>(value),
    );
  }
}

String _$driversRepositoryHash() => r'997fec3994b5619f9c504191d66392a73dc0e249';
