// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// StreamProvider that listens to real-time driver location updates.
/// Using a family provider allows tracking different drivers.
///
/// Usage in UI:
/// ```dart
/// final locationAsync = ref.watch(driverLocationProvider(driverId));
/// ```

@ProviderFor(driverLocation)
final driverLocationProvider = DriverLocationFamily._();

/// StreamProvider that listens to real-time driver location updates.
/// Using a family provider allows tracking different drivers.
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

/// Controller for simulation and other tracking actions.

@ProviderFor(TrackingController)
final trackingControllerProvider = TrackingControllerProvider._();

/// Controller for simulation and other tracking actions.
final class TrackingControllerProvider
    extends $AsyncNotifierProvider<TrackingController, void> {
  /// Controller for simulation and other tracking actions.
  TrackingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackingControllerHash();

  @$internal
  @override
  TrackingController create() => TrackingController();
}

String _$trackingControllerHash() =>
    r'071bc96a6e782ed8a76c8fe74d39a3c9cf86d4f0';

/// Controller for simulation and other tracking actions.

abstract class _$TrackingController extends $AsyncNotifier<void> {
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
