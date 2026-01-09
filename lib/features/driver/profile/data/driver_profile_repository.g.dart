// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_profile_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(driverProfileRepository)
final driverProfileRepositoryProvider = DriverProfileRepositoryProvider._();

final class DriverProfileRepositoryProvider
    extends
        $FunctionalProvider<
          DriverProfileRepository,
          DriverProfileRepository,
          DriverProfileRepository
        >
    with $Provider<DriverProfileRepository> {
  DriverProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverProfileRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverProfileRepositoryHash();

  @$internal
  @override
  $ProviderElement<DriverProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DriverProfileRepository create(Ref ref) {
    return driverProfileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverProfileRepository>(value),
    );
  }
}

String _$driverProfileRepositoryHash() =>
    r'48decb30cb4c61e7cb2be4cc1a084f4cc4d92df5';

/// Provider for the current driver's profile

@ProviderFor(currentDriverProfile)
final currentDriverProfileProvider = CurrentDriverProfileProvider._();

/// Provider for the current driver's profile

final class CurrentDriverProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<DriverProfileModel?>,
          DriverProfileModel?,
          FutureOr<DriverProfileModel?>
        >
    with
        $FutureModifier<DriverProfileModel?>,
        $FutureProvider<DriverProfileModel?> {
  /// Provider for the current driver's profile
  CurrentDriverProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentDriverProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentDriverProfileHash();

  @$internal
  @override
  $FutureProviderElement<DriverProfileModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DriverProfileModel?> create(Ref ref) {
    return currentDriverProfile(ref);
  }
}

String _$currentDriverProfileHash() =>
    r'974dc8b39a821c8ee29d313b2d2278a28e2000ed';

/// Provider for the current driver's schedules

@ProviderFor(driverSchedules)
final driverSchedulesProvider = DriverSchedulesProvider._();

/// Provider for the current driver's schedules

final class DriverSchedulesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DriverScheduleModel>>,
          List<DriverScheduleModel>,
          FutureOr<List<DriverScheduleModel>>
        >
    with
        $FutureModifier<List<DriverScheduleModel>>,
        $FutureProvider<List<DriverScheduleModel>> {
  /// Provider for the current driver's schedules
  DriverSchedulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverSchedulesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverSchedulesHash();

  @$internal
  @override
  $FutureProviderElement<List<DriverScheduleModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DriverScheduleModel>> create(Ref ref) {
    return driverSchedules(ref);
  }
}

String _$driverSchedulesHash() => r'3bbc552b5e9d71645cc106fef4184c79254fa02b';
