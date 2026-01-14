// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drivers_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for searching driver ads with pagination support.
/// Replaces the simple FutureProvider to handle infinite scrolling.

@ProviderFor(DriverAds)
final driverAdsProvider = DriverAdsFamily._();

/// Provider for searching driver ads with pagination support.
/// Replaces the simple FutureProvider to handle infinite scrolling.
final class DriverAdsProvider
    extends $AsyncNotifierProvider<DriverAds, List<DriverAdModel>> {
  /// Provider for searching driver ads with pagination support.
  /// Replaces the simple FutureProvider to handle infinite scrolling.
  DriverAdsProvider._({
    required DriverAdsFamily super.from,
    required ({double? lat, double? lng}) super.argument,
  }) : super(
         retry: null,
         name: r'driverAdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driverAdsHash();

  @override
  String toString() {
    return r'driverAdsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  DriverAds create() => DriverAds();

  @override
  bool operator ==(Object other) {
    return other is DriverAdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverAdsHash() => r'5c1b122389bfce5e646783c62124a1e03dcf65ce';

/// Provider for searching driver ads with pagination support.
/// Replaces the simple FutureProvider to handle infinite scrolling.

final class DriverAdsFamily extends $Family
    with
        $ClassFamilyOverride<
          DriverAds,
          AsyncValue<List<DriverAdModel>>,
          List<DriverAdModel>,
          FutureOr<List<DriverAdModel>>,
          ({double? lat, double? lng})
        > {
  DriverAdsFamily._()
    : super(
        retry: null,
        name: r'driverAdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for searching driver ads with pagination support.
  /// Replaces the simple FutureProvider to handle infinite scrolling.

  DriverAdsProvider call({double? lat, double? lng}) =>
      DriverAdsProvider._(argument: (lat: lat, lng: lng), from: this);

  @override
  String toString() => r'driverAdsProvider';
}

/// Provider for searching driver ads with pagination support.
/// Replaces the simple FutureProvider to handle infinite scrolling.

abstract class _$DriverAds extends $AsyncNotifier<List<DriverAdModel>> {
  late final _$args = ref.$arg as ({double? lat, double? lng});
  double? get lat => _$args.lat;
  double? get lng => _$args.lng;

  FutureOr<List<DriverAdModel>> build({double? lat, double? lng});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<DriverAdModel>>, List<DriverAdModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<DriverAdModel>>, List<DriverAdModel>>,
              AsyncValue<List<DriverAdModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(lat: _$args.lat, lng: _$args.lng));
  }
}

/// Providers for reference data

@ProviderFor(cities)
final citiesProvider = CitiesProvider._();

/// Providers for reference data

final class CitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  /// Providers for reference data
  CitiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'citiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$citiesHash();

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    return cities(ref);
  }
}

String _$citiesHash() => r'77df44adfe5ca35abb801f8d4c2b17d89a684b3c';

@ProviderFor(areas)
final areasProvider = AreasFamily._();

final class AreasProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  AreasProvider._({
    required AreasFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'areasProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$areasHash();

  @override
  String toString() {
    return r'areasProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    final argument = this.argument as String?;
    return areas(ref, cityId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AreasProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$areasHash() => r'3d32ba82bf098592dc74090f8ad7888c466b6860';

final class AreasFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Map<String, dynamic>>>,
          String?
        > {
  AreasFamily._()
    : super(
        retry: null,
        name: r'areasProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AreasProvider call({String? cityId}) =>
      AreasProvider._(argument: cityId, from: this);

  @override
  String toString() => r'areasProvider';
}

@ProviderFor(schools)
final schoolsProvider = SchoolsFamily._();

final class SchoolsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  SchoolsProvider._({
    required SchoolsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'schoolsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$schoolsHash();

  @override
  String toString() {
    return r'schoolsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    final argument = this.argument as String?;
    return schools(ref, cityId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SchoolsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$schoolsHash() => r'810a4ac941124f417b6cc93168f6a570267eef52';

final class SchoolsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Map<String, dynamic>>>,
          String?
        > {
  SchoolsFamily._()
    : super(
        retry: null,
        name: r'schoolsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SchoolsProvider call({String? cityId}) =>
      SchoolsProvider._(argument: cityId, from: this);

  @override
  String toString() => r'schoolsProvider';
}

@ProviderFor(priceRange)
final priceRangeProvider = PriceRangeProvider._();

final class PriceRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<({double max, double min})>,
          ({double max, double min}),
          FutureOr<({double max, double min})>
        >
    with
        $FutureModifier<({double max, double min})>,
        $FutureProvider<({double max, double min})> {
  PriceRangeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'priceRangeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$priceRangeHash();

  @$internal
  @override
  $FutureProviderElement<({double max, double min})> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<({double max, double min})> create(Ref ref) {
    return priceRange(ref);
  }
}

String _$priceRangeHash() => r'1dd519fa599a13fd5d4111fcdde08a5496530a4c';

/// Controller that manages driver filters state.
/// Provides filter summary and clear functionality.

@ProviderFor(DriversFilterController)
final driversFilterControllerProvider = DriversFilterControllerProvider._();

/// Controller that manages driver filters state.
/// Provides filter summary and clear functionality.
final class DriversFilterControllerProvider
    extends $NotifierProvider<DriversFilterController, Map<String, dynamic>> {
  /// Controller that manages driver filters state.
  /// Provides filter summary and clear functionality.
  DriversFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driversFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driversFilterControllerHash();

  @$internal
  @override
  DriversFilterController create() => DriversFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, dynamic> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, dynamic>>(value),
    );
  }
}

String _$driversFilterControllerHash() =>
    r'614775f8aac03c616544f87c1575c96cb3505c63';

/// Controller that manages driver filters state.
/// Provides filter summary and clear functionality.

abstract class _$DriversFilterController
    extends $Notifier<Map<String, dynamic>> {
  Map<String, dynamic> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, dynamic>, Map<String, dynamic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, dynamic>, Map<String, dynamic>>,
              Map<String, dynamic>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
