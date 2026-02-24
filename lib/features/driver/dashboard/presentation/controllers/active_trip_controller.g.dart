// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_trip_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveTripController)
final activeTripControllerProvider = ActiveTripControllerProvider._();

final class ActiveTripControllerProvider
    extends $AsyncNotifierProvider<ActiveTripController, DriverTrip?> {
  ActiveTripControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeTripControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeTripControllerHash();

  @$internal
  @override
  ActiveTripController create() => ActiveTripController();
}

String _$activeTripControllerHash() =>
    r'871212ab524355cbf42b3a47ed6585947fceb143';

abstract class _$ActiveTripController extends $AsyncNotifier<DriverTrip?> {
  FutureOr<DriverTrip?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DriverTrip?>, DriverTrip?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DriverTrip?>, DriverTrip?>,
              AsyncValue<DriverTrip?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
