// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// StreamProvider that listens to real-time driver location updates.

@ProviderFor(driverLocation)
final driverLocationProvider = DriverLocationFamily._();

/// StreamProvider that listens to real-time driver location updates.

final class DriverLocationProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrackingViewModel?>,
          TrackingViewModel?,
          Stream<TrackingViewModel?>
        >
    with
        $FutureModifier<TrackingViewModel?>,
        $StreamProvider<TrackingViewModel?> {
  /// StreamProvider that listens to real-time driver location updates.
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
  $StreamProviderElement<TrackingViewModel?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TrackingViewModel?> create(Ref ref) {
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

String _$driverLocationHash() => r'8b508e36bc616495cd4de0f4bbe96f17c285f27b';

/// StreamProvider that listens to real-time driver location updates.

final class DriverLocationFamily extends $Family
    with $FunctionalFamilyOverride<Stream<TrackingViewModel?>, String> {
  DriverLocationFamily._()
    : super(
        retry: null,
        name: r'driverLocationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// StreamProvider that listens to real-time driver location updates.

  DriverLocationProvider call(String driverId) =>
      DriverLocationProvider._(argument: driverId, from: this);

  @override
  String toString() => r'driverLocationProvider';
}

/// Provider to fetch booking locations (home and school coordinates).

@ProviderFor(bookingLocations)
final bookingLocationsProvider = BookingLocationsFamily._();

/// Provider to fetch booking locations (home and school coordinates).

final class BookingLocationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<BookingLocation?>,
          BookingLocation?,
          FutureOr<BookingLocation?>
        >
    with $FutureModifier<BookingLocation?>, $FutureProvider<BookingLocation?> {
  /// Provider to fetch booking locations (home and school coordinates).
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
  $FutureProviderElement<BookingLocation?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BookingLocation?> create(Ref ref) {
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

String _$bookingLocationsHash() => r'5a6b3fd2bb1e598012faf66dfc91537d684a4763';

/// Provider to fetch booking locations (home and school coordinates).

final class BookingLocationsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BookingLocation?>, String> {
  BookingLocationsFamily._()
    : super(
        retry: null,
        name: r'bookingLocationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to fetch booking locations (home and school coordinates).

  BookingLocationsProvider call(String bookingId) =>
      BookingLocationsProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'bookingLocationsProvider';
}

@ProviderFor(latestRideEvent)
final latestRideEventProvider = LatestRideEventFamily._();

final class LatestRideEventProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>?>,
          Map<String, dynamic>?,
          Stream<Map<String, dynamic>?>
        >
    with
        $FutureModifier<Map<String, dynamic>?>,
        $StreamProvider<Map<String, dynamic>?> {
  LatestRideEventProvider._({
    required LatestRideEventFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'latestRideEventProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$latestRideEventHash();

  @override
  String toString() {
    return r'latestRideEventProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, dynamic>?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, dynamic>?> create(Ref ref) {
    final argument = this.argument as String;
    return latestRideEvent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LatestRideEventProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$latestRideEventHash() => r'1b56f16ba87f91764ee06298ac343abc774b5301';

final class LatestRideEventFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, dynamic>?>, String> {
  LatestRideEventFamily._()
    : super(
        retry: null,
        name: r'latestRideEventProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LatestRideEventProvider call(String bookingId) =>
      LatestRideEventProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'latestRideEventProvider';
}

@ProviderFor(parentNextStopInfo)
final parentNextStopInfoProvider = ParentNextStopInfoFamily._();

final class ParentNextStopInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<ParentNextStopInfo?>,
          ParentNextStopInfo?,
          FutureOr<ParentNextStopInfo?>
        >
    with
        $FutureModifier<ParentNextStopInfo?>,
        $FutureProvider<ParentNextStopInfo?> {
  ParentNextStopInfoProvider._({
    required ParentNextStopInfoFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'parentNextStopInfoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$parentNextStopInfoHash();

  @override
  String toString() {
    return r'parentNextStopInfoProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ParentNextStopInfo?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ParentNextStopInfo?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return parentNextStopInfo(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ParentNextStopInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$parentNextStopInfoHash() =>
    r'9191a356fe4abb1ccb852983d15bd9e1b8a2e32f';

final class ParentNextStopInfoFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ParentNextStopInfo?>,
          (String, String)
        > {
  ParentNextStopInfoFamily._()
    : super(
        retry: null,
        name: r'parentNextStopInfoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ParentNextStopInfoProvider call(String bookingId, String driverId) =>
      ParentNextStopInfoProvider._(argument: (bookingId, driverId), from: this);

  @override
  String toString() => r'parentNextStopInfoProvider';
}
