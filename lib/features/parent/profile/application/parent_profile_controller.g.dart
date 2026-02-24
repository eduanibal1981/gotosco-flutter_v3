// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ParentProfileController)
final parentProfileControllerProvider = ParentProfileControllerProvider._();

final class ParentProfileControllerProvider
    extends $AsyncNotifierProvider<ParentProfileController, void> {
  ParentProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentProfileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentProfileControllerHash();

  @$internal
  @override
  ParentProfileController create() => ParentProfileController();
}

String _$parentProfileControllerHash() =>
    r'5953f570e7d158785e1fec636aecd08436801ab4';

abstract class _$ParentProfileController extends $AsyncNotifier<void> {
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
