// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_dashboard_repository.dart';

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
    r'0678d0fbb1725e36f174a3c584fd722d243d0310';

/// Provider for checking if driver has a profile in drivers table

@ProviderFor(driverProfile)
final driverProfileProvider = DriverProfileProvider._();

/// Provider for checking if driver has a profile in drivers table

final class DriverProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>?>,
          Map<String, dynamic>?,
          FutureOr<Map<String, dynamic>?>
        >
    with
        $FutureModifier<Map<String, dynamic>?>,
        $FutureProvider<Map<String, dynamic>?> {
  /// Provider for checking if driver has a profile in drivers table
  DriverProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverProfileHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>?> create(Ref ref) {
    return driverProfile(ref);
  }
}

String _$driverProfileHash() => r'8c2f2a9ee486877264b5a9d36dac35a8ce264ee2';

/// Provider for driver dashboard state (1-5)

@ProviderFor(driverDashboardState)
final driverDashboardStateProvider = DriverDashboardStateProvider._();

/// Provider for driver dashboard state (1-5)

final class DriverDashboardStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<DriverDashboardState>,
          DriverDashboardState,
          FutureOr<DriverDashboardState>
        >
    with
        $FutureModifier<DriverDashboardState>,
        $FutureProvider<DriverDashboardState> {
  /// Provider for driver dashboard state (1-5)
  DriverDashboardStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverDashboardStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverDashboardStateHash();

  @$internal
  @override
  $FutureProviderElement<DriverDashboardState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DriverDashboardState> create(Ref ref) {
    return driverDashboardState(ref);
  }
}

String _$driverDashboardStateHash() =>
    r'd80e8bccf15bec668af66c26bca9216a17dab289';

/// Provider for driver stats (students, pending requests, earnings)

@ProviderFor(driverStats)
final driverStatsProvider = DriverStatsProvider._();

/// Provider for driver stats (students, pending requests, earnings)

final class DriverStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DriverStats>,
          DriverStats,
          FutureOr<DriverStats>
        >
    with $FutureModifier<DriverStats>, $FutureProvider<DriverStats> {
  /// Provider for driver stats (students, pending requests, earnings)
  DriverStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverStatsHash();

  @$internal
  @override
  $FutureProviderElement<DriverStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DriverStats> create(Ref ref) {
    return driverStats(ref);
  }
}

String _$driverStatsHash() => r'5b440d070e9cbe2cf17e06522ab2de98ce6ceb09';

/// Provider for driver's booking requests (pending)

@ProviderFor(driverBookingRequests)
final driverBookingRequestsProvider = DriverBookingRequestsProvider._();

/// Provider for driver's booking requests (pending)

final class DriverBookingRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DriverRequest>>,
          List<DriverRequest>,
          Stream<List<DriverRequest>>
        >
    with
        $FutureModifier<List<DriverRequest>>,
        $StreamProvider<List<DriverRequest>> {
  /// Provider for driver's booking requests (pending)
  DriverBookingRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverBookingRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverBookingRequestsHash();

  @$internal
  @override
  $StreamProviderElement<List<DriverRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DriverRequest>> create(Ref ref) {
    return driverBookingRequests(ref);
  }
}

String _$driverBookingRequestsHash() =>
    r'004f7bcd53dd7426ed44403151cffb27579b9101';

/// Provider for driver's enrolled students
/// Returns List<Map> for compatibility with existing UI for now

@ProviderFor(driverStudents)
final driverStudentsProvider = DriverStudentsProvider._();

/// Provider for driver's enrolled students
/// Returns List<Map> for compatibility with existing UI for now

final class DriverStudentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  /// Provider for driver's enrolled students
  /// Returns List<Map> for compatibility with existing UI for now
  DriverStudentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverStudentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverStudentsHash();

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    return driverStudents(ref);
  }
}

String _$driverStudentsHash() => r'aeeafb32db71f3412b50fac1123e4756e3b22533';

/// Provider for today's trips

@ProviderFor(todaysTrips)
final todaysTripsProvider = TodaysTripsProvider._();

/// Provider for today's trips

final class TodaysTripsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DriverTrip>>,
          List<DriverTrip>,
          FutureOr<List<DriverTrip>>
        >
    with $FutureModifier<List<DriverTrip>>, $FutureProvider<List<DriverTrip>> {
  /// Provider for today's trips
  TodaysTripsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaysTripsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaysTripsHash();

  @$internal
  @override
  $FutureProviderElement<List<DriverTrip>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DriverTrip>> create(Ref ref) {
    return todaysTrips(ref);
  }
}

String _$todaysTripsHash() => r'105c55dc7141aef324da562d96084ae6ed5b02ba';

/// Provider for active trip (if any)

@ProviderFor(activeTrip)
final activeTripProvider = ActiveTripProvider._();

/// Provider for active trip (if any)

final class ActiveTripProvider
    extends
        $FunctionalProvider<
          AsyncValue<DriverTrip?>,
          DriverTrip?,
          FutureOr<DriverTrip?>
        >
    with $FutureModifier<DriverTrip?>, $FutureProvider<DriverTrip?> {
  /// Provider for active trip (if any)
  ActiveTripProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeTripProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeTripHash();

  @$internal
  @override
  $FutureProviderElement<DriverTrip?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DriverTrip?> create(Ref ref) {
    return activeTrip(ref);
  }
}

String _$activeTripHash() => r'4a695fa53ba30da60a9759d74f39293be97feec1';

/// Provider for the next scheduled trip (Go to School first, then Return)

@ProviderFor(nextScheduledTrip)
final nextScheduledTripProvider = NextScheduledTripProvider._();

/// Provider for the next scheduled trip (Go to School first, then Return)

final class NextScheduledTripProvider
    extends
        $FunctionalProvider<
          AsyncValue<DriverTrip?>,
          DriverTrip?,
          FutureOr<DriverTrip?>
        >
    with $FutureModifier<DriverTrip?>, $FutureProvider<DriverTrip?> {
  /// Provider for the next scheduled trip (Go to School first, then Return)
  NextScheduledTripProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nextScheduledTripProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nextScheduledTripHash();

  @$internal
  @override
  $FutureProviderElement<DriverTrip?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DriverTrip?> create(Ref ref) {
    return nextScheduledTrip(ref);
  }
}

String _$nextScheduledTripHash() => r'bfb560ae2f6f61a27d3efc8af19ddd2cfde4097f';
