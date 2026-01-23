import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/booking_flow_controller.dart';
import '../../../parent/children/data/children_repository.dart';

/// Step 1: Select child for booking
class Step1SelectChild extends ConsumerWidget {
  const Step1SelectChild({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(myChildrenProvider);
    final bookingDraft = ref.watch(bookingFlowControllerProvider);
    final selectedIds = bookingDraft.studentIds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Child(ren)',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedIds.isEmpty
                        ? 'Choose one or more children for this trip'
                        : '${selectedIds.length} child${selectedIds.length > 1 ? "ren" : ""} selected',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selectedIds.isEmpty
                          ? Colors.grey.shade600
                          : Colors.indigo.shade700,
                      fontWeight: selectedIds.isEmpty
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (selectedIds.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  ref
                      .read(bookingFlowControllerProvider.notifier)
                      .clearChildSelections();
                },
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),

        Expanded(
          child: childrenAsync.when(
            data: (children) {
              if (children.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.child_care_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No children added yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please add a child in your profile first',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: children.length,
                itemBuilder: (context, index) {
                  final child = children[index];
                  final isSelected = selectedIds.contains(child.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () async {
                        // Toggle child selection
                        ref
                            .read(bookingFlowControllerProvider.notifier)
                            .toggleChildSelection(child.id);

                        // Auto-populate locations from user profile and school(s)
                        await _autoPopulateLocationsForMultiple(ref, children);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? Colors.indigo.shade500
                                : Colors.grey.shade200,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          color: isSelected
                              ? Colors.indigo.shade50
                              : Colors.transparent,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Checkbox
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.indigo.shade600
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.indigo.shade600
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            // Child Avatar
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.indigo.shade400,
                                    Colors.purple.shade500,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  child.name.isNotEmpty
                                      ? child.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Child Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    child.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_calculateAge(child.dob)} years • Grade ${child.grade}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (child.schoolName.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.school_outlined,
                                          size: 16,
                                          color: Colors.grey.shade500,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            child.schoolName,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load children',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Helper method to calculate age from date of birth
  int _calculateAge(DateTime? dob) {
    if (dob == null) return 0;
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  /// Auto-populate locations for multiple children selection
  Future<void> _autoPopulateLocationsForMultiple(
    WidgetRef ref,
    List<dynamic> allChildren,
  ) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final bookingDraft = ref.read(bookingFlowControllerProvider);
      final selectedIds = bookingDraft.studentIds;

      if (selectedIds.isEmpty) {
        // Clear locations if no children selected
        ref
            .read(bookingFlowControllerProvider.notifier)
            .autoPopulateLocations(
              homeLocationText: null,
              homeLat: null,
              homeLng: null,
              schoolLocationText: null,
              schoolLat: null,
              schoolLng: null,
            );
        return;
      }

      // Always fetch user's home location
      final userResponse = await supabase
          .from('users')
          .select('location_text, location_lat, location_lng')
          .eq('id', userId)
          .maybeSingle();

      String? homeLocationText = userResponse?['location_text'];
      double? homeLat = userResponse?['location_lat'];
      double? homeLng = userResponse?['location_lng'];

      // Get selected children
      final selectedChildren = allChildren
          .where((c) => selectedIds.contains(c.id))
          .toList();

      // Check if all selected children go to the same school
      String? schoolLocationText;
      double? schoolLat;
      double? schoolLng;
      bool requiresManualSelection = false;

      if (selectedChildren.isNotEmpty) {
        // Get unique school IDs
        final schoolIds = selectedChildren
            .where((c) => c.schoolId != null && c.schoolId.isNotEmpty)
            .map((c) => c.schoolId as String)
            .toSet();

        if (schoolIds.isEmpty) {
          // No schools linked - require manual selection
          requiresManualSelection = true;
        } else if (schoolIds.length == 1) {
          // All children go to the same school - auto-populate
          final schoolId = schoolIds.first;
          final schoolResponse = await supabase
              .from('schools')
              .select('name, address, latitude, longitude')
              .eq('id', schoolId)
              .maybeSingle();

          if (schoolResponse != null) {
            schoolLocationText =
                schoolResponse['address'] ??
                schoolResponse['name'] ??
                selectedChildren.first.schoolName;
            schoolLat = schoolResponse['latitude'];
            schoolLng = schoolResponse['longitude'];
          } else {
            // School not found - use name only
            schoolLocationText = selectedChildren.first.schoolName;
          }
        } else {
          // Children go to different schools - require manual selection
          requiresManualSelection = true;
        }
      }

      // Auto-populate the locations
      ref
          .read(bookingFlowControllerProvider.notifier)
          .autoPopulateLocations(
            homeLocationText: homeLocationText,
            homeLat: homeLat,
            homeLng: homeLng,
            schoolLocationText: schoolLocationText,
            schoolLat: schoolLat,
            schoolLng: schoolLng,
            requiresManualSelection: requiresManualSelection,
          );

      // Populate school locations structure for multi-school support
      // This will set isMultiSchool=true if multiple schools are detected
      await ref
          .read(bookingFlowControllerProvider.notifier)
          .buildSchoolLocationsFromChildren();
    } catch (e) {
      debugPrint('Error auto-populating locations for multiple children: $e');
      // Continue without auto-population if there's an error
    }
  }
}
