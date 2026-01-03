// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'children_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller that encapsulates all children management business logic.
/// Handles validation, CRUD operations, and state management.

@ProviderFor(ChildrenController)
final childrenControllerProvider = ChildrenControllerProvider._();

/// Controller that encapsulates all children management business logic.
/// Handles validation, CRUD operations, and state management.
final class ChildrenControllerProvider
    extends $AsyncNotifierProvider<ChildrenController, void> {
  /// Controller that encapsulates all children management business logic.
  /// Handles validation, CRUD operations, and state management.
  ChildrenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'childrenControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$childrenControllerHash();

  @$internal
  @override
  ChildrenController create() => ChildrenController();
}

String _$childrenControllerHash() =>
    r'6dd0f59b1838ec59aa0db8cc232d70b5b4ce5cff';

/// Controller that encapsulates all children management business logic.
/// Handles validation, CRUD operations, and state management.

abstract class _$ChildrenController extends $AsyncNotifier<void> {
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
