import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_controller.g.dart';

/// Controls the Bottom Navigation Index
/// 0 = Find, 1 = Home (Default), 2 = Children, etc.
@riverpod
class ParentDashboardIndex extends _$ParentDashboardIndex {
  @override
  int build() => 1;

  void setIndex(int index) => state = index;
}
