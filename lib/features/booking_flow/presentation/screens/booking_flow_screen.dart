import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/booking_flow_controller.dart';
import '../widgets/progress_indicator_widget.dart';
import '../widgets/step_1_select_child.dart';
import '../widgets/step_2_trip_category.dart';
import '../widgets/step_3_direction.dart';
import '../widgets/step_4_locations.dart';
import '../widgets/step_5_schedule.dart';
import '../widgets/step_6_review.dart';
import '../../../parent/bookings/data/bookings_repository.dart';

import '../../../parent/children/data/children_repository.dart';
import '../../../parent/children/data/child_model.dart';

/// Main booking flow screen with 6-step wizard
class BookingFlowScreen extends ConsumerStatefulWidget {
  final String? driverId;
  final String? driverName;
  final bool isPublicRequest;

  /// For editing an existing pending booking
  final Map<String, dynamic>? editBookingData;
  final String? editBookingId;

  const BookingFlowScreen({
    super.key,
    this.driverId,
    this.driverName,
    this.isPublicRequest = false,
    this.editBookingData,
    this.editBookingId,
  });

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  bool get isEditMode =>
      widget.editBookingId != null && widget.editBookingData != null;

  @override
  void initState() {
    super.initState();

    // If editing an existing booking, load its data
    if (isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(bookingFlowControllerProvider.notifier)
            .loadFromBooking(
              widget.editBookingData!,
              editBookingId: widget.editBookingId,
            );
      });
      return; // Skip other initializations for edit mode
    }

    // Initialize with driver info if provided
    if (widget.driverId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(bookingFlowControllerProvider.notifier)
            .setDriverInfo(driverId: widget.driverId!);
      });
    }

    // Initialize public request mode
    if (widget.isPublicRequest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(bookingFlowControllerProvider.notifier)
            .setPublicRequestMode(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingDraft = ref.watch(bookingFlowControllerProvider);
    final controller = ref.read(bookingFlowControllerProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.indigo.shade50],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        ref
                            .read(bookingFlowControllerProvider.notifier)
                            .reset();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close, color: Colors.grey),
                      tooltip: 'Cancel',
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress Indicator
                BookingProgressIndicator(
                  currentStep: bookingDraft.currentStep,
                  onStepTap: (step) {
                    // Only allow going back to previous steps
                    if (step < bookingDraft.currentStep) {
                      controller.goToStep(step);
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Step Content
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: _buildStepContent(
                              context,
                              bookingDraft.currentStep,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Navigation Buttons
                          _buildNavigationButtons(
                            context,
                            ref,
                            bookingDraft.currentStep,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, int currentStep) {
    switch (currentStep) {
      case 1:
        return const Step1SelectChild();
      case 2:
        return const Step2TripCategory();
      case 3:
        return const Step3Direction();
      case 4:
        return const Step4Locations();
      case 5:
        return const Step5Schedule();
      case 6:
        return const Step6Review();
      default:
        return const Center(child: Text('Invalid step'));
    }
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    WidgetRef ref,
    int currentStep,
  ) {
    final controller = ref.read(bookingFlowControllerProvider.notifier);
    final canProceed = controller.canProceedFromStep(currentStep);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous Button
        if (currentStep > 1)
          OutlinedButton(
            onPressed: () => controller.previousStep(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
            child: const Text(
              'Previous',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          )
        else
          const SizedBox.shrink(),

        // Next/Submit Button
        ElevatedButton(
          onPressed: canProceed
              ? () {
                  if (currentStep < 6) {
                    controller.nextStep();
                  } else {
                    if (isEditMode) {
                      _handleEditSubmit(context, ref);
                    } else {
                      _handleSubmit(context, ref);
                    }
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade600,
            disabledBackgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: canProceed ? 2 : 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentStep == 6
                    ? (isEditMode
                          ? 'Save Changes'
                          : ref
                                .read(bookingFlowControllerProvider)
                                .isPublicRequest
                          ? 'Post Request'
                          : 'Submit Booking')
                    : 'Continue',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (currentStep < 6) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit(BuildContext context, WidgetRef ref) async {
    final bookingDraft = ref.read(bookingFlowControllerProvider);

    // 1. PUBLIC REQUEST SUBMISSION
    if (bookingDraft.isPublicRequest) {
      // Get Child Info
      if (bookingDraft.studentIds.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: No child selected')),
          );
        }
        return;
      }

      final childrenAsync = ref.read(myChildrenProvider);
      if (!childrenAsync.hasValue) {
        return;
      }

      final allChildren = childrenAsync.value!.cast<ChildModel>();
      final selectedChildren = allChildren
          .where((c) => bookingDraft.studentIds.contains(c.id))
          .toList();

      if (selectedChildren.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Selected children not found')),
          );
        }
        return;
      }

      // Serialize Schools Info (if multi-school)
      List<Map<String, dynamic>> schoolsInfo = [];
      if (bookingDraft.isMultiSchool) {
        schoolsInfo = bookingDraft.schoolLocations
            .map(
              (s) => {
                'school_id': s.schoolId,
                'name': s.schoolName,
                'address': s.schoolAddress,
                'latitude': s.latitude,
                'longitude': s.longitude,
                'student_ids': s.studentIds,
              },
            )
            .toList();
      }

      // Fallback/Legacy Summary Data (First Child / First School)
      final primaryChild = selectedChildren.first;
      String schoolNameSummary = 'Multiple Schools';
      double schoolLat = 0;
      double schoolLng = 0;
      String schoolLocationText = 'Values in list';

      if (!bookingDraft.isMultiSchool) {
        // Single location mode (School or Journey)
        if (bookingDraft.tripCategory == 'school') {
          schoolNameSummary = primaryChild.schoolName.isNotEmpty
              ? primaryChild.schoolName
              : 'School';
        } else {
          // For Journey/Other, "School Name" is really "Destination Name"
          // Use the custom dropoff text
          schoolNameSummary = bookingDraft.dropoffLocationText ?? 'Destination';
        }

        schoolLocationText = bookingDraft.dropoffLocationText ?? 'School';
        schoolLat = bookingDraft.dropoffLat ?? 0;
        schoolLng = bookingDraft.dropoffLng ?? 0;

        // Create a single entry in schoolsInfo if empty to ensure JSON consistency
        if (schoolsInfo.isEmpty) {
          schoolsInfo.add({
            'name': schoolNameSummary,
            'address': schoolLocationText,
            'latitude': schoolLat,
            'longitude': schoolLng,
            'type': 'primary',
          });
        }
      } else {
        // Takes the first valid school for summary columns if needed
        if (bookingDraft.schoolLocations.isNotEmpty) {
          final firstS = bookingDraft.schoolLocations.first;
          schoolNameSummary = firstS.schoolName;
          schoolLat = firstS.latitude ?? 0;
          schoolLng = firstS.longitude ?? 0;
          schoolLocationText = firstS.schoolAddress ?? firstS.schoolName;
        }
      }

      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        final bookingsRepo = ref.read(bookingsRepositoryProvider);

        // Prepare Multi-School Data for Booking Repo (needs 'school_id', 'sequence_order')
        List<Map<String, dynamic>>? multiSchoolForBooking;
        if (bookingDraft.isMultiSchool &&
            bookingDraft.schoolLocations.isNotEmpty) {
          int seq = 1;
          multiSchoolForBooking = bookingDraft.schoolLocations
              .map(
                (s) => {
                  'school_id': s.schoolId == 'pending_selection'
                      ? null
                      : s.schoolId, // Handle placeholders? Booking repo might expect UUID
                  'sequence_order': seq++,
                },
              )
              .where((m) => m['school_id'] != null)
              .toList();
        }

        // We assume Bookings Table handles recurring logic natively via start/end dates
        await bookingsRepo.createBooking(
          driverId: null, // Open Request
          childIds: selectedChildren.map((c) => c.id).toList(),
          bookingType: bookingDraft.bookingType ?? 'Two Way',
          tripCategory: bookingDraft.tripCategory,
          isForParent: bookingDraft.isForParent,

          schoolId: !bookingDraft.isMultiSchool
              ? (primaryChild.schoolId != null &&
                        primaryChild.schoolId!.isNotEmpty
                    ? primaryChild.schoolId
                    : null)
              : null,
          schoolName: schoolNameSummary,

          homeLocation: bookingDraft.pickupLocationText,
          schoolLocation: schoolLocationText,

          homeLat: bookingDraft.pickupLat,
          homeLng: bookingDraft.pickupLng,
          schoolLat: schoolLat != 0 ? schoolLat : null,
          schoolLng: schoolLng != 0 ? schoolLng : null,

          homePickupTime: bookingDraft.homePickupTime != null
              ? _parseTimeOfDay(bookingDraft.homePickupTime!)
              : null,
          schoolPickupTime: bookingDraft.schoolPickupTime != null
              ? _parseTimeOfDay(bookingDraft.schoolPickupTime!)
              : null,

          notes: bookingDraft.notes,
          proposalPrice: bookingDraft.estimatedPrice,

          startDate: bookingDraft.contractStartDate ?? DateTime.now(),
          endDate:
              bookingDraft.contractEndDate ??
              DateTime.now().add(const Duration(days: 30)),
          isRecurring: bookingDraft.isRecurring,
          recurringDays: bookingDraft.recurringDays,
          isMonthlySubscription: bookingDraft.isMonthlySubscription,

          // One-time trip
          isOneTime: bookingDraft.isOneTime,
          scheduledPickupDatetime: bookingDraft.scheduledPickupDatetime,
          scheduledDropoffDatetime: bookingDraft.scheduledDropoffDatetime,

          multiSchoolData: multiSchoolForBooking,
        );

        if (context.mounted) {
          Navigator.pop(context); // Hide loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transport request posted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(myBookingsProvider); // Refresh bookings list
          ref.read(bookingFlowControllerProvider.notifier).reset();
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Hide loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to post request: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }

    // 2. REGULAR BOOKING SUBMISSION
    final repo = ref.read(bookingsRepositoryProvider);

    // Basic Validation
    if (bookingDraft.driverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Driver not selected')),
      );
      return;
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Prepare multi-school data
      List<Map<String, dynamic>>? multiSchoolData;
      if (bookingDraft.isMultiSchool) {
        multiSchoolData = bookingDraft.schoolLocations.asMap().entries.map((
          entry,
        ) {
          final index = entry.key;
          final loc = entry.value;
          return {
            'school_id': loc.schoolId == 'pending_selection'
                ? null
                : loc.schoolId,
            'school_lat': loc.latitude,
            'school_lng': loc.longitude,
            'student_ids': loc.studentIds,
            'sequence_order': index + 1,
          };
        }).toList();

        // Check for pending selections
        if (multiSchoolData.any((d) => d['school_id'] == null)) {
          Navigator.pop(context); // Hide loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please select all specific schools in "Locations" step.',
              ),
            ),
          );
          return;
        }
      }

      // Helper for time
      TimeOfDay? parseTime(String? timeStr) {
        if (timeStr == null) return null;
        try {
          final parts = timeStr.split(':');
          return TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        } catch (_) {
          return null;
        }
      }

      // Resolve School ID for Single School Booking (Critical for DB Trigger)
      String? resolvedSchoolId;
      if (!bookingDraft.isMultiSchool && bookingDraft.studentIds.isNotEmpty) {
        final childrenAsync = ref.read(myChildrenProvider);
        if (childrenAsync.hasValue) {
          final allChildren = childrenAsync.value!.cast<ChildModel>();
          final matchingChildren = allChildren.where(
            (c) => bookingDraft.studentIds.contains(c.id),
          );
          if (matchingChildren.isNotEmpty) {
            resolvedSchoolId = matchingChildren.first.schoolId;
          }
        }
      }

      await repo.createBooking(
        driverId: bookingDraft.driverId!,
        childIds: bookingDraft.studentIds,
        bookingType: bookingDraft.bookingType!,
        tripCategory: bookingDraft.tripCategory,
        isForParent: bookingDraft.isForParent,

        schoolId: bookingDraft.isMultiSchool ? null : resolvedSchoolId,
        schoolName: bookingDraft.tripCategory == 'school' ? 'School' : null,

        homeLocation: bookingDraft.pickupLocationText,
        schoolLocation: bookingDraft.dropoffLocationText,
        homeLat: bookingDraft.pickupLat,
        homeLng: bookingDraft.pickupLng,
        schoolLat: bookingDraft.dropoffLat,
        schoolLng: bookingDraft.dropoffLng,

        homePickupTime: parseTime(bookingDraft.homePickupTime),
        schoolPickupTime: parseTime(bookingDraft.schoolPickupTime),

        notes: bookingDraft.notes,
        price: bookingDraft.estimatedPrice,

        startDate: bookingDraft.contractStartDate ?? DateTime.now(),
        endDate: bookingDraft.contractEndDate ?? DateTime.now(),
        isRecurring: bookingDraft.isRecurring,
        recurringDays: bookingDraft.recurringDays,
        isMonthlySubscription: bookingDraft.isMonthlySubscription,

        // One-time trip
        isOneTime: bookingDraft.isOneTime,
        scheduledPickupDatetime: bookingDraft.scheduledPickupDatetime,
        scheduledDropoffDatetime: bookingDraft.scheduledDropoffDatetime,

        multiSchoolData: multiSchoolData,
      );

      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(myBookingsProvider); // Refresh bookings list
        ref.read(bookingFlowControllerProvider.notifier).reset();
        Navigator.of(context).pop(); // Close booking flow screen
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  TimeOfDay? _parseTimeOfDay(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final lower = timeStr.toLowerCase();
      final isPm = lower.contains('pm');
      final isAm = lower.contains('am');

      String cleanTime = timeStr.replaceAll(RegExp(r'[a-zA-Z\s]'), '');
      final parts = cleanTime.split(':');
      if (parts.length < 2) return null;

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  /// Handle saving edits to an existing pending booking
  Future<void> _handleEditSubmit(BuildContext context, WidgetRef ref) async {
    final bookingDraft = ref.read(bookingFlowControllerProvider);
    final repo = ref.read(bookingsRepositoryProvider);

    if (widget.editBookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Booking ID missing')),
      );
      return;
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Prepare multi-school data
      List<Map<String, dynamic>>? multiSchoolData;
      if (bookingDraft.isMultiSchool) {
        multiSchoolData = bookingDraft.schoolLocations.asMap().entries.map((
          entry,
        ) {
          final index = entry.key;
          final loc = entry.value;
          return {
            'school_id': loc.schoolId == 'pending_selection'
                ? null
                : loc.schoolId,
            'school_lat': loc.latitude,
            'school_lng': loc.longitude,
            'student_ids': loc.studentIds,
            'sequence_order': index + 1,
          };
        }).toList();
      }

      // Resolve School ID for Single School Booking
      String? resolvedSchoolId;
      if (!bookingDraft.isMultiSchool && bookingDraft.studentIds.isNotEmpty) {
        final childrenAsync = ref.read(myChildrenProvider);
        if (childrenAsync.hasValue) {
          final allChildren = childrenAsync.value!.cast<ChildModel>();
          final matchingChildren = allChildren.where(
            (c) => bookingDraft.studentIds.contains(c.id),
          );
          if (matchingChildren.isNotEmpty) {
            resolvedSchoolId = matchingChildren.first.schoolId;
          }
        }
      }

      await repo.updateBooking(
        bookingId: widget.editBookingId!,
        childIds: bookingDraft.studentIds,
        bookingType: bookingDraft.bookingType ?? 'Two Way',

        schoolId: bookingDraft.isMultiSchool ? null : resolvedSchoolId,
        schoolName: bookingDraft.tripCategory == 'school' ? 'School' : null,

        homeLocation: bookingDraft.pickupLocationText,
        schoolLocation: bookingDraft.dropoffLocationText,
        homeLat: bookingDraft.pickupLat,
        homeLng: bookingDraft.pickupLng,
        schoolLat: bookingDraft.dropoffLat,
        schoolLng: bookingDraft.dropoffLng,

        homePickupTime: _parseTimeOfDay(bookingDraft.homePickupTime),
        schoolPickupTime: _parseTimeOfDay(bookingDraft.schoolPickupTime),

        notes: bookingDraft.notes,
        price: bookingDraft.estimatedPrice,

        startDate: bookingDraft.contractStartDate ?? DateTime.now(),
        endDate: bookingDraft.contractEndDate ?? DateTime.now(),
        isRecurring: bookingDraft.isRecurring,
        recurringDays: bookingDraft.recurringDays,
        isMonthlySubscription: bookingDraft.isMonthlySubscription,
        isForParent: bookingDraft.isForParent,
        tripCategory: bookingDraft.tripCategory,

        multiSchoolData: multiSchoolData,
      );

      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(myBookingsProvider); // Refresh bookings list
        ref.read(bookingFlowControllerProvider.notifier).resetBookingFlow();
        Navigator.of(context).pop(); // Go back to bookings list
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
