// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_flow_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing booking flow state and navigation between steps

@ProviderFor(BookingFlowController)
final bookingFlowControllerProvider = BookingFlowControllerProvider._();

/// Controller for managing booking flow state and navigation between steps
final class BookingFlowControllerProvider
    extends $NotifierProvider<BookingFlowController, BookingDraftModel> {
  /// Controller for managing booking flow state and navigation between steps
  BookingFlowControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingFlowControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingFlowControllerHash();

  @$internal
  @override
  BookingFlowController create() => BookingFlowController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookingDraftModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookingDraftModel>(value),
    );
  }
}

String _$bookingFlowControllerHash() =>
    r'451531919c39d5ad6a8af993ca4379d903a3da99';

/// Controller for managing booking flow state and navigation between steps

abstract class _$BookingFlowController extends $Notifier<BookingDraftModel> {
  BookingDraftModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BookingDraftModel, BookingDraftModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BookingDraftModel, BookingDraftModel>,
              BookingDraftModel,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
