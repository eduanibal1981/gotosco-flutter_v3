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
          DriverDashboardRepository,
          DriverDashboardRepository,
          DriverDashboardRepository
        >
    with $Provider<DriverDashboardRepository> {
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
  $ProviderElement<DriverDashboardRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DriverDashboardRepository create(Ref ref) {
    return driverDashboardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverDashboardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverDashboardRepository>(value),
    );
  }
}

String _$driverDashboardRepositoryHash() =>
    r'0f031ba89a3b353c34332b102e98afc51c98bc41';
