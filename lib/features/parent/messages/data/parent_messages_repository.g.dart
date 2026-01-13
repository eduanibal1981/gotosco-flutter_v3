// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_messages_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(parentMessagesRepository)
final parentMessagesRepositoryProvider = ParentMessagesRepositoryProvider._();

final class ParentMessagesRepositoryProvider
    extends
        $FunctionalProvider<
          ParentMessagesRepository,
          ParentMessagesRepository,
          ParentMessagesRepository
        >
    with $Provider<ParentMessagesRepository> {
  ParentMessagesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentMessagesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentMessagesRepositoryHash();

  @$internal
  @override
  $ProviderElement<ParentMessagesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ParentMessagesRepository create(Ref ref) {
    return parentMessagesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ParentMessagesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ParentMessagesRepository>(value),
    );
  }
}

String _$parentMessagesRepositoryHash() =>
    r'698ea95ee688616d8f9de05300e43334cc30924d';

/// Stream of conversations for the current parent

@ProviderFor(parentConversationsStream)
final parentConversationsStreamProvider = ParentConversationsStreamProvider._();

/// Stream of conversations for the current parent

final class ParentConversationsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ParentConversationModel>>,
          List<ParentConversationModel>,
          Stream<List<ParentConversationModel>>
        >
    with
        $FutureModifier<List<ParentConversationModel>>,
        $StreamProvider<List<ParentConversationModel>> {
  /// Stream of conversations for the current parent
  ParentConversationsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentConversationsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentConversationsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<ParentConversationModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ParentConversationModel>> create(Ref ref) {
    return parentConversationsStream(ref);
  }
}

String _$parentConversationsStreamHash() =>
    r'96bafeffc299f125af7ef7903cbc3b45309284db';
