import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/booking_flow_controller.dart';
import '../../application/booking_flow_data_providers.dart';

/// Step 1: Select child for booking
class Step1SelectChild extends ConsumerWidget {
  const Step1SelectChild({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(bookingFlowChildrenProvider);
    final bookingDraft = ref.watch(bookingFlowControllerProvider);
    final selectedIds = bookingDraft.studentIds;
    final isForParent = bookingDraft.isForParent;

    // Build subtitle text
    String subtitleText;
    if (isForParent) {
      subtitleText = 'Booking for yourself';
    } else if (selectedIds.isEmpty) {
      subtitleText = 'Choose yourself or children for this trip';
    } else {
      subtitleText =
          '${selectedIds.length} child${selectedIds.length > 1 ? "ren" : ""} selected';
    }

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
                    'Who is this trip for?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitleText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: (selectedIds.isEmpty && !isForParent)
                          ? Colors.grey.shade600
                          : Colors.indigo.shade700,
                      fontWeight: (selectedIds.isEmpty && !isForParent)
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (selectedIds.isNotEmpty || isForParent)
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
              // Build a list with "Myself" option first, then children
              return ListView(
                children: [
                  // "Myself (Parent)" option card
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () {
                        if (isForParent) {
                          // Already selected, deselect
                          ref
                              .read(bookingFlowControllerProvider.notifier)
                              .clearChildSelections();
                        } else {
                          // Select parent
                          ref
                              .read(bookingFlowControllerProvider.notifier)
                              .selectParentSelf();
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isForParent
                                ? Colors.indigo.shade500
                                : Colors.grey.shade200,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          color: isForParent
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
                                color: isForParent
                                    ? Colors.indigo.shade600
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isForParent
                                      ? Colors.indigo.shade600
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: isForParent
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            // Parent Avatar
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.teal.shade400,
                                    Colors.cyan.shade500,
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Parent Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Myself',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Book transport for yourself',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
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

                  // Divider with "or" label
                  if (children.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or select children',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                    ),

                  // Children list
                  ...children.map((child) {
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
                          await ref
                              .read(bookingFlowControllerProvider.notifier)
                              .autoPopulateLocationsForSelectedChildren();
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
                                      '${_calculateAge(child.dob)} years - Grade ${child.grade}',
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
                  }),
                ],
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
}
