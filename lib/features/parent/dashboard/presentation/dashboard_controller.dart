import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_controller.g.dart';

/// Controls the Bottom Navigation Index
/// 0 = Children, 1 = Find, 2 = Home, 3 = Bookings, 4 = Profile
@riverpod
class ParentDashboardIndex extends _$ParentDashboardIndex {
  @override
  int build() => 1;

  void setIndex(int index) => state = index;
}
