// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_availability_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(driverAvailabilityRepository)
final driverAvailabilityRepositoryProvider =
    DriverAvailabilityRepositoryProvider._();

final class DriverAvailabilityRepositoryProvider
    extends
        $FunctionalProvider<
          DriverAvailabilityRepository,
          DriverAvailabilityRepository,
          DriverAvailabilityRepository
        >
    with $Provider<DriverAvailabilityRepository> {
  DriverAvailabilityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverAvailabilityRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverAvailabilityRepositoryHash();

  @$internal
  @override
  $ProviderElement<DriverAvailabilityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DriverAvailabilityRepository create(Ref ref) {
    return driverAvailabilityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverAvailabilityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverAvailabilityRepository>(value),
    );
  }
}

String _$driverAvailabilityRepositoryHash() =>
    r'e378bd7665323a1886d0e589d6879666dd2ea4a9';

/// Provider for current availability settings

@ProviderFor(driverAvailabilitySettings)
final driverAvailabilitySettingsProvider =
    DriverAvailabilitySettingsProvider._();

/// Provider for current availability settings

final class DriverAvailabilitySettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DriverAvailabilitySettings>,
          DriverAvailabilitySettings,
          FutureOr<DriverAvailabilitySettings>
        >
    with
        $FutureModifier<DriverAvailabilitySettings>,
        $FutureProvider<DriverAvailabilitySettings> {
  /// Provider for current availability settings
  DriverAvailabilitySettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverAvailabilitySettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverAvailabilitySettingsHash();

  @$internal
  @override
  $FutureProviderElement<DriverAvailabilitySettings> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DriverAvailabilitySettings> create(Ref ref) {
    return driverAvailabilitySettings(ref);
  }
}

String _$driverAvailabilitySettingsHash() =>
    r'd137bdb987cb96045933525d916fd6731acd6a12';
