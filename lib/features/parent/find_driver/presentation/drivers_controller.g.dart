// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drivers_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller that manages driver filters state.
/// Provides filter summary and clear functionality.

@ProviderFor(DriversFilterController)
final driversFilterControllerProvider = DriversFilterControllerProvider._();

/// Controller that manages driver filters state.
/// Provides filter summary and clear functionality.
final class DriversFilterControllerProvider
    extends $NotifierProvider<DriversFilterController, Map<String, dynamic>> {
  /// Controller that manages driver filters state.
  /// Provides filter summary and clear functionality.
  DriversFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driversFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driversFilterControllerHash();

  @$internal
  @override
  DriversFilterController create() => DriversFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, dynamic> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, dynamic>>(value),
    );
  }
}

String _$driversFilterControllerHash() =>
    r'614775f8aac03c616544f87c1575c96cb3505c63';

/// Controller that manages driver filters state.
/// Provides filter summary and clear functionality.

abstract class _$DriversFilterController
    extends $Notifier<Map<String, dynamic>> {
  Map<String, dynamic> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, dynamic>, Map<String, dynamic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, dynamic>, Map<String, dynamic>>,
              Map<String, dynamic>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
