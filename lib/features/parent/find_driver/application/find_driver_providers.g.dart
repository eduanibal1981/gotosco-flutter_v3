// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_driver_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(nearbyDrivers)
final nearbyDriversProvider = NearbyDriversProvider._();

final class NearbyDriversProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DriverAdModel>>,
          List<DriverAdModel>,
          FutureOr<List<DriverAdModel>>
        >
    with
        $FutureModifier<List<DriverAdModel>>,
        $FutureProvider<List<DriverAdModel>> {
  NearbyDriversProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearbyDriversProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearbyDriversHash();

  @$internal
  @override
  $FutureProviderElement<List<DriverAdModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DriverAdModel>> create(Ref ref) {
    return nearbyDrivers(ref);
  }
}

String _$nearbyDriversHash() => r'874e87b915ecced436b5bea8db8cf49b28005787';

/// Controller that manages driver filters state.

@ProviderFor(DriversFilterController)
final driversFilterControllerProvider = DriversFilterControllerProvider._();

/// Controller that manages driver filters state.
final class DriversFilterControllerProvider
    extends $NotifierProvider<DriversFilterController, Map<String, dynamic>> {
  /// Controller that manages driver filters state.
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
    r'88050ceb76eb8a98adccedf87324bbe0ad040c31';

/// Controller that manages driver filters state.

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

@ProviderFor(DriverAds)
final driverAdsProvider = DriverAdsFamily._();

final class DriverAdsProvider
    extends $AsyncNotifierProvider<DriverAds, List<DriverAdModel>> {
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

String _$driverAdsHash() => r'b46494fbc62a2579d82756570d7e8a37021136e7';

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

  DriverAdsProvider call({double? lat, double? lng}) =>
      DriverAdsProvider._(argument: (lat: lat, lng: lng), from: this);

  @override
  String toString() => r'driverAdsProvider';
}

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

/// REFERENCE DATA PROVIDERS

@ProviderFor(cities)
final citiesProvider = CitiesProvider._();

/// REFERENCE DATA PROVIDERS

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
  /// REFERENCE DATA PROVIDERS
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

String _$citiesHash() => r'01aa4e44fa6da43355d2fb7d20443d6ff381e89a';

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

String _$areasHash() => r'dbeea04cc5115720dbc98cb98d59cdf5ca11a0e8';

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
    required ({String? cityId, String? areaId}) super.argument,
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
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    final argument = this.argument as ({String? cityId, String? areaId});
    return schools(ref, cityId: argument.cityId, areaId: argument.areaId);
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

String _$schoolsHash() => r'23b8150762f10c13826c05aedf3dc5c65661ded7';

final class SchoolsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Map<String, dynamic>>>,
          ({String? cityId, String? areaId})
        > {
  SchoolsFamily._()
    : super(
        retry: null,
        name: r'schoolsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SchoolsProvider call({String? cityId, String? areaId}) =>
      SchoolsProvider._(argument: (cityId: cityId, areaId: areaId), from: this);

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

/// FAVORITES PROVIDERS

@ProviderFor(favoriteDrivers)
final favoriteDriversProvider = FavoriteDriversProvider._();

/// FAVORITES PROVIDERS

final class FavoriteDriversProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DriverAdModel>>,
          List<DriverAdModel>,
          FutureOr<List<DriverAdModel>>
        >
    with
        $FutureModifier<List<DriverAdModel>>,
        $FutureProvider<List<DriverAdModel>> {
  /// FAVORITES PROVIDERS
  FavoriteDriversProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteDriversProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteDriversHash();

  @$internal
  @override
  $FutureProviderElement<List<DriverAdModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DriverAdModel>> create(Ref ref) {
    return favoriteDrivers(ref);
  }
}

String _$favoriteDriversHash() => r'be5c0c25519924da24f5e5ad51ac19b15bc70c67';

@ProviderFor(Favorites)
final favoritesProvider = FavoritesProvider._();

final class FavoritesProvider
    extends $AsyncNotifierProvider<Favorites, List<String>> {
  FavoritesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesHash();

  @$internal
  @override
  Favorites create() => Favorites();
}

String _$favoritesHash() => r'46376e37d069424cb0e3007a761192e77e3904f3';

abstract class _$Favorites extends $AsyncNotifier<List<String>> {
  FutureOr<List<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
