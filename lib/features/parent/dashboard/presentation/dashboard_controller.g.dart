// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controls the Bottom Navigation Index
/// 0 = Children, 1 = Find Driver, 2 = Home, 3 = Bookings, 4 = Profile

@ProviderFor(ParentDashboardIndex)
final parentDashboardIndexProvider = ParentDashboardIndexProvider._();

/// Controls the Bottom Navigation Index
/// 0 = Children, 1 = Find Driver, 2 = Home, 3 = Bookings, 4 = Profile
final class ParentDashboardIndexProvider
    extends $NotifierProvider<ParentDashboardIndex, int> {
  /// Controls the Bottom Navigation Index
  /// 0 = Children, 1 = Find Driver, 2 = Home, 3 = Bookings, 4 = Profile
  ParentDashboardIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentDashboardIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentDashboardIndexHash();

  @$internal
  @override
  ParentDashboardIndex create() => ParentDashboardIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$parentDashboardIndexHash() =>
    r'9386a0f8b2d531ebb4f9bdf923e3110fcd1f3fd4';

/// Controls the Bottom Navigation Index
/// 0 = Children, 1 = Find Driver, 2 = Home, 3 = Bookings, 4 = Profile

abstract class _$ParentDashboardIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
