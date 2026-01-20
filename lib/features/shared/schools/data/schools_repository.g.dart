// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schools_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(schoolsRepository)
final schoolsRepositoryProvider = SchoolsRepositoryProvider._();

final class SchoolsRepositoryProvider
    extends
        $FunctionalProvider<
          SchoolsRepository,
          SchoolsRepository,
          SchoolsRepository
        >
    with $Provider<SchoolsRepository> {
  SchoolsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schoolsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schoolsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SchoolsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SchoolsRepository create(Ref ref) {
    return schoolsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SchoolsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SchoolsRepository>(value),
    );
  }
}

String _$schoolsRepositoryHash() => r'ff62fa716b01f6b6a3e8acbf1334176de2d6b016';
