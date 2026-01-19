// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport_requests_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transportRequestsRepository)
final transportRequestsRepositoryProvider =
    TransportRequestsRepositoryProvider._();

final class TransportRequestsRepositoryProvider
    extends
        $FunctionalProvider<
          TransportRequestsRepository,
          TransportRequestsRepository,
          TransportRequestsRepository
        >
    with $Provider<TransportRequestsRepository> {
  TransportRequestsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transportRequestsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transportRequestsRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransportRequestsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransportRequestsRepository create(Ref ref) {
    return transportRequestsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransportRequestsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransportRequestsRepository>(value),
    );
  }
}

String _$transportRequestsRepositoryHash() =>
    r'1d9e3f60590a5b023a77a1f612746b5de45e1550';

@ProviderFor(parentTransportRequests)
final parentTransportRequestsProvider = ParentTransportRequestsProvider._();

final class ParentTransportRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          Stream<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $StreamProvider<List<Map<String, dynamic>>> {
  ParentTransportRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentTransportRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentTransportRequestsHash();

  @$internal
  @override
  $StreamProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Map<String, dynamic>>> create(Ref ref) {
    return parentTransportRequests(ref);
  }
}

String _$parentTransportRequestsHash() =>
    r'c394d714cb410eccd15764cebf5d3d02af96af9b';
