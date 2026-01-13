// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_messages_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(driverMessagesRepository)
final driverMessagesRepositoryProvider = DriverMessagesRepositoryProvider._();

final class DriverMessagesRepositoryProvider
    extends
        $FunctionalProvider<
          DriverMessagesRepository,
          DriverMessagesRepository,
          DriverMessagesRepository
        >
    with $Provider<DriverMessagesRepository> {
  DriverMessagesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverMessagesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverMessagesRepositoryHash();

  @$internal
  @override
  $ProviderElement<DriverMessagesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DriverMessagesRepository create(Ref ref) {
    return driverMessagesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverMessagesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverMessagesRepository>(value),
    );
  }
}

String _$driverMessagesRepositoryHash() =>
    r'4adab4a77b9d47b908c4db411fd1364492c1dabd';

/// Stream of conversations for the current driver

@ProviderFor(driverConversationsStream)
final driverConversationsStreamProvider = DriverConversationsStreamProvider._();

/// Stream of conversations for the current driver

final class DriverConversationsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConversationModel>>,
          List<ConversationModel>,
          Stream<List<ConversationModel>>
        >
    with
        $FutureModifier<List<ConversationModel>>,
        $StreamProvider<List<ConversationModel>> {
  /// Stream of conversations for the current driver
  DriverConversationsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverConversationsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverConversationsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<ConversationModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ConversationModel>> create(Ref ref) {
    return driverConversationsStream(ref);
  }
}

String _$driverConversationsStreamHash() =>
    r'4598c990612f3f63b580d3c8c0aa04fc782661b7';
