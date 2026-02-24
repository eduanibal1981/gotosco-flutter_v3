import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/booking_flow_controller.dart';

/// Step 3: Select direction (two-way, one-way, etc.)
class Step3Direction extends ConsumerWidget {
  const Step3Direction({super.key});

  static const List<Map<String, String>> directions = [
    {
      'id': 'Two Way',
      'label': 'Go & Return',
      'desc': 'Pickup and dropoff service',
      'icon': 'ðŸ”„',
    },
    {
      'id': 'One Way to School',
      'label': 'Go Only',
      'desc': 'One way to destination',
      'icon': 'âž¡ï¸',
    },
    {
      'id': 'One Way Back Home',
      'label': 'Return Only',
      'desc': 'One way back home',
      'icon': 'â¬…ï¸',
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingDraft = ref.watch(bookingFlowControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Direction',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the trip direction',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),

        Expanded(
          child: ListView.builder(
            itemCount: directions.length,
            itemBuilder: (context, index) {
              final direction = directions[index];
              final isSelected = bookingDraft.bookingType == direction['id'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () {
                    ref
                        .read(bookingFlowControllerProvider.notifier)
                        .selectDirection(direction['id']!);
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
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.indigo.shade100
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              direction['icon']!,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                direction['label']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.indigo.shade700
                                      : Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                direction['desc']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Selection indicator
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade600,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
