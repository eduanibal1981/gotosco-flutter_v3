import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/booking_flow_controller.dart';

/// Step 6: Review booking details before submission
class Step6Review extends ConsumerWidget {
  const Step6Review({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingDraft = ref.watch(bookingFlowControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Booking',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please review your booking details',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),

        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  // Child
                  _buildReviewRow(
                    label: 'Child',
                    value: bookingDraft.studentId ?? 'Not selected',
                    icon: Icons.child_care,
                    iconColor: Colors.purple,
                  ),

                  const Divider(height: 32),

                  // Trip Type
                  _buildReviewRow(
                    label: 'Trip Type',
                    value: _formatTripCategory(bookingDraft.tripCategory),
                    icon: Icons.category,
                    iconColor: Colors.blue,
                  ),

                  const Divider(height: 32),

                  // Direction
                  _buildReviewRow(
                    label: 'Direction',
                    value: bookingDraft.bookingType ?? 'Not selected',
                    icon: Icons.alt_route,
                    iconColor: Colors.orange,
                  ),

                  const Divider(height: 32),

                  // Locations
                  _buildLocationsSection(bookingDraft),

                  const Divider(height: 32),

                  // Schedule
                  _buildScheduleSection(bookingDraft),

                  const Divider(height: 32),

                  // Notes field
                  _buildNotesField(ref, bookingDraft),

                  const SizedBox(height: 24),

                  // Estimated Price
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.indigo.shade600,
                          Colors.purple.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimated Price',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${bookingDraft.estimatedPrice?.toStringAsFixed(2) ?? '0.00'} OMR',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your booking will be sent to the selected driver for approval',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationsSection(dynamic bookingDraft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Locations',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Multi-School Logic
        if (bookingDraft.isMultiSchool) ...[
          // 1. Pickup (always valid for Two Way / Go Only)
          if (bookingDraft.pickupLocationText != null &&
              bookingDraft.bookingType !=
                  'One Way Back Home') // Standard Pickup
            _buildDetailRow(
              'Pickup (Home):',
              bookingDraft.pickupLocationText ?? 'N/A',
            ),

          // 2. Schools List (replaces Dropoff for Two Way / Go Only)
          if (bookingDraft.bookingType != 'One Way Back Home') ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dropoff (Schools):',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  ...bookingDraft.schoolLocations.map<Widget>((school) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${school.schoolName}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],

          // 3. Pickup from Schools (One Way Back Home)
          if (bookingDraft.bookingType == 'One Way Back Home') ...[
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pickup (Schools):',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  ...bookingDraft.schoolLocations.map<Widget>((school) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${school.schoolName}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],

          // 4. Dropoff at Home (One Way Back Home)
          if (bookingDraft.bookingType == 'One Way Back Home' &&
              bookingDraft.dropoffLocationText != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              'Dropoff (Home):',
              bookingDraft.dropoffLocationText ?? 'N/A',
            ),
          ],
        ] else ...[
          // Standard Single Location Logic
          if (bookingDraft.pickupLocationText != null)
            _buildDetailRow(
              'Pickup:',
              bookingDraft.pickupLocationText ?? 'N/A',
            ),

          if (bookingDraft.dropoffLocationText != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              'Dropoff:',
              bookingDraft.dropoffLocationText ?? 'N/A',
            ),
          ],
        ],
      ],
    );
  }

  /// Helper widget to build a detail row with label and value
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(dynamic bookingDraft) {
    String scheduleType = 'Not selected';
    String scheduleDetails = '';

    if (bookingDraft.isOneTime) {
      scheduleType = 'One-Time Trip';
      if (bookingDraft.scheduledPickupDatetime != null) {
        scheduleDetails = DateFormat(
          'MMM dd, yyyy - hh:mm a',
        ).format(bookingDraft.scheduledPickupDatetime!);
      }
    } else if (bookingDraft.isRecurring) {
      scheduleType = 'Recurring Trip';
      if (bookingDraft.recurringDays != null &&
          bookingDraft.recurringDays!.isNotEmpty) {
        scheduleDetails =
            '${bookingDraft.recurringDays!.join(', ')}\nPickup: ${bookingDraft.homePickupTime ?? 'Not set'}';
      }
    } else if (bookingDraft.isMonthlySubscription) {
      scheduleType = 'Monthly Subscription';
      if (bookingDraft.contractStartDate != null &&
          bookingDraft.contractEndDate != null) {
        scheduleDetails =
            '${DateFormat('MMM dd').format(bookingDraft.contractStartDate!)} - ${DateFormat('MMM dd, yyyy').format(bookingDraft.contractEndDate!)}\nDaily pickup: ${bookingDraft.homePickupTime ?? 'Not set'}';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Colors.indigo,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Schedule',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scheduleType,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (scheduleDetails.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  scheduleDetails,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField(WidgetRef ref, dynamic bookingDraft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Notes (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any special instructions or notes...',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo.shade600, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            ref.read(bookingFlowControllerProvider.notifier).setNotes(value);
          },
        ),
      ],
    );
  }

  String _formatTripCategory(String category) {
    switch (category) {
      case 'school':
        return 'School Transport';
      case 'Journey':
        return 'Journey Trip';
      case 'Other':
        return 'Other';
      default:
        return category;
    }
  }
}
