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

/// Main booking flow screen with 6-step wizard
class BookingFlowScreen extends ConsumerWidget {
  const BookingFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    // TODO: Implement booking submission logic
    // This will call the booking repository to create the booking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Reset the flow and navigate back
    ref.read(bookingFlowControllerProvider.notifier).reset();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
