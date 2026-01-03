// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AUTH STATE STREAM
/// Listens to Supabase (Login, Logout, Token Refresh).
/// The UI watches this to decide whether to show LoginScreen or HomeScreen.

@ProviderFor(authStateChanges)
final authStateChangesProvider = AuthStateChangesProvider._();

/// AUTH STATE STREAM
/// Listens to Supabase (Login, Logout, Token Refresh).
/// The UI watches this to decide whether to show LoginScreen or HomeScreen.

final class AuthStateChangesProvider
    extends
        $FunctionalProvider<AsyncValue<AuthState>, AuthState, Stream<AuthState>>
    with $FutureModifier<AuthState>, $StreamProvider<AuthState> {
  /// AUTH STATE STREAM
  /// Listens to Supabase (Login, Logout, Token Refresh).
  /// The UI watches this to decide whether to show LoginScreen or HomeScreen.
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
  $StreamProviderElement<AuthState> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthState> create(Ref ref) {
    return authStateChanges(ref);
  }
}

String _$authStateChangesHash() => r'ec06ce46bdc8fee126d288aa2103df3459b3db7f';

/// CURRENT USER PROFILE
/// Fetches the full 'UserModel' (name, role, phone) from the database.
/// Smart Logic: It watches 'authStateChangesProvider', so if the user
/// logs out, this automatically updates/nullifies without extra code.

@ProviderFor(currentUserProfile)
final currentUserProfileProvider = CurrentUserProfileProvider._();

/// CURRENT USER PROFILE
/// Fetches the full 'UserModel' (name, role, phone) from the database.
/// Smart Logic: It watches 'authStateChangesProvider', so if the user
/// logs out, this automatically updates/nullifies without extra code.

final class CurrentUserProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserModel?>,
          UserModel?,
          FutureOr<UserModel?>
        >
    with $FutureModifier<UserModel?>, $FutureProvider<UserModel?> {
  /// CURRENT USER PROFILE
  /// Fetches the full 'UserModel' (name, role, phone) from the database.
  /// Smart Logic: It watches 'authStateChangesProvider', so if the user
  /// logs out, this automatically updates/nullifies without extra code.
  CurrentUserProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserProfileHash();

  @$internal
  @override
  $FutureProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserModel?> create(Ref ref) {
    return currentUserProfile(ref);
  }
}

String _$currentUserProfileHash() =>
    r'77bd8c069df756116a1ea2195dd9c006eeff8d50';
