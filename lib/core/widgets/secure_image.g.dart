// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_image.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(signedUrl)
final signedUrlProvider = SignedUrlFamily._();

final class SignedUrlProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  SignedUrlProvider._({
    required SignedUrlFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'signedUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$signedUrlHash();

  @override
  String toString() {
    return r'signedUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return signedUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SignedUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$signedUrlHash() => r'bd30fd9681f2955fe651396e4b184637267a8a18';

final class SignedUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  SignedUrlFamily._()
    : super(
        retry: null,
        name: r'signedUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SignedUrlProvider call(String r2Key) =>
      SignedUrlProvider._(argument: r2Key, from: this);

  @override
  String toString() => r'signedUrlProvider';
}
