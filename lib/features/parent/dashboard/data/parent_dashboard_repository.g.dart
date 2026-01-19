// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_dashboard_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(parentTodayTrips)
final parentTodayTripsProvider = ParentTodayTripsProvider._();

final class ParentTodayTripsProvider
    extends
        $FunctionalProvider<
          List<Map<String, dynamic>>,
          List<Map<String, dynamic>>,
          List<Map<String, dynamic>>
        >
    with $Provider<List<Map<String, dynamic>>> {
  ParentTodayTripsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentTodayTripsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentTodayTripsHash();

  @$internal
  @override
  $ProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<Map<String, dynamic>> create(Ref ref) {
    return parentTodayTrips(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Map<String, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Map<String, dynamic>>>(value),
    );
  }
}

String _$parentTodayTripsHash() => r'2e3168c321caec1fb0f6daf0eaee6902f95c4312';
