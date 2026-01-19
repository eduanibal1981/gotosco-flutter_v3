// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller that encapsulates all booking business logic.
/// Handles validation and submission of booking requests.

@ProviderFor(BookingsController)
final bookingsControllerProvider = BookingsControllerProvider._();

/// Controller that encapsulates all booking business logic.
/// Handles validation and submission of booking requests.
final class BookingsControllerProvider
    extends $AsyncNotifierProvider<BookingsController, void> {
  /// Controller that encapsulates all booking business logic.
  /// Handles validation and submission of booking requests.
  BookingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingsControllerHash();

  @$internal
  @override
  BookingsController create() => BookingsController();
}

String _$bookingsControllerHash() =>
    r'228ddea63ffca9658b7452a37d0d1efe9e903920';

/// Controller that encapsulates all booking business logic.
/// Handles validation and submission of booking requests.

abstract class _$BookingsController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
