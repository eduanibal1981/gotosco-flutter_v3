// lib/features/driver/bookings/presentation/widgets/booking_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gotosco_v3/features/driver/bookings/domain/models/booking_model.dart';
import 'package:gotosco_v3/features/driver/bookings/data/driver_bookings_repository.dart';
import 'package:gotosco_v3/features/driver/dashboard/presentation/driver_dashboard_screen.dart';

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
    final startDate = booking.startDate != null
        ? DateTime.tryParse(booking.startDate!)
        : null;
    final endDate = booking.endDate != null
        ? DateTime.tryParse(booking.endDate!)
        : null;
    final pauseUntil = booking.pauseEndDate != null
        ? DateTime.tryParse(booking.pauseEndDate!)
        : null;
    final scheduledStop = booking.contractEndDate != null
        ? DateTime.tryParse(booking.contractEndDate!)
        : null;

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
                  // Chat button
                  IconButton(
                    onPressed: () => context.push(
                      '/chat',
                      extra: {
                        'userId': booking.parentId,
                        'userName': booking.parentName ?? 'Parent',
                      },
                    ),
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.blue.shade400,
                      size: 20,
                    ),
                    tooltip: 'Chat with parent',
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
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
              const SizedBox(height: 12), // Adjusted spacing
              // Route Info (Enhanced Vertical Stepper)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.my_location,
                        size: 16,
                        color: Colors.indigo,
                      ), // Pickup
                      Container(
                        width: 2,
                        height: 12,
                        color: Colors.grey.shade300,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                      ),
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.teal,
                      ), // Dropoff
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.homeLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          booking.schoolLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Removed Date Range Schedule Block here as requested
              if (booking.isRecurring)
                Row(
                  children: [
                    const Icon(Icons.repeat, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.recurringDays.isNotEmpty
                            ? 'Recurring: ${booking.recurringDays.join(', ')}'
                            : 'Recurring schedule',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),

              if (booking.isRecurring) const SizedBox(height: 16),

              if (booking.subscriptionStatus == 'paused')
                _buildNoticeRow(
                  Icons.pause_circle_filled,
                  pauseUntil != null
                      ? 'Paused until ${dateFormatter.format(pauseUntil)}'
                      : 'Paused',
                  Colors.orange,
                ),
              if (booking.contractEndDate != null)
                _buildNoticeRow(
                  Icons.event_busy,
                  scheduledStop != null
                      ? 'Scheduled stop on ${dateFormatter.format(scheduledStop)}'
                      : 'Scheduled stop set',
                  Colors.orange,
                ),
              if (booking.cancellationType != null &&
                  (booking.status == 'accepted' ||
                      booking.status == 'confirmed') &&
                  booking.subscriptionStatus != 'paused' &&
                  booking.contractEndDate == null)
                _buildNoticeRow(
                  Icons.info_outline,
                  'Cancellation requested',
                  Colors.redAccent,
                ),

              if (booking.status == 'accepted' || booking.status == 'confirmed')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref
                              .read(driverDashboardIndexProvider.notifier)
                              .setIndex(3);
                        },
                        icon: const Icon(Icons.route, size: 18),
                        label: const Text('Open Trips'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal,
                          side: BorderSide(color: Colors.teal.shade300),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ),

              if (booking.status == 'accepted' || booking.status == 'confirmed')
                const SizedBox(height: 12),

              // Action Buttons
              if (isPending) _BookingActions(booking: booking),

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
      case 'confirmed':
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

  Widget _buildNoticeRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: color, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // Helper _formatDateRange removed or kept if used elsewhere?
  // It was only used in the removed block. I can remove it or keep it as utility.
  // I will keep it commented out or remove it to be clean.
}

class _BookingActions extends ConsumerStatefulWidget {
  final BookingModel booking;

  const _BookingActions({required this.booking});

  @override
  ConsumerState<_BookingActions> createState() => _BookingActionsState();
}

class _BookingActionsState extends ConsumerState<_BookingActions> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else ...[
          OutlinedButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              try {
                await ref
                    .read(driverBookingsRepositoryProvider)
                    .rejectBooking(widget.booking.id);
                ref.invalidate(driverBookingsProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking rejected'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
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
              setState(() => _isLoading = true);
              try {
                await ref
                    .read(driverBookingsRepositoryProvider)
                    .acceptBooking(widget.booking.id);
                ref.invalidate(driverBookingsProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking accepted!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Accept'),
          ),
        ],
      ],
    );
  }
}

