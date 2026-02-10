// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller that encapsulates all authentication business logic.
/// This keeps the UI widgets thin and focused only on presentation.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Controller that encapsulates all authentication business logic.
/// This keeps the UI widgets thin and focused only on presentation.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, AuthResult?> {
  /// Controller that encapsulates all authentication business logic.
  /// This keeps the UI widgets thin and focused only on presentation.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'26f97a879b36b1e257b8d7976d50812dca893e17';

/// Controller that encapsulates all authentication business logic.
/// This keeps the UI widgets thin and focused only on presentation.

abstract class _$AuthController extends $AsyncNotifier<AuthResult?> {
  FutureOr<AuthResult?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthResult?>, AuthResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthResult?>, AuthResult?>,
              AsyncValue<AuthResult?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
