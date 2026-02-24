// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_flow_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bookingFlowChildren)
final bookingFlowChildrenProvider = BookingFlowChildrenProvider._();

final class BookingFlowChildrenProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BookingFlowChildModel>>,
          List<BookingFlowChildModel>,
          FutureOr<List<BookingFlowChildModel>>
        >
    with
        $FutureModifier<List<BookingFlowChildModel>>,
        $FutureProvider<List<BookingFlowChildModel>> {
  BookingFlowChildrenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingFlowChildrenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingFlowChildrenHash();

  @$internal
  @override
  $FutureProviderElement<List<BookingFlowChildModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BookingFlowChildModel>> create(Ref ref) {
    return bookingFlowChildren(ref);
  }
}

String _$bookingFlowChildrenHash() =>
    r'cd16fd7214e9620e953c36b397fbfb0967f453e8';
