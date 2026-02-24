// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_dashboard_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(driverDashboardRepository)
final driverDashboardRepositoryProvider = DriverDashboardRepositoryProvider._();

final class DriverDashboardRepositoryProvider
    extends
        $FunctionalProvider<
          DriverDashboardContract,
          DriverDashboardContract,
          DriverDashboardContract
        >
    with $Provider<DriverDashboardContract> {
  DriverDashboardRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverDashboardRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverDashboardRepositoryHash();

  @$internal
  @override
  $ProviderElement<DriverDashboardContract> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DriverDashboardContract create(Ref ref) {
    return driverDashboardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverDashboardContract value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverDashboardContract>(value),
    );
  }
}

String _$driverDashboardRepositoryHash() =>
    r'2302efb3c2e5127ec182d4fab52d597ab96fe1bb';
