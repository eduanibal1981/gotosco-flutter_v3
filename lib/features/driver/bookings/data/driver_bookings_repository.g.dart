// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_bookings_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(driverBookingsRepository)
final driverBookingsRepositoryProvider = DriverBookingsRepositoryProvider._();

final class DriverBookingsRepositoryProvider
    extends
        $FunctionalProvider<
          DriverBookingsRepository,
          DriverBookingsRepository,
          DriverBookingsRepository
        >
    with $Provider<DriverBookingsRepository> {
  DriverBookingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverBookingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverBookingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<DriverBookingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DriverBookingsRepository create(Ref ref) {
    return driverBookingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverBookingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverBookingsRepository>(value),
    );
  }
}

String _$driverBookingsRepositoryHash() =>
    r'c8df0afc361373ff19ab11736afebbe7b90d0406';

@ProviderFor(driverBookings)
final driverBookingsProvider = DriverBookingsProvider._();

final class DriverBookingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BookingModel>>,
          List<BookingModel>,
          FutureOr<List<BookingModel>>
        >
    with
        $FutureModifier<List<BookingModel>>,
        $FutureProvider<List<BookingModel>> {
  DriverBookingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverBookingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverBookingsHash();

  @$internal
  @override
  $FutureProviderElement<List<BookingModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BookingModel>> create(Ref ref) {
    return driverBookings(ref);
  }
}

String _$driverBookingsHash() => r'98d94223d7b3e49c49f06e868781ebbcc4db51e3';
