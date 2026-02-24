// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_flow_contract_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bookingFlowContract)
final bookingFlowContractProvider = BookingFlowContractProvider._();

final class BookingFlowContractProvider
    extends
        $FunctionalProvider<
          BookingFlowContract,
          BookingFlowContract,
          BookingFlowContract
        >
    with $Provider<BookingFlowContract> {
  BookingFlowContractProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingFlowContractProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingFlowContractHash();

  @$internal
  @override
  $ProviderElement<BookingFlowContract> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BookingFlowContract create(Ref ref) {
    return bookingFlowContract(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookingFlowContract value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookingFlowContract>(value),
    );
  }
}

String _$bookingFlowContractHash() =>
    r'9fad43fbc07b6f31cc01fd7364b79a2881426e6d';
