// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_profile_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(parentProfileRepository)
final parentProfileRepositoryProvider = ParentProfileRepositoryProvider._();

final class ParentProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ParentProfileContract,
          ParentProfileContract,
          ParentProfileContract
        >
    with $Provider<ParentProfileContract> {
  ParentProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentProfileRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentProfileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ParentProfileContract> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ParentProfileContract create(Ref ref) {
    return parentProfileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ParentProfileContract value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ParentProfileContract>(value),
    );
  }
}

String _$parentProfileRepositoryHash() =>
    r'acb6be9c93638e902b09dd43e1be64f5c207d647';
