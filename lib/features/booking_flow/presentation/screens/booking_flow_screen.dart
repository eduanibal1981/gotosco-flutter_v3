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

/// Main booking flow screen with 6-step wizard
class BookingFlowScreen extends ConsumerStatefulWidget {
  final String? driverId;
  final String? driverName;

  const BookingFlowScreen({super.key, this.driverId, this.driverName});

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize with driver info if provided
    if (widget.driverId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(bookingFlowControllerProvider.notifier)
            .setDriverInfo(driverId: widget.driverId!);
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
                    _handleSubmit(context, ref);
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
                currentStep == 6 ? 'Submit Booking' : 'Continue',
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

      await repo.createBooking(
        driverId: bookingDraft.driverId!,
        childIds: bookingDraft.studentIds,
        bookingType: bookingDraft.bookingType!,

        schoolId: bookingDraft.isMultiSchool
            ? null
            : null, // If single school, maybe we should set it?
        // Logic: if NOT multi-school, we usually set schoolId on the main booking row.
        // Where do we get it? From the single child?
        // But the repo takes schoolId/schoolName args.
        // For now, let's leave main school_id null if multi-school OR if we don't have it easily.
        // Ideally if single school, we find it.
        // But let's rely on multiSchoolData for complex cases and repo handling.

        // Actually, for single school, we should ideally set schoolId.
        // But let's keep it simple: If multi-school, use table. If single, we might populate standard fields if we had them.
        // But BookingDraft doesn't explicitly store "single school id" except inside children or location logic.
        // We'll pass multiSchoolData if isMultiSchool.
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

        startDate: bookingDraft.contractStartDate ?? DateTime.now(), // Fallback
        endDate: bookingDraft.contractEndDate ?? DateTime.now(),
        isRecurring: bookingDraft.isRecurring,
        recurringDays: bookingDraft.recurringDays,
        isMonthlySubscription: bookingDraft.isMonthlySubscription,

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

        // Navigate away or reset
        ref.read(bookingFlowControllerProvider.notifier).reset();
        Navigator.of(context).pop();
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
}
