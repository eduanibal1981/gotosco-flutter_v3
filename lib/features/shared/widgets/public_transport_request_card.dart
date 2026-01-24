import 'package:flutter/material.dart';
import 'booking_details_view.dart';

class PublicTransportRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final bool showMessageButton;
  final VoidCallback? onDelete; // Added for parent view utility

  const PublicTransportRequestCard({
    super.key,
    required this.request,
    this.showMessageButton = true,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Basic Parsing for List Card Preview
    final childGender = request['child_gender'] as String?;
    // childAge removed, using grade
    final childGrade = request['child_grade'] as String?;

    // Privacy compliant name for card
    String displayChildName = 'Student';
    if (childGender != null && childGender.isNotEmpty) {
      displayChildName =
          childGender[0].toUpperCase() + childGender.substring(1);
    }

    final schoolName = request['school_name'] as String? ?? '';
    final bookingType = request['booking_type'] as String? ?? '';
    final homeLocation = request['hometxt_location'] as String? ?? '';
    final status = request['status'] as String? ?? 'open';
    final createdAt = request['created_at'] != null
        ? DateTime.tryParse(request['created_at'])
        : null;

    // Parent info for card header
    final parentName = request['parent_name'] as String? ?? 'Parent';
    final parentPhoto = request['parent_photo'] as String?;

    final statusColor = switch (status) {
      'open' => Colors.green,
      'closed' => Colors.blueGrey,
      'cancelled' => Colors.red,
      _ => Colors.grey,
    };

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDetailDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Parent Info & Status
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.teal.shade100,
                    backgroundImage: parentPhoto != null
                        ? NetworkImage(parentPhoto)
                        : null,
                    child: parentPhoto == null
                        ? Text(
                            parentName.isNotEmpty
                                ? parentName[0].toUpperCase()
                                : 'P',
                            style: TextStyle(
                              color: Colors.teal.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          bookingType,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Child Info (Masked)
              Row(
                children: [
                  Icon(
                    Icons.face_retouching_natural,
                    size: 20,
                    color: Colors.indigo.shade400,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$displayChildName${childGrade != null ? ' ($childGrade)' : ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              if (schoolName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.school, size: 18, color: Colors.grey.shade500),
                      const SizedBox(width: 10),
                      Text(
                        schoolName,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              if (homeLocation.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        homeLocation,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              if (createdAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Posted on ${_formatDate(createdAt)}',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context) {
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
            title: 'Transport Request',
            childName: request['child_name'] ?? 'Child',
            childGender: request['child_gender'],
            childGrade: request['child_grade'], // No DOB/Age for driver
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
            tripCategory: 'School Transport',
            bookingType: request['booking_type'] ?? '',
            locations: [
              if (request['hometxt_location'] != null)
                {'label': 'Pickup From', 'value': request['hometxt_location']},
              if (request['schooltxt_location'] != null)
                {'label': 'Dropoff To', 'value': request['schooltxt_location']},
            ],
            // Use same schedule description logic as Parent View or similar
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
            isDriverView: true, // Key: Enables privacy masking including name

            onClose: () => Navigator.pop(ctx),
            // Driver can't delete, but maybe Contact Parent logic can go here?
            // For now, simpler view.
          ),
        ),
      ),
    );
  }

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

    return 'See details in Notes below\nPosted: ${_formatDate(DateTime.parse(req['created_at'] ?? DateTime.now().toIso8601String()))}';
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
