// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drivers_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for searching driver ads.
/// watches [driversFilterControllerProvider] internally for filters.
/// Accepts [lat] and [lng] as arguments to avoid Maps in family.

@ProviderFor(driverAds)
final driverAdsProvider = DriverAdsFamily._();

/// Provider for searching driver ads.
/// watches [driversFilterControllerProvider] internally for filters.
/// Accepts [lat] and [lng] as arguments to avoid Maps in family.

final class DriverAdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DriverAdModel>>,
          List<DriverAdModel>,
          FutureOr<List<DriverAdModel>>
        >
    with
        $FutureModifier<List<DriverAdModel>>,
        $FutureProvider<List<DriverAdModel>> {
  /// Provider for searching driver ads.
  /// watches [driversFilterControllerProvider] internally for filters.
  /// Accepts [lat] and [lng] as arguments to avoid Maps in family.
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
  $FutureProviderElement<List<DriverAdModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DriverAdModel>> create(Ref ref) {
    final argument = this.argument as ({double? lat, double? lng});
    return driverAds(ref, lat: argument.lat, lng: argument.lng);
  }

  @override
  bool operator ==(Object other) {
    return other is DriverAdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverAdsHash() => r'154f24c931e5628f0bc82a4f45768ef4e453324c';

/// Provider for searching driver ads.
/// watches [driversFilterControllerProvider] internally for filters.
/// Accepts [lat] and [lng] as arguments to avoid Maps in family.

final class DriverAdsFamily extends $Family
    with
        $FunctionalFamilyOverride<
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

  /// Provider for searching driver ads.
  /// watches [driversFilterControllerProvider] internally for filters.
  /// Accepts [lat] and [lng] as arguments to avoid Maps in family.

  DriverAdsProvider call({double? lat, double? lng}) =>
      DriverAdsProvider._(argument: (lat: lat, lng: lng), from: this);

  @override
  String toString() => r'driverAdsProvider';
}

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
