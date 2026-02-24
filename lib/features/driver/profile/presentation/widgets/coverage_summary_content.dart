import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/driver_coverage_repository.dart';
import '../../domain/models/city_model.dart';
import '../../domain/models/area_model.dart';
import '../../domain/models/school_model.dart';

class CoverageSummaryContent extends ConsumerWidget {
  const CoverageSummaryContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areaIdsAsync = ref.watch(driverCoverageAreaIdsProvider);
    final schoolIdsAsync = ref.watch(driverCoverageSchoolIdsProvider);
    final citiesAsync = ref.watch(coverageCitiesProvider);
    final allAreasAsync = ref.watch(coverageAllAreasProvider);
    final allSchoolsAsync = ref.watch(coverageAllSchoolsProvider);

    // Combine all states
    final isLoading =
        areaIdsAsync.isLoading ||
        schoolIdsAsync.isLoading ||
        citiesAsync.isLoading ||
        allAreasAsync.isLoading ||
        allSchoolsAsync.isLoading;

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: LinearProgressIndicator(),
      );
    }

    // Safety check for errors or null data
    if (areaIdsAsync.hasError ||
        schoolIdsAsync.hasError ||
        citiesAsync.hasError ||
        allAreasAsync.hasError ||
        allSchoolsAsync.hasError) {
      return const Text('Unable to load coverage details.');
    }

    final cities = citiesAsync.asData?.value ?? [];
    final allAreas = allAreasAsync.asData?.value ?? [];
    final allSchools = allSchoolsAsync.asData?.value ?? [];
    final myAreaIds = areaIdsAsync.asData?.value ?? {};
    final mySchoolIds = schoolIdsAsync.asData?.value ?? {};

    // Grouping Logic
    final areasByCity = <String, List<AreaModel>>{}; // CityName -> Areas
    final schoolsByCity = <String, List<SchoolModel>>{}; // CityName -> Schools
    final fullAreasCountByCity = <String, int>{}; // CityId -> Total Count
    final fullSchoolsCountByCity = <String, int>{}; // CityId -> Total Count

    // 1. Calculate totals per city ID
    for (var area in allAreas) {
      fullAreasCountByCity[area.cityId] =
          (fullAreasCountByCity[area.cityId] ?? 0) + 1;
    }
    for (var school in allSchools) {
      fullSchoolsCountByCity[school.cityId] =
          (fullSchoolsCountByCity[school.cityId] ?? 0) + 1;
    }

    // 2. Map selected items to City NAMES
    for (var areaId in myAreaIds) {
      try {
        final area = allAreas.firstWhere((a) => a.id == areaId);
        final city = cities.firstWhere(
          (c) => c.id == area.cityId,
          orElse: () => _unknownCity,
        );
        areasByCity.putIfAbsent(city.name, () => []).add(area);
      } catch (_) {}
    }

    for (var schoolId in mySchoolIds) {
      try {
        final school = allSchools.firstWhere((s) => s.id == schoolId);
        final city = cities.firstWhere(
          (c) => c.id == school.cityId,
          orElse: () => _unknownCity,
        );
        schoolsByCity.putIfAbsent(city.name, () => []).add(school);
      } catch (_) {}
    }

    final hasNoCoverage = myAreaIds.isEmpty && mySchoolIds.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => context.push('/driver-coverage'),
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Manage Coverage'),
          ),
        ),
        if (hasNoCoverage)
          Text(
            'No service areas or schools added yet.',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          )
        else ...[
          // Areas Section
          if (areasByCity.isNotEmpty) ...[
            Text(
              'Areas:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: areasByCity.entries.map((entry) {
                final cityName = entry.key;
                final myAreas = entry.value;

                // Find city id by name (simplified for display logic)
                final cityId = cities
                    .firstWhere(
                      (c) => c.name == cityName,
                      orElse: () => _unknownCity,
                    )
                    .id;

                final totalInCity = fullAreasCountByCity[cityId] ?? 0;
                final isAllSelected =
                    totalInCity > 0 && myAreas.length == totalInCity;

                if (isAllSelected) {
                  return Chip(
                    label: Text('All of $cityName Areas Selected'),
                    backgroundColor: Colors.teal.shade100,
                    labelStyle: TextStyle(
                      color: Colors.teal.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                } else {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: myAreas
                        .map(
                          (area) => Chip(
                            label: Text('${area.name} ($cityName)'),
                            backgroundColor: Colors.teal.shade50,
                          ),
                        )
                        .toList(),
                  );
                }
              }).toList(),
            ),
          ],

          // Schools Section
          if (schoolsByCity.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Schools:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: schoolsByCity.entries.map((entry) {
                final cityName = entry.key;
                final mySchools = entry.value;

                final cityId = cities
                    .firstWhere(
                      (c) => c.name == cityName,
                      orElse: () => _unknownCity,
                    )
                    .id;

                final totalInCity = fullSchoolsCountByCity[cityId] ?? 0;
                final isAllSelected =
                    totalInCity > 0 && mySchools.length == totalInCity;

                if (isAllSelected) {
                  return Chip(
                    label: Text('All of $cityName Schools Selected'),
                    backgroundColor: Colors.blue.shade100,
                    labelStyle: TextStyle(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                } else {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: mySchools
                        .map(
                          (school) => Chip(
                            label: Text('${school.name} ($cityName)'),
                            backgroundColor: Colors.blue.shade50,
                          ),
                        )
                        .toList(),
                  );
                }
              }).toList(),
            ),
          ],
        ],
      ],
    );
  }

  static const _unknownCity = CityModel(
    id: 'unknown',
    name: 'Unknown',
    state: '',
    country: '',
  );
}

