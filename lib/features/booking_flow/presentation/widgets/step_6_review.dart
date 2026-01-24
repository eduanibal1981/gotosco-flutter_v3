import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/booking_flow_controller.dart';
import '../../../shared/widgets/booking_details_view.dart';
import '../../../parent/children/data/children_repository.dart';
import '../../../parent/children/data/child_model.dart';

/// Step 6: Review booking details before submission
class Step6Review extends ConsumerWidget {
  const Step6Review({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingDraft = ref.watch(bookingFlowControllerProvider);
    final childrenAsync = ref.watch(myChildrenProvider);

    // Resolve Child Name
    final childDisplay = _resolveChildName(bookingDraft, childrenAsync);
    // Resolve Child Details (Age/Gender)
    final childDetails = _resolveChildDetails(bookingDraft, childrenAsync);

    // Format Locations
    final locations = _formatLocations(bookingDraft);

    // Format Schedule
    final schedule = _formatSchedule(bookingDraft);

    return BookingDetailsView(
      title: bookingDraft.isPublicRequest
          ? 'Review Advertise Request'
          : 'Review Booking',
      childName: childDisplay,
      childGender: childDetails['gender'],
      childGrade: childDetails['grade'] as String?,
      tripCategory: _formatTripCategory(bookingDraft.tripCategory),
      bookingType: bookingDraft.bookingType ?? 'Not selected',
      locations: locations,
      scheduleType: schedule['type']!,
      scheduleDescription: schedule['desc']!,
      price: bookingDraft.estimatedPrice,
      notes: bookingDraft.notes,

      // Mode Props
      isPublicRequest: bookingDraft.isPublicRequest,
      isEditable: true,

      // Callbacks
      onPriceChanged: (val) {
        ref.read(bookingFlowControllerProvider.notifier).setEstimatedPrice(val);
      },
      onNotesChanged: (val) {
        ref.read(bookingFlowControllerProvider.notifier).setNotes(val);
      },
    );
  }

  String _resolveChildName(
    dynamic bookingDraft,
    AsyncValue<List<dynamic>> childrenAsync,
  ) {
    if (bookingDraft.studentIds.isNotEmpty && childrenAsync.hasValue) {
      final names = bookingDraft.studentIds.map((id) {
        final child = childrenAsync.value!.cast<ChildModel?>().firstWhere(
          (c) => c?.id == id,
          orElse: () => null,
        );
        return child?.name ?? 'Unknown';
      }).toList();
      return names.join(', ');
    }
    return bookingDraft.studentId ?? 'Not selected';
  }

  Map<String, dynamic> _resolveChildDetails(
    dynamic bookingDraft,
    AsyncValue<dynamic> childrenAsync,
  ) {
    if (bookingDraft.studentIds.isNotEmpty && childrenAsync.hasValue) {
      // Just take first child for gender/age representative if multiple
      final childId = bookingDraft.studentIds.first;
      final child = childrenAsync.value!.cast<ChildModel?>().firstWhere(
        (c) => c?.id == childId,
        orElse: () => null,
      );
      if (child != null) {
        return {'gender': child.gender, 'grade': child.grade};
      }
    }
    return {};
  }

  List<Map<String, String>> _formatLocations(dynamic bookingDraft) {
    final list = <Map<String, String>>[];

    if (bookingDraft.isMultiSchool) {
      if (bookingDraft.pickupLocationText != null &&
          bookingDraft.bookingType != 'One Way Back Home') {
        list.add({
          'label': 'Pickup (Home)',
          'value': bookingDraft.pickupLocationText!,
        });
      }
      if (bookingDraft.bookingType != 'One Way Back Home') {
        for (var s in bookingDraft.schoolLocations) {
          list.add({'label': 'Dropoff (School)', 'value': s.schoolName});
        }
      }
      if (bookingDraft.bookingType == 'One Way Back Home') {
        for (var s in bookingDraft.schoolLocations) {
          list.add({'label': 'Pickup (School)', 'value': s.schoolName});
        }
        if (bookingDraft.dropoffLocationText != null) {
          list.add({
            'label': 'Dropoff (Home)',
            'value': bookingDraft.dropoffLocationText!,
          });
        }
      }
    } else {
      if (bookingDraft.pickupLocationText != null) {
        list.add({
          'label': 'Pickup',
          'value': bookingDraft.pickupLocationText!,
        });
      }
      if (bookingDraft.dropoffLocationText != null) {
        list.add({
          'label': 'Dropoff',
          'value': bookingDraft.dropoffLocationText!,
        });
      }
    }
    return list;
  }

  Map<String, String> _formatSchedule(dynamic bookingDraft) {
    String type = 'Not selected';
    String desc = '';

    if (bookingDraft.isOneTime) {
      type = 'One-Time Trip';
      if (bookingDraft.scheduledPickupDatetime != null) {
        desc = DateFormat(
          'MMM dd, yyyy - hh:mm a',
        ).format(bookingDraft.scheduledPickupDatetime!);
      }
    } else if (bookingDraft.isRecurring) {
      type = 'Recurring Trip';
      desc =
          '${bookingDraft.recurringDays?.join(", ") ?? ""} \nPickup: ${bookingDraft.homePickupTime ?? ""}';
    } else if (bookingDraft.isMonthlySubscription) {
      type = 'Monthly Subscription';
      if (bookingDraft.contractStartDate != null) {
        desc =
            '${DateFormat('MMM dd').format(bookingDraft.contractStartDate!)} - ${DateFormat('MMM dd, yyyy').format(bookingDraft.contractEndDate!)}\nDaily pickup: ${bookingDraft.homePickupTime ?? 'Not set'}';
      }
    }
    return {'type': type, 'desc': desc};
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
