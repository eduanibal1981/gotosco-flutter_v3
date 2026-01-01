import 'package:flutter_riverpod/legacy.dart';

// Controls the Bottom Navigation Index
// 0 = Find, 1 = Home (Default), 2 = Children, etc.
final parentDashboardIndexProvider = StateProvider<int>((ref) => 1);