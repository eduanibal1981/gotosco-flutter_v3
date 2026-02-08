// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookings_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bookingsRepository)
final bookingsRepositoryProvider = BookingsRepositoryProvider._();

final class BookingsRepositoryProvider
    extends
        $FunctionalProvider<
          BookingsRepository,
          BookingsRepository,
          BookingsRepository
        >
    with $Provider<BookingsRepository> {
  BookingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<BookingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BookingsRepository create(Ref ref) {
    return bookingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookingsRepository>(value),
    );
  }
}

String _$bookingsRepositoryHash() =>
    r'267a0f85c73d29e6043e22ec6aeb8916f045d4d0';

@ProviderFor(myBookings)
final myBookingsProvider = MyBookingsProvider._();

final class MyBookingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          Stream<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $StreamProvider<List<Map<String, dynamic>>> {
  MyBookingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myBookingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myBookingsHash();

  @$internal
  @override
  $StreamProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Map<String, dynamic>>> create(Ref ref) {
    return myBookings(ref);
  }
}

String _$myBookingsHash() => r'308b250fefc5cb7eb8fa49c63d3ec77d6016538a';

/// ✅ NEW OPTIMIZED: Returns typed ParentBooking models using the database view.
/// This is 3-4x faster than myBookingsProvider due to fewer network requests.

@ProviderFor(parentBookings)
final parentBookingsProvider = ParentBookingsProvider._();

/// ✅ NEW OPTIMIZED: Returns typed ParentBooking models using the database view.
/// This is 3-4x faster than myBookingsProvider due to fewer network requests.

final class ParentBookingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ParentBooking>>,
          List<ParentBooking>,
          Stream<List<ParentBooking>>
        >
    with
        $FutureModifier<List<ParentBooking>>,
        $StreamProvider<List<ParentBooking>> {
  /// ✅ NEW OPTIMIZED: Returns typed ParentBooking models using the database view.
  /// This is 3-4x faster than myBookingsProvider due to fewer network requests.
  ParentBookingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentBookingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentBookingsHash();

  @$internal
  @override
  $StreamProviderElement<List<ParentBooking>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ParentBooking>> create(Ref ref) {
    return parentBookings(ref);
  }
}

String _$parentBookingsHash() => r'eaa4b2ea2e0aeed7ceaa181c399dfcc97fd5317a';
