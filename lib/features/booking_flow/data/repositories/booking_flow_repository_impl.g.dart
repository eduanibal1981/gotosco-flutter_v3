// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_flow_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bookingFlowRepository)
final bookingFlowRepositoryProvider = BookingFlowRepositoryProvider._();

final class BookingFlowRepositoryProvider
    extends
        $FunctionalProvider<
          BookingFlowContract,
          BookingFlowContract,
          BookingFlowContract
        >
    with $Provider<BookingFlowContract> {
  BookingFlowRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingFlowRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingFlowRepositoryHash();

  @$internal
  @override
  $ProviderElement<BookingFlowContract> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BookingFlowContract create(Ref ref) {
    return bookingFlowRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookingFlowContract value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookingFlowContract>(value),
    );
  }
}

String _$bookingFlowRepositoryHash() =>
    r'9f88a50d5760c9eabbf9f9dd9db5cb18a88edddb';
