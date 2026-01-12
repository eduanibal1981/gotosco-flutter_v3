// lib/features/driver/bookings/presentation/widgets/booking_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gotosco_v3/features/driver/bookings/data/booking_model.dart';
import 'package:gotosco_v3/features/driver/bookings/data/driver_bookings_repository.dart';

class BookingCard extends ConsumerWidget {
  final BookingModel booking;
  final bool isPending;
  final bool canDelete;
  final VoidCallback onTap;

  const BookingCard({
    super.key,
    required this.booking,
    this.isPending = false,
    this.canDelete = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormatter = DateFormat('MMM d, yyyy');
    final createdDate = DateTime.tryParse(booking.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Parent Name and Date
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: booking.parentPhoto != null
                        ? NetworkImage(booking.parentPhoto!)
                        : null,
                    radius: 20,
                    child: booking.parentPhoto == null
                        ? Text(booking.parentName?[0].toUpperCase() ?? 'P')
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.parentName ?? 'Unknown Parent',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          createdDate != null
                              ? dateFormatter.format(createdDate)
                              : '',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(booking.status),
                ],
              ),
              const SizedBox(height: 12),

              // Children Info
              Row(
                children: [
                  const Icon(Icons.child_care, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${booking.children.length} Children: ${booking.children.map((c) => c.name).take(2).join(", ")}${booking.children.length > 2 ? "..." : ""}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Route Info (Simplified)
              Row(
                children: [
                  const Icon(Icons.route, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pickup: ${booking.homeLocation}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action Buttons
              if (isPending)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        await ref
                            .read(driverBookingsRepositoryProvider)
                            .rejectBooking(booking.id);
                        ref.invalidate(driverBookingsProvider);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(driverBookingsRepositoryProvider)
                            .acceptBooking(booking.id);
                        ref.invalidate(driverBookingsProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Accept'),
                    ),
                  ],
                ),

              if (canDelete)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Show 'Expired' label if expired
                    if (booking.isExpired)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          'EXPIRED',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Booking?'),
                            content: const Text(
                              'Are you sure you want to delete this booking? This cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await ref
                              .read(driverBookingsRepositoryProvider)
                              .deleteBooking(booking.id);
                          ref.invalidate(driverBookingsProvider);
                        }
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.grey,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'accepted':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
