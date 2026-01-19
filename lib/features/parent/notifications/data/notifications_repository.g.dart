// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationsRepository)
final notificationsRepositoryProvider = NotificationsRepositoryProvider._();

final class NotificationsRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationsRepository,
          NotificationsRepository,
          NotificationsRepository
        >
    with $Provider<NotificationsRepository> {
  NotificationsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationsRepository create(Ref ref) {
    return notificationsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationsRepository>(value),
    );
  }
}

String _$notificationsRepositoryHash() =>
    r'69165f87f5e43ac7f357875e91f9a7527789692a';

@ProviderFor(parentNotificationsStream)
final parentNotificationsStreamProvider = ParentNotificationsStreamProvider._();

final class ParentNotificationsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          Stream<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $StreamProvider<List<Map<String, dynamic>>> {
  ParentNotificationsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentNotificationsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentNotificationsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Map<String, dynamic>>> create(Ref ref) {
    return parentNotificationsStream(ref);
  }
}

String _$parentNotificationsStreamHash() =>
    r'23afe20b339412aa55749f52d381a3496d5bb3d6';

@ProviderFor(parentNotificationsOnce)
final parentNotificationsOnceProvider = ParentNotificationsOnceProvider._();

final class ParentNotificationsOnceProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  ParentNotificationsOnceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentNotificationsOnceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentNotificationsOnceHash();

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    return parentNotificationsOnce(ref);
  }
}

String _$parentNotificationsOnceHash() =>
    r'5244abf4cee68253f2fbe4dffebd5bb832ab7a19';

@ProviderFor(parentUnreadNotificationsCount)
final parentUnreadNotificationsCountProvider =
    ParentUnreadNotificationsCountProvider._();

final class ParentUnreadNotificationsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  ParentUnreadNotificationsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentUnreadNotificationsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentUnreadNotificationsCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return parentUnreadNotificationsCount(ref);
  }
}

String _$parentUnreadNotificationsCountHash() =>
    r'61bc47458d854b2fc1a1973e39a82f686b600ceb';
