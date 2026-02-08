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

/// Legacy provider - returns old BookingModel for backward compatibility

@ProviderFor(driverBookings)
final driverBookingsProvider = DriverBookingsProvider._();

/// Legacy provider - returns old BookingModel for backward compatibility

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
  /// Legacy provider - returns old BookingModel for backward compatibility
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

String _$driverBookingsHash() => r'c8e5f0f38fc1e3937cf5eeeceab1d0ac8ad6e013';

/// ✅ NEW: Typed provider - returns Freezed DriverBooking models

@ProviderFor(driverBookingsTyped)
final driverBookingsTypedProvider = DriverBookingsTypedProvider._();

/// ✅ NEW: Typed provider - returns Freezed DriverBooking models

final class DriverBookingsTypedProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DriverBooking>>,
          List<DriverBooking>,
          FutureOr<List<DriverBooking>>
        >
    with
        $FutureModifier<List<DriverBooking>>,
        $FutureProvider<List<DriverBooking>> {
  /// ✅ NEW: Typed provider - returns Freezed DriverBooking models
  DriverBookingsTypedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverBookingsTypedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverBookingsTypedHash();

  @$internal
  @override
  $FutureProviderElement<List<DriverBooking>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DriverBooking>> create(Ref ref) {
    return driverBookingsTyped(ref);
  }
}

String _$driverBookingsTypedHash() =>
    r'e74c6d3629a5dbdd987066e3ee0ecc81f6e366af';
