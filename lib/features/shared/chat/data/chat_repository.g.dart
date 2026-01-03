// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chatRepository)
final chatRepositoryProvider = ChatRepositoryProvider._();

final class ChatRepositoryProvider
    extends $FunctionalProvider<ChatRepository, ChatRepository, ChatRepository>
    with $Provider<ChatRepository> {
  ChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChatRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChatRepository create(Ref ref) {
    return chatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatRepository>(value),
    );
  }
}

String _$chatRepositoryHash() => r'a2357be5498d7fc7172e1a4433153a600f1f0d8d';

/// Stream provider to listen to messages for a specific chat

@ProviderFor(chatStream)
final chatStreamProvider = ChatStreamFamily._();

/// Stream provider to listen to messages for a specific chat

final class ChatStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MessageModel>>,
          List<MessageModel>,
          Stream<List<MessageModel>>
        >
    with
        $FutureModifier<List<MessageModel>>,
        $StreamProvider<List<MessageModel>> {
  /// Stream provider to listen to messages for a specific chat
  ChatStreamProvider._({
    required ChatStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatStreamHash();

  @override
  String toString() {
    return r'chatStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<MessageModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MessageModel>> create(Ref ref) {
    final argument = this.argument as String;
    return chatStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatStreamHash() => r'9c67b1c296df39d88c983eb2cc1e9483a48c1280';

/// Stream provider to listen to messages for a specific chat

final class ChatStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<MessageModel>>, String> {
  ChatStreamFamily._()
    : super(
        retry: null,
        name: r'chatStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream provider to listen to messages for a specific chat

  ChatStreamProvider call(String otherUserId) =>
      ChatStreamProvider._(argument: otherUserId, from: this);

  @override
  String toString() => r'chatStreamProvider';
}
