// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the current user session.
/// Loads user data from the database and provides role switching functionality.
/// Automatically refreshes when auth state changes.

@ProviderFor(UserSessionNotifier)
final userSessionProvider = UserSessionNotifierProvider._();

/// Provider for the current user session.
/// Loads user data from the database and provides role switching functionality.
/// Automatically refreshes when auth state changes.
final class UserSessionNotifierProvider
    extends $AsyncNotifierProvider<UserSessionNotifier, UserSession?> {
  /// Provider for the current user session.
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
    r'6876c30c51caff868f50dc5dbc205a9cb2d84721';

/// Provider for the current user session.
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

@ProviderFor(authStateChanges)
final authStateChangesProvider = AuthStateChangesProvider._();

/// Internal provider to watch auth state changes

final class AuthStateChangesProvider
    extends
        $FunctionalProvider<AsyncValue<AuthUser?>, AuthUser?, Stream<AuthUser?>>
    with $FutureModifier<AuthUser?>, $StreamProvider<AuthUser?> {
  /// Internal provider to watch auth state changes
  AuthStateChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateChangesHash();

  @$internal
  @override
  $StreamProviderElement<AuthUser?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthUser?> create(Ref ref) {
    return authStateChanges(ref);
  }
}

String _$authStateChangesHash() => r'8102bb76553f558fba5213ffaa31139157c8b079';
