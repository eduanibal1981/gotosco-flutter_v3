// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_repository.dart';

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
          TrackingRepository,
          TrackingRepository,
          TrackingRepository
        >
    with $Provider<TrackingRepository> {
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
  $ProviderElement<TrackingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TrackingRepository create(Ref ref) {
    return trackingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackingRepository>(value),
    );
  }
}

String _$trackingRepositoryHash() =>
    r'65209bc52e5d3cea007e5af602e14d63eadf8082';
