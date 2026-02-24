// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthContract, AuthContract, AuthContract>
    with $Provider<AuthContract> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthContract> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthContract create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthContract value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthContract>(value),
    );
  }
}

String _$authRepositoryHash() => r'2273dd75b75c250aa1bb5af882c0b8069effe2d2';
