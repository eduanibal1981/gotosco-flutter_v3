import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/booking_flow_controller.dart';
import '../../data/models/trip_categories.dart';

/// Step 2: Select trip category
class Step2TripCategory extends ConsumerWidget {
  const Step2TripCategory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingDraft = ref.watch(bookingFlowControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Trip Type',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What type of trip do you need?',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 32),

        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: TripCategories.all.length,
            itemBuilder: (context, index) {
              final category = TripCategories.all[index];
              final isSelected = bookingDraft.tripCategory == category.id;

              return InkWell(
                onTap: () {
                  ref
                      .read(bookingFlowControllerProvider.notifier)
                      .selectTripCategory(category.id);
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Text(category.icon, style: const TextStyle(fontSize: 56)),
                      const SizedBox(height: 12),

                      // Label
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          category.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.indigo.shade700
                                : Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Description (if available)
                      if (category.description != null) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            category.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],

                      // Selection indicator
                      if (isSelected) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade600,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ],
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
