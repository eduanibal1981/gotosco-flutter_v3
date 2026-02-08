// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport_requests_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(driverTransportRequestsRepository)
final driverTransportRequestsRepositoryProvider =
    DriverTransportRequestsRepositoryProvider._();

final class DriverTransportRequestsRepositoryProvider
    extends
        $FunctionalProvider<
          DriverTransportRequestsRepository,
          DriverTransportRequestsRepository,
          DriverTransportRequestsRepository
        >
    with $Provider<DriverTransportRequestsRepository> {
  DriverTransportRequestsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverTransportRequestsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$driverTransportRequestsRepositoryHash();

  @$internal
  @override
  $ProviderElement<DriverTransportRequestsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DriverTransportRequestsRepository create(Ref ref) {
    return driverTransportRequestsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverTransportRequestsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverTransportRequestsRepository>(
        value,
      ),
    );
  }
}

String _$driverTransportRequestsRepositoryHash() =>
    r'19f9b66ff8a4bcd1a904fb2a729f59157d124f3e';

@ProviderFor(transportRequests)
final transportRequestsProvider = TransportRequestsFamily._();

final class TransportRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  TransportRequestsProvider._({
    required TransportRequestsFamily super.from,
    required ({
      String? status,
      String? bookingType,
      String? searchTerm,
      int? ageMin,
      int? ageMax,
      String? schoolName,
      double? maxDistanceKm,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'transportRequestsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transportRequestsHash();

  @override
  String toString() {
    return r'transportRequestsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    final argument =
        this.argument
            as ({
              String? status,
              String? bookingType,
              String? searchTerm,
              int? ageMin,
              int? ageMax,
              String? schoolName,
              double? maxDistanceKm,
            });
    return transportRequests(
      ref,
      status: argument.status,
      bookingType: argument.bookingType,
      searchTerm: argument.searchTerm,
      ageMin: argument.ageMin,
      ageMax: argument.ageMax,
      schoolName: argument.schoolName,
      maxDistanceKm: argument.maxDistanceKm,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TransportRequestsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transportRequestsHash() => r'411987e446e7e546b89fe6d9f5e64cff53245e14';

final class TransportRequestsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Map<String, dynamic>>>,
          ({
            String? status,
            String? bookingType,
            String? searchTerm,
            int? ageMin,
            int? ageMax,
            String? schoolName,
            double? maxDistanceKm,
          })
        > {
  TransportRequestsFamily._()
    : super(
        retry: null,
        name: r'transportRequestsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransportRequestsProvider call({
    String? status,
    String? bookingType,
    String? searchTerm,
    int? ageMin,
    int? ageMax,
    String? schoolName,
    double? maxDistanceKm,
  }) => TransportRequestsProvider._(
    argument: (
      status: status,
      bookingType: bookingType,
      searchTerm: searchTerm,
      ageMin: ageMin,
      ageMax: ageMax,
      schoolName: schoolName,
      maxDistanceKm: maxDistanceKm,
    ),
    from: this,
  );

  @override
  String toString() => r'transportRequestsProvider';
}

/// Newly added provider for typed access

@ProviderFor(driverRequests)
final driverRequestsProvider = DriverRequestsFamily._();

/// Newly added provider for typed access

final class DriverRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DriverRequest>>,
          List<DriverRequest>,
          FutureOr<List<DriverRequest>>
        >
    with
        $FutureModifier<List<DriverRequest>>,
        $FutureProvider<List<DriverRequest>> {
  /// Newly added provider for typed access
  DriverRequestsProvider._({
    required DriverRequestsFamily super.from,
    required ({
      String? status,
      String? bookingType,
      String? searchTerm,
      int? ageMin,
      int? ageMax,
      String? schoolName,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'driverRequestsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driverRequestsHash();

  @override
  String toString() {
    return r'driverRequestsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<DriverRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DriverRequest>> create(Ref ref) {
    final argument =
        this.argument
            as ({
              String? status,
              String? bookingType,
              String? searchTerm,
              int? ageMin,
              int? ageMax,
              String? schoolName,
            });
    return driverRequests(
      ref,
      status: argument.status,
      bookingType: argument.bookingType,
      searchTerm: argument.searchTerm,
      ageMin: argument.ageMin,
      ageMax: argument.ageMax,
      schoolName: argument.schoolName,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DriverRequestsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverRequestsHash() => r'0531eccaa3c6210080bbae93d509e5f973742fe1';

/// Newly added provider for typed access

final class DriverRequestsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<DriverRequest>>,
          ({
            String? status,
            String? bookingType,
            String? searchTerm,
            int? ageMin,
            int? ageMax,
            String? schoolName,
          })
        > {
  DriverRequestsFamily._()
    : super(
        retry: null,
        name: r'driverRequestsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Newly added provider for typed access

  DriverRequestsProvider call({
    String? status,
    String? bookingType,
    String? searchTerm,
    int? ageMin,
    int? ageMax,
    String? schoolName,
  }) => DriverRequestsProvider._(
    argument: (
      status: status,
      bookingType: bookingType,
      searchTerm: searchTerm,
      ageMin: ageMin,
      ageMax: ageMax,
      schoolName: schoolName,
    ),
    from: this,
  );

  @override
  String toString() => r'driverRequestsProvider';
}
