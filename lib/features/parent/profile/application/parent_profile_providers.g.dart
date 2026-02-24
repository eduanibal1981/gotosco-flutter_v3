// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(parentProfileUser)
final parentProfileUserProvider = ParentProfileUserProvider._();

final class ParentProfileUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserModel?>,
          UserModel?,
          FutureOr<UserModel?>
        >
    with $FutureModifier<UserModel?>, $FutureProvider<UserModel?> {
  ParentProfileUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentProfileUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentProfileUserHash();

  @$internal
  @override
  $FutureProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserModel?> create(Ref ref) {
    return parentProfileUser(ref);
  }
}

String _$parentProfileUserHash() => r'3495acc9506d65f14a6cec45d4052f43f01d3d76';

@ProviderFor(parentProfileChildren)
final parentProfileChildrenProvider = ParentProfileChildrenProvider._();

final class ParentProfileChildrenProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChildModel>>,
          List<ChildModel>,
          FutureOr<List<ChildModel>>
        >
    with $FutureModifier<List<ChildModel>>, $FutureProvider<List<ChildModel>> {
  ParentProfileChildrenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentProfileChildrenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentProfileChildrenHash();

  @$internal
  @override
  $FutureProviderElement<List<ChildModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ChildModel>> create(Ref ref) {
    return parentProfileChildren(ref);
  }
}

String _$parentProfileChildrenHash() =>
    r'6b59fdb671f6c7bdac46d96850ea4abd6dcf6cad';

@ProviderFor(parentProfileBookings)
final parentProfileBookingsProvider = ParentProfileBookingsProvider._();

final class ParentProfileBookingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          Stream<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $StreamProvider<List<Map<String, dynamic>>> {
  ParentProfileBookingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentProfileBookingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentProfileBookingsHash();

  @$internal
  @override
  $StreamProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Map<String, dynamic>>> create(Ref ref) {
    return parentProfileBookings(ref);
  }
}

String _$parentProfileBookingsHash() =>
    r'305509d8d635257df5339ccee5620adf740c57c9';

@ProviderFor(parentProfileSession)
final parentProfileSessionProvider = ParentProfileSessionProvider._();

final class ParentProfileSessionProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserSession?>,
          UserSession?,
          FutureOr<UserSession?>
        >
    with $FutureModifier<UserSession?>, $FutureProvider<UserSession?> {
  ParentProfileSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentProfileSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentProfileSessionHash();

  @$internal
  @override
  $FutureProviderElement<UserSession?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserSession?> create(Ref ref) {
    return parentProfileSession(ref);
  }
}

String _$parentProfileSessionHash() =>
    r'114b9013fe7fbdc58c4a6a41efc39dda5b5c0809';
