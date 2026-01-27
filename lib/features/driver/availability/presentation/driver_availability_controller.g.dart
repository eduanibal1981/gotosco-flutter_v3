// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_availability_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DriverAvailabilityController)
final driverAvailabilityControllerProvider =
    DriverAvailabilityControllerProvider._();

final class DriverAvailabilityControllerProvider
    extends
        $AsyncNotifierProvider<
          DriverAvailabilityController,
          DriverAvailabilitySettings
        > {
  DriverAvailabilityControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverAvailabilityControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverAvailabilityControllerHash();

  @$internal
  @override
  DriverAvailabilityController create() => DriverAvailabilityController();
}

String _$driverAvailabilityControllerHash() =>
    r'9cf02a672b3867b6756498a5197b20ab83645bbb';

abstract class _$DriverAvailabilityController
    extends $AsyncNotifier<DriverAvailabilitySettings> {
  FutureOr<DriverAvailabilitySettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<DriverAvailabilitySettings>,
              DriverAvailabilitySettings
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<DriverAvailabilitySettings>,
                DriverAvailabilitySettings
              >,
              AsyncValue<DriverAvailabilitySettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
