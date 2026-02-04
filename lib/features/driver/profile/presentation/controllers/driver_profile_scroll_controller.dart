import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'driver_profile_scroll_controller.g.dart';

enum DriverProfileScrollTarget { serviceAreas, locationSettings, schedule }

@riverpod
class DriverProfileScrollTargetController
    extends _$DriverProfileScrollTargetController {
  @override
  DriverProfileScrollTarget? build() => null;

  void setTarget(DriverProfileScrollTarget? target) {
    state = target;
  }
}
