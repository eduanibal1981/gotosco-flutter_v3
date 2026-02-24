// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_flow_bookings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bookingFlowBookingsRepository)
final bookingFlowBookingsRepositoryProvider =
    BookingFlowBookingsRepositoryProvider._();

final class BookingFlowBookingsRepositoryProvider
    extends
        $FunctionalProvider<
          BookingsRepository,
          BookingsRepository,
          BookingsRepository
        >
    with $Provider<BookingsRepository> {
  BookingFlowBookingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingFlowBookingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingFlowBookingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<BookingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BookingsRepository create(Ref ref) {
    return bookingFlowBookingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookingsRepository>(value),
    );
  }
}

String _$bookingFlowBookingsRepositoryHash() =>
    r'2e44ae387be38424d8f2aaad1d8d0e48b078f3a6';

@ProviderFor(bookingFlowMyBookings)
final bookingFlowMyBookingsProvider = BookingFlowMyBookingsProvider._();

final class BookingFlowMyBookingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          Stream<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $StreamProvider<List<Map<String, dynamic>>> {
  BookingFlowMyBookingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingFlowMyBookingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingFlowMyBookingsHash();

  @$internal
  @override
  $StreamProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Map<String, dynamic>>> create(Ref ref) {
    return bookingFlowMyBookings(ref);
  }
}

String _$bookingFlowMyBookingsHash() =>
    r'a24479ca7c10ed234d85730c5653e408d37071b4';
