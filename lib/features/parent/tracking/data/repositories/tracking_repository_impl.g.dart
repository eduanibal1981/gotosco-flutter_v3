// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trackingRepository)
final trackingRepositoryProvider = TrackingRepositoryProvider._();

final class TrackingRepositoryProvider
    extends
        $FunctionalProvider<
          TrackingContract,
          TrackingContract,
          TrackingContract
        >
    with $Provider<TrackingContract> {
  TrackingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackingRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackingRepositoryHash();

  @$internal
  @override
  $ProviderElement<TrackingContract> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TrackingContract create(Ref ref) {
    return trackingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackingContract value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackingContract>(value),
    );
  }
}

String _$trackingRepositoryHash() =>
    r'86cfb0d163e36b21245ec8cd7275fa0d3730af82';
