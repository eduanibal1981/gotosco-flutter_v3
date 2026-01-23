import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/booking_flow_controller.dart';

/// Step 4: Set pickup and dropoff locations
class Step4Locations extends ConsumerWidget {
  const Step4Locations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingDraft = ref.watch(bookingFlowControllerProvider);
    final bookingType = bookingDraft.bookingType ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set Locations',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose pickup and dropoff locations',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Pickup Location (for Two Way and Go Only)
                if (bookingType == 'Two Way' ||
                    bookingType == 'One Way to School')
                  _buildLocationField(
                    context,
                    ref,
                    label: 'Pickup Location',
                    icon: Icons.location_on,
                    iconColor: Colors.green,
                    hintText: bookingDraft.tripCategory == 'school'
                        ? 'Your home address'
                        : 'Enter pickup location',
                    currentLocation: bookingDraft.pickupLocationText,
                    onTap: () => _pickLocation(context, ref, isPickup: true),
                  ),

                if (bookingType == 'Two Way' ||
                    bookingType == 'One Way to School')
                  const SizedBox(height: 20),

                // Dropoff Location (for Two Way and Go Only)
                if (bookingType == 'Two Way' ||
                    bookingType == 'One Way to School')
                  _buildLocationField(
                    context,
                    ref,
                    label: 'Dropoff Location',
                    icon: Icons.flag,
                    iconColor: Colors.red,
                    hintText: bookingDraft.tripCategory == 'school'
                        ? 'School address'
                        : 'Enter dropoff location',
                    currentLocation: bookingDraft.dropoffLocationText,
                    onTap: () => _pickLocation(context, ref, isPickup: false),
                  ),

                // Pickup Location (for Return Only - same as dropoff)
                if (bookingType == 'One Way Back Home')
                  _buildLocationField(
                    context,
                    ref,
                    label: 'Pickup Location (School)',
                    icon: Icons.location_on,
                    iconColor: Colors.green,
                    hintText: 'School address',
                    currentLocation: bookingDraft.pickupLocationText,
                    onTap: () => _pickLocation(context, ref, isPickup: true),
                  ),

                if (bookingType == 'One Way Back Home')
                  const SizedBox(height: 20),

                // Dropoff Location (for Return Only)
                if (bookingType == 'One Way Back Home')
                  _buildLocationField(
                    context,
                    ref,
                    label: 'Dropoff Location (Home)',
                    icon: Icons.flag,
                    iconColor: Colors.red,
                    hintText: 'Your home address',
                    currentLocation: bookingDraft.dropoffLocationText,
                    onTap: () => _pickLocation(context, ref, isPickup: false),
                  ),

                // Helper text for school trips
                if (bookingDraft.tripCategory == 'school') ...[
                  const SizedBox(height: 16),
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
                            'Default locations will be used from child\'s profile if not specified',
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required IconData icon,
    required Color iconColor,
    required String hintText,
    required String? currentLocation,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: currentLocation != null && currentLocation.isNotEmpty
                    ? Colors.indigo.shade300
                    : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: currentLocation != null && currentLocation.isNotEmpty
                  ? Colors.indigo.shade50
                  : Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    currentLocation != null && currentLocation.isNotEmpty
                        ? currentLocation
                        : hintText,
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          currentLocation != null && currentLocation.isNotEmpty
                          ? Colors.black87
                          : Colors.grey.shade500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.edit_location_alt,
                  color: Colors.indigo.shade600,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickLocation(
    BuildContext context,
    WidgetRef ref, {
    required bool isPickup,
  }) async {
    // TODO: Integrate with your existing location picker
    // For now, show a placeholder dialog
    final controller = ref.read(bookingFlowControllerProvider.notifier);

    // Example integration - replace with actual location picker
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Location picker integration needed for ${isPickup ? 'pickup' : 'dropoff'}',
        ),
        action: SnackBarAction(
          label: 'Set Test Location',
          onPressed: () {
            // Set a test location
            if (isPickup) {
              controller.setPickupLocation(
                locationText: 'Test Pickup Address, Muscat',
                lat: 23.5880,
                lng: 58.3829,
              );
            } else {
              controller.setDropoffLocation(
                locationText: 'Test Dropoff Address, Muscat',
                lat: 23.6100,
                lng: 58.5400,
              );
            }
          },
        ),
      ),
    );
  }
}
