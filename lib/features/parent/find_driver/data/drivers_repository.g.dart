// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drivers_repository.dart';

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

String _$driversRepositoryHash() => r'9f8b0dc2a1a389b315c5a605de6e8665f1231655';

/// Provider for searching driver ads with filters.
/// The UI watches this to display filtered results.

@ProviderFor(driverAds)
final driverAdsProvider = DriverAdsFamily._();

/// Provider for searching driver ads with filters.
/// The UI watches this to display filtered results.

final class DriverAdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DriverAdModel>>,
          List<DriverAdModel>,
          FutureOr<List<DriverAdModel>>
        >
    with
        $FutureModifier<List<DriverAdModel>>,
        $FutureProvider<List<DriverAdModel>> {
  /// Provider for searching driver ads with filters.
  /// The UI watches this to display filtered results.
  DriverAdsProvider._({
    required DriverAdsFamily super.from,
    required Map<String, dynamic> super.argument,
  }) : super(
         retry: null,
         name: r'driverAdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driverAdsHash();

  @override
  String toString() {
    return r'driverAdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DriverAdModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DriverAdModel>> create(Ref ref) {
    final argument = this.argument as Map<String, dynamic>;
    return driverAds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DriverAdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverAdsHash() => r'3a7ebaa5c2f1cd14e7aefd9569c1638f08056bcd';

/// Provider for searching driver ads with filters.
/// The UI watches this to display filtered results.

final class DriverAdsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<DriverAdModel>>,
          Map<String, dynamic>
        > {
  DriverAdsFamily._()
    : super(
        retry: null,
        name: r'driverAdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for searching driver ads with filters.
  /// The UI watches this to display filtered results.

  DriverAdsProvider call(Map<String, dynamic> filters) =>
      DriverAdsProvider._(argument: filters, from: this);

  @override
  String toString() => r'driverAdsProvider';
}

/// Provider for dashboard "Nearby/Featured" drivers

@ProviderFor(nearbyDrivers)
final nearbyDriversProvider = NearbyDriversProvider._();

/// Provider for dashboard "Nearby/Featured" drivers

final class NearbyDriversProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DriverAdModel>>,
          List<DriverAdModel>,
          FutureOr<List<DriverAdModel>>
        >
    with
        $FutureModifier<List<DriverAdModel>>,
        $FutureProvider<List<DriverAdModel>> {
  /// Provider for dashboard "Nearby/Featured" drivers
  NearbyDriversProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearbyDriversProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearbyDriversHash();

  @$internal
  @override
  $FutureProviderElement<List<DriverAdModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DriverAdModel>> create(Ref ref) {
    return nearbyDrivers(ref);
  }
}

String _$nearbyDriversHash() => r'874e87b915ecced436b5bea8db8cf49b28005787';
