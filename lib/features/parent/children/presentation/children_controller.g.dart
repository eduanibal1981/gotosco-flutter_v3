// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'children_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to fetch attendance history for a specific child

@ProviderFor(attendanceHistory)
final attendanceHistoryProvider = AttendanceHistoryFamily._();

/// Provider to fetch attendance history for a specific child

final class AttendanceHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AttendanceRecord>>,
          List<AttendanceRecord>,
          FutureOr<List<AttendanceRecord>>
        >
    with
        $FutureModifier<List<AttendanceRecord>>,
        $FutureProvider<List<AttendanceRecord>> {
  /// Provider to fetch attendance history for a specific child
  AttendanceHistoryProvider._({
    required AttendanceHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'attendanceHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$attendanceHistoryHash();

  @override
  String toString() {
    return r'attendanceHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AttendanceRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AttendanceRecord>> create(Ref ref) {
    final argument = this.argument as String;
    return attendanceHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AttendanceHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$attendanceHistoryHash() => r'6d74b76dc6b0edeacf16306f8c87e247c2e7ae3f';

/// Provider to fetch attendance history for a specific child

final class AttendanceHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AttendanceRecord>>, String> {
  AttendanceHistoryFamily._()
    : super(
        retry: null,
        name: r'attendanceHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to fetch attendance history for a specific child

  AttendanceHistoryProvider call(String childId) =>
      AttendanceHistoryProvider._(argument: childId, from: this);

  @override
  String toString() => r'attendanceHistoryProvider';
}

/// Controller that encapsulates all children management business logic.
/// Handles validation, CRUD operations, and state management.

@ProviderFor(ChildrenController)
final childrenControllerProvider = ChildrenControllerProvider._();

/// Controller that encapsulates all children management business logic.
/// Handles validation, CRUD operations, and state management.
final class ChildrenControllerProvider
    extends $AsyncNotifierProvider<ChildrenController, void> {
  /// Controller that encapsulates all children management business logic.
  /// Handles validation, CRUD operations, and state management.
  ChildrenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'childrenControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$childrenControllerHash();

  @$internal
  @override
  ChildrenController create() => ChildrenController();
}

String _$childrenControllerHash() =>
    r'6dd0f59b1838ec59aa0db8cc232d70b5b4ce5cff';

/// Controller that encapsulates all children management business logic.
/// Handles validation, CRUD operations, and state management.

abstract class _$ChildrenController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
