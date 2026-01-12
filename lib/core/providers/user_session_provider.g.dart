// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the current user session.
///
/// Loads user data from the database and provides role switching functionality.
/// Automatically refreshes when auth state changes.

@ProviderFor(UserSessionNotifier)
final userSessionProvider = UserSessionNotifierProvider._();

/// Provider for the current user session.
///
/// Loads user data from the database and provides role switching functionality.
/// Automatically refreshes when auth state changes.
final class UserSessionNotifierProvider
    extends $AsyncNotifierProvider<UserSessionNotifier, UserSession?> {
  /// Provider for the current user session.
  ///
  /// Loads user data from the database and provides role switching functionality.
  /// Automatically refreshes when auth state changes.
  UserSessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userSessionNotifierHash();

  @$internal
  @override
  UserSessionNotifier create() => UserSessionNotifier();
}

String _$userSessionNotifierHash() =>
    r'e2fbd0c3d6547ed1b93245876fba86ad93742cc1';

/// Provider for the current user session.
///
/// Loads user data from the database and provides role switching functionality.
/// Automatically refreshes when auth state changes.

abstract class _$UserSessionNotifier extends $AsyncNotifier<UserSession?> {
  FutureOr<UserSession?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserSession?>, UserSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserSession?>, UserSession?>,
              AsyncValue<UserSession?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Internal provider to watch auth state changes

@ProviderFor(_authState)
final _authStateProvider = _AuthStateProvider._();

/// Internal provider to watch auth state changes

final class _AuthStateProvider
    extends
        $FunctionalProvider<AsyncValue<AuthState>, AuthState, Stream<AuthState>>
    with $FutureModifier<AuthState>, $StreamProvider<AuthState> {
  /// Internal provider to watch auth state changes
  _AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_authStateHash();

  @$internal
  @override
  $StreamProviderElement<AuthState> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthState> create(Ref ref) {
    return _authState(ref);
  }
}

String _$_authStateHash() => r'6dddf818e9e4df0690fa554c2ecdf7f73b2bfab2';
