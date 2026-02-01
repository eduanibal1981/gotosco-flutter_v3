import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotosco_v3/features/driver/profile/data/area_model.dart';
import 'package:gotosco_v3/features/driver/profile/data/city_model.dart';
import 'package:gotosco_v3/features/driver/profile/data/driver_coverage_repository.dart';
import 'package:gotosco_v3/features/driver/profile/data/school_model.dart';
import 'package:gotosco_v3/features/driver/profile/presentation/widgets/coverage_summary_content.dart';

void main() {
  testWidgets('CoverageSummaryContent displays city name in chips',
      (WidgetTester tester) async {
    // 1. Setup Data
    const city = CityModel(id: 'c1', name: 'Muscat');
    // We need at least 2 areas in the city so that "All Areas" logic isn't triggered
    const area1 = AreaModel(id: 'a1', cityId: 'c1', name: 'Bawsher');
    const area2 = AreaModel(id: 'a2', cityId: 'c1', name: 'Seeb');

    // Similarly for schools
    const school1 = SchoolModel(id: 's1', cityId: 'c1', name: 'British School');
    const school2 = SchoolModel(id: 's2', cityId: 'c1', name: 'American School');

    // 2. Pump Widget with Overrides
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coverageCitiesProvider.overrideWith((ref) => Future.value([city])),
          coverageAllAreasProvider.overrideWith((ref) => Future.value([area1, area2])),
          coverageAllSchoolsProvider
              .overrideWith((ref) => Future.value([school1, school2])),
          // Only select the first one of each
          driverCoverageAreaIdsProvider
              .overrideWith((ref) => Future.value({'a1'})),
          driverCoverageSchoolIdsProvider
              .overrideWith((ref) => Future.value({'s1'})),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CoverageSummaryContent(),
          ),
        ),
      ),
    );

    // 3. Pump to resolve futures
    await tester.pumpAndSettle();

    // Debugging
    if (find.text('All of Muscat Areas Selected').evaluate().isNotEmpty) {
      debugPrint('Found "All Areas Selected" chip - logic issue in test setup');
    }

    // 4. Verify Fix
    expect(find.text('Bawsher (Muscat)'), findsOneWidget);
    expect(find.text('British School (Muscat)'), findsOneWidget);
  });
}
