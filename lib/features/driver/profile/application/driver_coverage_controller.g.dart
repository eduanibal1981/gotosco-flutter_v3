// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_coverage_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
