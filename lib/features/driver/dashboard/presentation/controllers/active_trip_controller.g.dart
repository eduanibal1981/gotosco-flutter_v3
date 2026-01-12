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
    extends
        $AsyncNotifierProvider<ActiveTripController, Map<String, dynamic>?> {
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
    r'd5ef195e0a597dd114ad0478fe10b90defcdba39';

abstract class _$ActiveTripController
    extends $AsyncNotifier<Map<String, dynamic>?> {
  FutureOr<Map<String, dynamic>?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<Map<String, dynamic>?>, Map<String, dynamic>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, dynamic>?>,
                Map<String, dynamic>?
              >,
              AsyncValue<Map<String, dynamic>?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
