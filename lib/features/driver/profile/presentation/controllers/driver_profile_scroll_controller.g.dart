// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_profile_scroll_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DriverProfileScrollTargetController)
final driverProfileScrollTargetControllerProvider =
    DriverProfileScrollTargetControllerProvider._();

final class DriverProfileScrollTargetControllerProvider
    extends
        $NotifierProvider<
          DriverProfileScrollTargetController,
          DriverProfileScrollTarget?
        > {
  DriverProfileScrollTargetControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverProfileScrollTargetControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$driverProfileScrollTargetControllerHash();

  @$internal
  @override
  DriverProfileScrollTargetController create() =>
      DriverProfileScrollTargetController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverProfileScrollTarget? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverProfileScrollTarget?>(value),
    );
  }
}

String _$driverProfileScrollTargetControllerHash() =>
    r'9c335c9029e4c39be71e0a636c9d7d0580c32d8e';

abstract class _$DriverProfileScrollTargetController
    extends $Notifier<DriverProfileScrollTarget?> {
  DriverProfileScrollTarget? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<DriverProfileScrollTarget?, DriverProfileScrollTarget?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                DriverProfileScrollTarget?,
                DriverProfileScrollTarget?
              >,
              DriverProfileScrollTarget?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
