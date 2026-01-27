// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_coverage_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(driverCoverageRepository)
final driverCoverageRepositoryProvider = DriverCoverageRepositoryProvider._();

final class DriverCoverageRepositoryProvider
    extends
        $FunctionalProvider<
          DriverCoverageRepository,
          DriverCoverageRepository,
          DriverCoverageRepository
        >
    with $Provider<DriverCoverageRepository> {
  DriverCoverageRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverCoverageRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverCoverageRepositoryHash();

  @$internal
  @override
  $ProviderElement<DriverCoverageRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DriverCoverageRepository create(Ref ref) {
    return driverCoverageRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverCoverageRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverCoverageRepository>(value),
    );
  }
}

String _$driverCoverageRepositoryHash() =>
    r'bbf47e4f35254e0dee4ef3328db3caa716aa950f';

@ProviderFor(coverageCities)
final coverageCitiesProvider = CoverageCitiesProvider._();

final class CoverageCitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CityModel>>,
          List<CityModel>,
          FutureOr<List<CityModel>>
        >
    with $FutureModifier<List<CityModel>>, $FutureProvider<List<CityModel>> {
  CoverageCitiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coverageCitiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coverageCitiesHash();

  @$internal
  @override
  $FutureProviderElement<List<CityModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CityModel>> create(Ref ref) {
    return coverageCities(ref);
  }
}

String _$coverageCitiesHash() => r'2fe032d7ca4fc91fe0432ce54ff3c5a3563841fe';

@ProviderFor(coverageAreas)
final coverageAreasProvider = CoverageAreasFamily._();

final class CoverageAreasProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AreaModel>>,
          List<AreaModel>,
          FutureOr<List<AreaModel>>
        >
    with $FutureModifier<List<AreaModel>>, $FutureProvider<List<AreaModel>> {
  CoverageAreasProvider._({
    required CoverageAreasFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'coverageAreasProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$coverageAreasHash();

  @override
  String toString() {
    return r'coverageAreasProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AreaModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AreaModel>> create(Ref ref) {
    final argument = this.argument as String;
    return coverageAreas(ref, cityId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CoverageAreasProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$coverageAreasHash() => r'8f587bc340bfa990715bd7001b4f7327c5fe0b9b';

final class CoverageAreasFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AreaModel>>, String> {
  CoverageAreasFamily._()
    : super(
        retry: null,
        name: r'coverageAreasProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CoverageAreasProvider call({required String cityId}) =>
      CoverageAreasProvider._(argument: cityId, from: this);

  @override
  String toString() => r'coverageAreasProvider';
}

@ProviderFor(coverageSchools)
final coverageSchoolsProvider = CoverageSchoolsFamily._();

final class CoverageSchoolsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SchoolModel>>,
          List<SchoolModel>,
          FutureOr<List<SchoolModel>>
        >
    with
        $FutureModifier<List<SchoolModel>>,
        $FutureProvider<List<SchoolModel>> {
  CoverageSchoolsProvider._({
    required CoverageSchoolsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'coverageSchoolsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$coverageSchoolsHash();

  @override
  String toString() {
    return r'coverageSchoolsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SchoolModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SchoolModel>> create(Ref ref) {
    final argument = this.argument as String;
    return coverageSchools(ref, cityId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CoverageSchoolsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$coverageSchoolsHash() => r'a201590d27d4cfbe316e0f8ae50925e43ae5e6d0';

final class CoverageSchoolsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SchoolModel>>, String> {
  CoverageSchoolsFamily._()
    : super(
        retry: null,
        name: r'coverageSchoolsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CoverageSchoolsProvider call({required String cityId}) =>
      CoverageSchoolsProvider._(argument: cityId, from: this);

  @override
  String toString() => r'coverageSchoolsProvider';
}

@ProviderFor(coverageAllAreas)
final coverageAllAreasProvider = CoverageAllAreasProvider._();

final class CoverageAllAreasProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AreaModel>>,
          List<AreaModel>,
          FutureOr<List<AreaModel>>
        >
    with $FutureModifier<List<AreaModel>>, $FutureProvider<List<AreaModel>> {
  CoverageAllAreasProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coverageAllAreasProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coverageAllAreasHash();

  @$internal
  @override
  $FutureProviderElement<List<AreaModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AreaModel>> create(Ref ref) {
    return coverageAllAreas(ref);
  }
}

String _$coverageAllAreasHash() => r'966d505d67957c27458bf3e80e026a5cfd7cbe6f';

@ProviderFor(coverageAllSchools)
final coverageAllSchoolsProvider = CoverageAllSchoolsProvider._();

final class CoverageAllSchoolsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SchoolModel>>,
          List<SchoolModel>,
          FutureOr<List<SchoolModel>>
        >
    with
        $FutureModifier<List<SchoolModel>>,
        $FutureProvider<List<SchoolModel>> {
  CoverageAllSchoolsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coverageAllSchoolsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coverageAllSchoolsHash();

  @$internal
  @override
  $FutureProviderElement<List<SchoolModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SchoolModel>> create(Ref ref) {
    return coverageAllSchools(ref);
  }
}

String _$coverageAllSchoolsHash() =>
    r'8a5d68acbee916bfe539ff84728bc1e0d49dea27';

@ProviderFor(driverCoverageAreaIds)
final driverCoverageAreaIdsProvider = DriverCoverageAreaIdsProvider._();

final class DriverCoverageAreaIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  DriverCoverageAreaIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverCoverageAreaIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverCoverageAreaIdsHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return driverCoverageAreaIds(ref);
  }
}

String _$driverCoverageAreaIdsHash() =>
    r'45786b7cc1588c631e3ba8187976822840e5d1ed';

@ProviderFor(driverCoverageSchoolIds)
final driverCoverageSchoolIdsProvider = DriverCoverageSchoolIdsProvider._();

final class DriverCoverageSchoolIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  DriverCoverageSchoolIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverCoverageSchoolIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverCoverageSchoolIdsHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return driverCoverageSchoolIds(ref);
  }
}

String _$driverCoverageSchoolIdsHash() =>
    r'cc0590d74e9224a8596f8c3b549550798bb0a25d';

@ProviderFor(DriverCoverageController)
final driverCoverageControllerProvider = DriverCoverageControllerProvider._();

final class DriverCoverageControllerProvider
    extends $AsyncNotifierProvider<DriverCoverageController, void> {
  DriverCoverageControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverCoverageControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverCoverageControllerHash();

  @$internal
  @override
  DriverCoverageController create() => DriverCoverageController();
}

String _$driverCoverageControllerHash() =>
    r'8ea34faac03bb0b86ce70363941caf993597efec';

abstract class _$DriverCoverageController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
