// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// StreamProvider that listens to real-time driver location updates.
/// Using a family provider allows tracking different drivers.
/// Uses Supabase Realtime for instant updates.
///
/// Usage in UI:
/// ```dart
/// final locationAsync = ref.watch(driverLocationProvider(driverId));
/// ```

@ProviderFor(driverLocation)
final driverLocationProvider = DriverLocationFamily._();

/// StreamProvider that listens to real-time driver location updates.
/// Using a family provider allows tracking different drivers.
/// Uses Supabase Realtime for instant updates.
///
/// Usage in UI:
/// ```dart
/// final locationAsync = ref.watch(driverLocationProvider(driverId));
/// ```

final class DriverLocationProvider
    extends
        $FunctionalProvider<
          AsyncValue<DriverLocation>,
          DriverLocation,
          Stream<DriverLocation>
        >
    with $FutureModifier<DriverLocation>, $StreamProvider<DriverLocation> {
  /// StreamProvider that listens to real-time driver location updates.
  /// Using a family provider allows tracking different drivers.
  /// Uses Supabase Realtime for instant updates.
  ///
  /// Usage in UI:
  /// ```dart
  /// final locationAsync = ref.watch(driverLocationProvider(driverId));
  /// ```
  DriverLocationProvider._({
    required DriverLocationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'driverLocationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driverLocationHash();

  @override
  String toString() {
    return r'driverLocationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<DriverLocation> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DriverLocation> create(Ref ref) {
    final argument = this.argument as String;
    return driverLocation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DriverLocationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverLocationHash() => r'b1281596db94b618291c0610af9fdd158fa5412d';

/// StreamProvider that listens to real-time driver location updates.
/// Using a family provider allows tracking different drivers.
/// Uses Supabase Realtime for instant updates.
///
/// Usage in UI:
/// ```dart
/// final locationAsync = ref.watch(driverLocationProvider(driverId));
/// ```

final class DriverLocationFamily extends $Family
    with $FunctionalFamilyOverride<Stream<DriverLocation>, String> {
  DriverLocationFamily._()
    : super(
        retry: null,
        name: r'driverLocationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// StreamProvider that listens to real-time driver location updates.
  /// Using a family provider allows tracking different drivers.
  /// Uses Supabase Realtime for instant updates.
  ///
  /// Usage in UI:
  /// ```dart
  /// final locationAsync = ref.watch(driverLocationProvider(driverId));
  /// ```

  DriverLocationProvider call(String driverId) =>
      DriverLocationProvider._(argument: driverId, from: this);

  @override
  String toString() => r'driverLocationProvider';
}

/// Provider to fetch booking locations (home and school coordinates).
/// This is a one-time fetch, not a stream.

@ProviderFor(bookingLocations)
final bookingLocationsProvider = BookingLocationsFamily._();

/// Provider to fetch booking locations (home and school coordinates).
/// This is a one-time fetch, not a stream.

final class BookingLocationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<BookingLocations>,
          BookingLocations,
          FutureOr<BookingLocations>
        >
    with $FutureModifier<BookingLocations>, $FutureProvider<BookingLocations> {
  /// Provider to fetch booking locations (home and school coordinates).
  /// This is a one-time fetch, not a stream.
  BookingLocationsProvider._({
    required BookingLocationsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookingLocationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookingLocationsHash();

  @override
  String toString() {
    return r'bookingLocationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BookingLocations> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BookingLocations> create(Ref ref) {
    final argument = this.argument as String;
    return bookingLocations(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingLocationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookingLocationsHash() => r'2f5d9a064ac5111d51cefba0025f97a0f8f71765';

/// Provider to fetch booking locations (home and school coordinates).
/// This is a one-time fetch, not a stream.

final class BookingLocationsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BookingLocations>, String> {
  BookingLocationsFamily._()
    : super(
        retry: null,
        name: r'bookingLocationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to fetch booking locations (home and school coordinates).
  /// This is a one-time fetch, not a stream.

  BookingLocationsProvider call(String bookingId) =>
      BookingLocationsProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'bookingLocationsProvider';
}
