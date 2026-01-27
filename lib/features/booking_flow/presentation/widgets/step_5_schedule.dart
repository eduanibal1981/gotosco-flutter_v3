import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/booking_flow_controller.dart';

/// Step 5: Choose schedule type and set times
class Step5Schedule extends ConsumerStatefulWidget {
  const Step5Schedule({super.key});

  @override
  ConsumerState<Step5Schedule> createState() => _Step5ScheduleState();
}

class _Step5ScheduleState extends ConsumerState<Step5Schedule> {
  final List<Map<String, String>> _scheduleTypes = const [
    {
      'id': 'one_time',
      'label': 'One-Time Trip',
      'desc': 'Single journey on a specific date',
      'icon': '📅',
    },
    {
      'id': 'recurring',
      'label': 'Recurring Trip',
      'desc': 'Repeat on selected days of the week',
      'icon': '🔄',
    },
    {
      'id': 'monthly',
      'label': 'Monthly Subscription',
      'desc': 'Contract with driver for the month',
      'icon': '📆',
    },
  ];

  final List<String> _weekDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  @override
  void initState() {
    super.initState();
    // Set default contract dates (August to May) on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(bookingFlowControllerProvider.notifier)
          .setDefaultContractDates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingDraft = ref.watch(bookingFlowControllerProvider);

    String? selectedScheduleType;
    if (bookingDraft.isOneTime) {
      selectedScheduleType = 'one_time';
    } else if (bookingDraft.isRecurring) {
      selectedScheduleType = 'recurring';
    } else if (bookingDraft.isMonthlySubscription) {
      selectedScheduleType = 'monthly';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Schedule',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Monthly subscription from August to May',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Schedule Type Selection
                ..._scheduleTypes.map((scheduleType) {
                  final isSelected = selectedScheduleType == scheduleType['id'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () => _selectScheduleType(scheduleType['id']!),
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
                            // Icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.indigo.shade100
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  scheduleType['icon']!,
                                  style: const TextStyle(fontSize: 24),
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
                                    scheduleType['label']!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.indigo.shade700
                                          : Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    scheduleType['desc']!,
                                    style: TextStyle(
                                      fontSize: 13,
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
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // Schedule Details based on selection
                if (selectedScheduleType != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: _buildScheduleDetails(
                      selectedScheduleType,
                      bookingDraft,
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

  Widget _buildScheduleDetails(String scheduleType, dynamic bookingDraft) {
    switch (scheduleType) {
      case 'one_time':
        return _buildOneTimeSchedule(bookingDraft);
      case 'recurring':
        return _buildRecurringSchedule(bookingDraft);
      case 'monthly':
        return _buildMonthlySubscription(bookingDraft);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOneTimeSchedule(dynamic bookingDraft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date & Time',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Date Picker
        InkWell(
          onTap: () => _pickDateTime(isPickup: true),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.indigo.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    bookingDraft.scheduledPickupDatetime != null
                        ? DateFormat(
                            'MMM dd, yyyy - hh:mm a',
                          ).format(bookingDraft.scheduledPickupDatetime!)
                        : 'Select pickup date & time',
                    style: TextStyle(
                      fontSize: 15,
                      color: bookingDraft.scheduledPickupDatetime != null
                          ? Colors.black87
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecurringSchedule(dynamic bookingDraft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Days of Week',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Days selector
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _weekDays.map((day) {
            final isSelected =
                bookingDraft.recurringDays?.contains(day) ?? false;
            return FilterChip(
              label: Text(
                day[0].toUpperCase() + day.substring(1, 3),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) => _toggleDay(day, selected),
              selectedColor: Colors.indigo.shade600,
              checkmarkColor: Colors.white,
              backgroundColor: Colors.grey.shade200,
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        if (bookingDraft.bookingType != 'One Way Back Home') ...[
          // Pickup Time
          const Text(
            'Go Pickup Time (Morning)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _pickTime(isPickup: true),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Icon(Icons.wb_sunny_outlined, color: Colors.orange.shade600),
                  const SizedBox(width: 12),
                  Text(
                    bookingDraft.homePickupTime ?? 'Select morning pickup time',
                    style: TextStyle(
                      fontSize: 15,
                      color: bookingDraft.homePickupTime != null
                          ? Colors.black87
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        if (bookingDraft.bookingType != 'One Way to School') ...[
          const SizedBox(height: 12),

          // Return Pickup Time
          const Text(
            'Return Pickup Time (Afternoon)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _pickTime(isPickup: false),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.nights_stay_outlined,
                    color: Colors.indigo.shade600,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    bookingDraft.schoolPickupTime ??
                        'Select afternoon pickup time',
                    style: TextStyle(
                      fontSize: 15,
                      color: bookingDraft.schoolPickupTime != null
                          ? Colors.black87
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMonthlySubscription(dynamic bookingDraft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contract Period (August - May)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Start Date
        InkWell(
          onTap: () => _pickContractDate(isStart: true),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.green.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    bookingDraft.contractStartDate != null
                        ? 'Start: ${DateFormat('MMM dd, yyyy').format(bookingDraft.contractStartDate!)}'
                        : 'Select start date',
                    style: TextStyle(
                      fontSize: 15,
                      color: bookingDraft.contractStartDate != null
                          ? Colors.black87
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // End Date
        InkWell(
          onTap: () => _pickContractDate(isStart: false),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.red.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    bookingDraft.contractEndDate != null
                        ? 'End: ${DateFormat('MMM dd, yyyy').format(bookingDraft.contractEndDate!)}'
                        : 'Select end date',
                    style: TextStyle(
                      fontSize: 15,
                      color: bookingDraft.contractEndDate != null
                          ? Colors.black87
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        if (bookingDraft.bookingType != 'One Way Back Home') ...[
          // Go Pickup Time (Morning)
          const Text(
            'Go Pickup Time (Morning)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _pickTime(isPickup: true),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Icon(Icons.wb_sunny_outlined, color: Colors.orange.shade600),
                  const SizedBox(width: 12),
                  Text(
                    bookingDraft.homePickupTime ?? 'Select morning pickup time',
                    style: TextStyle(
                      fontSize: 15,
                      color: bookingDraft.homePickupTime != null
                          ? Colors.black87
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        if (bookingDraft.bookingType != 'One Way to School') ...[
          const SizedBox(height: 12),

          // Return Pickup Time (Afternoon)
          const Text(
            'Return Pickup Time (Afternoon)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _pickTime(isPickup: false),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.nights_stay_outlined,
                    color: Colors.indigo.shade600,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    bookingDraft.schoolPickupTime ??
                        'Select afternoon pickup time',
                    style: TextStyle(
                      fontSize: 15,
                      color: bookingDraft.schoolPickupTime != null
                          ? Colors.black87
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _selectScheduleType(String type) {
    final controller = ref.read(bookingFlowControllerProvider.notifier);
    controller.selectScheduleType(
      isOneTime: type == 'one_time',
      isRecurring: type == 'recurring',
      isMonthlySubscription: type == 'monthly',
    );
  }

  Future<void> _pickDateTime({required bool isPickup}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null && mounted) {
        final dateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        ref
            .read(bookingFlowControllerProvider.notifier)
            .setOneTimeSchedule(pickupDatetime: dateTime);
      }
    }
  }

  Future<void> _pickTime({required bool isPickup}) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && mounted) {
      // Store in 24-hour format (HH:mm) for reliable parsing
      final timeString =
          '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      final bookingDraft = ref.read(bookingFlowControllerProvider);

      if (bookingDraft.isRecurring) {
        ref
            .read(bookingFlowControllerProvider.notifier)
            .setRecurringSchedule(
              recurringDays: bookingDraft.recurringDays ?? [],
              pickupTime: isPickup ? timeString : bookingDraft.homePickupTime,
              dropoffTime: !isPickup
                  ? timeString
                  : bookingDraft.schoolPickupTime,
            );
      } else if (bookingDraft.isMonthlySubscription) {
        if (bookingDraft.contractStartDate != null &&
            bookingDraft.contractEndDate != null) {
          // For monthly subscription, handle both morning and afternoon times
          ref
              .read(bookingFlowControllerProvider.notifier)
              .setMonthlySubscription(
                contractStartDate: bookingDraft.contractStartDate!,
                contractEndDate: bookingDraft.contractEndDate!,
                pickupTime: isPickup ? timeString : bookingDraft.homePickupTime,
                dropoffTime: !isPickup
                    ? timeString
                    : bookingDraft.schoolPickupTime,
              );
        }
      }
    }
  }

  Future<void> _pickContractDate({required bool isStart}) async {
    final bookingDraft = ref.read(bookingFlowControllerProvider);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart
          ? DateTime.now()
          : (bookingDraft.contractStartDate ?? DateTime.now()).add(
              const Duration(days: 30),
            ),
      firstDate: isStart
          ? DateTime.now()
          : (bookingDraft.contractStartDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      if (isStart) {
        // Set start date
        final endDate =
            bookingDraft.contractEndDate ??
            pickedDate.add(const Duration(days: 30));
        ref
            .read(bookingFlowControllerProvider.notifier)
            .setMonthlySubscription(
              contractStartDate: pickedDate,
              contractEndDate: endDate,
              pickupTime: bookingDraft.homePickupTime,
              dropoffTime: bookingDraft.schoolPickupTime,
            );
      } else {
        // Set end date
        if (bookingDraft.contractStartDate != null) {
          ref
              .read(bookingFlowControllerProvider.notifier)
              .setMonthlySubscription(
                contractStartDate: bookingDraft.contractStartDate!,
                contractEndDate: pickedDate,
                pickupTime: bookingDraft.homePickupTime,
                dropoffTime: bookingDraft.schoolPickupTime,
              );
        }
      }
    }
  }

  void _toggleDay(String day, bool selected) {
    final bookingDraft = ref.read(bookingFlowControllerProvider);
    final currentDays = List<String>.from(bookingDraft.recurringDays ?? []);

    if (selected) {
      currentDays.add(day);
    } else {
      currentDays.remove(day);
    }

    ref
        .read(bookingFlowControllerProvider.notifier)
        .setRecurringSchedule(
          recurringDays: currentDays,
          pickupTime: bookingDraft.homePickupTime,
          dropoffTime: bookingDraft.schoolPickupTime,
        );
  }
}
