// lib/features/parent/dashboard/presentation/widgets/transport_request_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../bookings/data/bookings_repository.dart';
import '../../../../shared/widgets/booking_details_view.dart';

class TransportRequestCard extends ConsumerWidget {
  const TransportRequestCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch my bookings, then filter for ads (driver_id is null OR status is posted)
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade500, Colors.indigo.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: bookingsAsync.when(
        data: (bookings) {
          // Filter for Advertised Requests (Open)
          final requests = bookings
              .where((b) => b['status'] == 'posted' || b['driver_id'] == null)
              .toList();

          if (requests.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildRequestsList(context, ref, requests);
        },
        loading: () => _buildLoadingState(),
        error: (err, _) => _buildErrorState(err.toString()),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Need specific transport?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Post a request and let drivers contact you with offers.",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Tip: add the price you want in the notes.",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/transport-request');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.post_add, size: 18),
                label: const Text("Add Request"),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _buildDecorIcon(),
      ],
    );
  }

  Widget _buildRequestsList(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> requests,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Requests",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Add another request if you need more routes.",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildRequestTile(context, ref, request);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/transport-request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add Another"),
              ),
            ),
            const SizedBox(width: 12),
            _buildDecorIcon(),
          ],
        ),
      ],
    );
  }

  Widget _buildRequestTile(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> request,
  ) {
    // Privacy: Mask Child Name in list too
    String displayChildName = 'Student';
    final childGender = request['child_gender'] as String?;
    final childGrade = request['child_grade'] as String?;
    final schoolName = request['school_name'] as String? ?? 'School';
    final status = request['status'] as String? ?? 'open';

    if (childGender != null && childGender.isNotEmpty) {
      displayChildName = childGender;
      if (displayChildName.isNotEmpty) {
        displayChildName =
            displayChildName[0].toUpperCase() + displayChildName.substring(1);
      }
    }

    return InkWell(
      onTap: () => _showDetailDialog(context, ref, request),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$displayChildName${childGrade != null ? ' ($childGrade)' : ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    schoolName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusChip(status),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> request,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: BookingDetailsView(
            title: 'Review Advertise Request',
            childName: request['child_name'] ?? 'Child',
            childGender: request['child_gender'],
            childGrade: request['child_grade'],
            children: request['students_info'] != null
                ? List.from(
                    request['students_info'],
                  ).cast<Map<String, dynamic>>()
                : null,
            schools: request['schools_info'] != null
                ? List.from(
                    request['schools_info'],
                  ).cast<Map<String, dynamic>>()
                : null,
            tripCategory: request['trip_category'] == 'school'
                ? 'School Transport'
                : 'Journey/Other', // Basic derivation
            bookingType: request['booking_type'] ?? '',

            locations: [
              if (request['hometxt_location'] != null)
                {
                  'label': 'Pickup From',
                  'value': request['hometxt_location'],
                  'lat': request['home_lat'],
                  'lng': request['home_lng'],
                },
              if (request['schooltxt_location'] != null)
                {
                  'label': 'Dropoff To',
                  'value': request['schooltxt_location'],
                  'lat': request['school_lat'],
                  'lng': request['school_lng'],
                },
            ],
            scheduleType:
                request['schedule_type'] ??
                request['booking_type'] ??
                'Request',
            scheduleDescription: _formatScheduleDescription(request),
            price: request['propsal_price'] != null
                ? double.tryParse(request['propsal_price'].toString())
                : null,
            notes: request['notes'],

            isPublicRequest: true,
            isEditable: false,
            isDriverView: false, // Parent viewing own ad

            onClose: () => Navigator.pop(ctx),
            onDelete: () => _handleDelete(ctx, ref, request['id']),
          ),
        ),
      ),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Delete request?'),
        content: const Text(
          'This will remove the request from the marketplace.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (context.mounted) Navigator.pop(context); // Close detail dialog
      try {
        await ref.read(bookingsRepositoryProvider).deleteBooking(id);
        // ref.invalidate(myBookingsProvider); // Stream auto-updates
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Widget _buildStatusChip(String status) {
    final label = status.toUpperCase();
    final color = status == 'open'
        ? Colors.green
        : status == 'closed'
        ? Colors.orange
        : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDecorIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.campaign_outlined, color: Colors.white, size: 32),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 80,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Text('Error: $message', style: const TextStyle(color: Colors.white));
  }

  // _confirmDelete method removed as logic moved to dialog
  String _formatScheduleDescription(Map<String, dynamic> req) {
    if (req['schedule_type'] == 'One-Time Trip') {
      final date = req['start_date'] != null
          ? DateTime.parse(req['start_date'])
          : null;
      return date != null ? _formatDate(date) : '';
    }
    if (req['schedule_type'] == 'Recurring Trip') {
      return '${req['days_of_week'] ?? ""}\nPickup: ${req['pickup_time'] ?? ""}';
    }
    if (req['schedule_type'] == 'Monthly Subscription') {
      String desc = '';
      if (req['start_date'] != null) {
        final start = DateTime.parse(req['start_date']);
        desc = '${_formatDate(start)}';
        if (req['end_date'] != null) {
          final end = DateTime.parse(req['end_date']);
          desc += ' - ${_formatDate(end)}';
        }
      }
      if (req['pickup_time'] != null) {
        desc += '\nDaily Pickup: ${req['pickup_time']}';
      }
      if (desc.isNotEmpty) return desc;
    }

    // Fallback if new columns are empty (old data or just failed)
    return 'See details in Notes below\nPosted: ${_formatDate(DateTime.parse(req['created_at']))}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
