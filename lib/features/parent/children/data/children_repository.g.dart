// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'children_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(childrenRepository)
final childrenRepositoryProvider = ChildrenRepositoryProvider._();

final class ChildrenRepositoryProvider
    extends
        $FunctionalProvider<
          ChildrenRepository,
          ChildrenRepository,
          ChildrenRepository
        >
    with $Provider<ChildrenRepository> {
  ChildrenRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'childrenRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$childrenRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChildrenRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChildrenRepository create(Ref ref) {
    return childrenRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChildrenRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChildrenRepository>(value),
    );
  }
}

String _$childrenRepositoryHash() =>
    r'449e1c59156c5b921fb04ad289a81077797dc77c';

@ProviderFor(myChildren)
final myChildrenProvider = MyChildrenProvider._();

final class MyChildrenProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChildModel>>,
          List<ChildModel>,
          FutureOr<List<ChildModel>>
        >
    with $FutureModifier<List<ChildModel>>, $FutureProvider<List<ChildModel>> {
  MyChildrenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myChildrenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myChildrenHash();

  @$internal
  @override
  $FutureProviderElement<List<ChildModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ChildModel>> create(Ref ref) {
    return myChildren(ref);
  }
}

String _$myChildrenHash() => r'1b3829440957f66b0b38fee8d3cc48c8fb2ed5b5';
