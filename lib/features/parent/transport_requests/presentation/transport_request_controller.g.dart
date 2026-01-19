// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport_request_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransportRequestController)
final transportRequestControllerProvider =
    TransportRequestControllerProvider._();

final class TransportRequestControllerProvider
    extends $AsyncNotifierProvider<TransportRequestController, void> {
  TransportRequestControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transportRequestControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transportRequestControllerHash();

  @$internal
  @override
  TransportRequestController create() => TransportRequestController();
}

String _$transportRequestControllerHash() =>
    r'8c24535478624eaf021c581e510babfe12c3f73d';

abstract class _$TransportRequestController extends $AsyncNotifier<void> {
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
