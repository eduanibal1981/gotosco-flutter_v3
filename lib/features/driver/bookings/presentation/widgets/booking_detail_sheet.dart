// lib/features/driver/bookings/presentation/widgets/booking_detail_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotosco_v3/features/driver/bookings/data/booking_model.dart';
import 'package:gotosco_v3/features/driver/bookings/data/driver_bookings_repository.dart';
import 'package:gotosco_v3/features/driver/dashboard/presentation/driver_dashboard_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BookingDetailSheet extends ConsumerWidget {
  final BookingModel booking;

  const BookingDetailSheet({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Booking Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (booking.status == 'pending')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Pending',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Parent Section
            _buildSectionTitle('Parent Information'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundImage: booking.parentPhoto != null
                    ? NetworkImage(booking.parentPhoto!)
                    : null,
                child: booking.parentPhoto == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(booking.parentName ?? 'Unknown'),
              subtitle: Text(booking.parentPhone ?? 'No phone'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      context.push(
                        '/chat',
                        extra: {
                          'userId': booking.parentId,
                          'userName': booking.parentName ?? 'Parent',
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, color: Colors.green),
                    onPressed: () {
                      if (booking.parentPhone != null) {
                        launchUrl(Uri.parse('tel:${booking.parentPhone}'));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No phone number available'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Route Section
            _buildSectionTitle('Route Information'),
            _buildInfoRow(
              Icons.home,
              'Pickup Location',
              booking.homeLocation,
              lat: booking.homeLat,
              lng: booking.homeLng,
            ),
            const SizedBox(height: 12),
            // Build Multiple School Rows if available, else single
            if (booking.schoolIds != null && booking.schoolIds!.isNotEmpty)
              // This requires fetching details for each school ID if not joined.
              // For now, rely on repo to populate schoolLocation combined?
              // Or better, BookingModel should list schools.
              // Returning to single row for now as Model supports single Strings.
              // Ideally we iterate. Let's stick to the singlular for now but robust.
              _buildInfoRow(
                Icons.school,
                'School Location',
                booking.schoolLocation,
                lat: booking.schoolLat,
                lng: booking.schoolLng,
              )
            else
              _buildInfoRow(
                Icons.school,
                'School Location',
                booking.schoolLocation,
                lat: booking.schoolLat,
                lng: booking.schoolLng,
              ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.payments,
              'Price',
              // Use price if > 0, else proposalPrice, else 'Negotiable'
              (booking.price > 0)
                  ? '${booking.price} SAR'
                  : (booking.proposalPrice != null &&
                        booking.proposalPrice! > 0)
                  ? '${booking.proposalPrice} SAR'
                  : 'Negotiable',
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Children Section
            _buildSectionTitle('Children (${booking.children.length})'),
            ...booking.children.map(
              (child) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.child_care, color: Colors.blueGrey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${child.schoolName} • ${child.grade}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            if (booking.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await ref
                            .read(driverBookingsRepositoryProvider)
                            .rejectBooking(booking.id);
                        // Refresh provider handled by screen via invalidate
                        ref.invalidate(driverBookingsProvider);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Reject Request'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await ref
                            .read(driverBookingsRepositoryProvider)
                            .acceptBooking(booking.id);
                        ref.invalidate(driverBookingsProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Accept Request'),
                    ),
                  ),
                ],
              ),

            if (booking.status == 'accepted' ||
                booking.status == 'confirmed') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ref
                            .read(driverDashboardIndexProvider.notifier)
                            .setIndex(3);
                      },
                      icon: const Icon(Icons.route),
                      label: const Text('Open Trips'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.teal,
                        side: BorderSide(color: Colors.teal.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push(
                          '/chat',
                          extra: {
                            'userId': booking.parentId,
                            'userName': booking.parentName ?? 'Parent',
                          },
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Message'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Use the Trips tab to mark pickup and drop-off for each stop.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],

            if (booking.status == 'rejected' || booking.isExpired)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await ref
                        .read(driverBookingsRepositoryProvider)
                        .deleteBooking(booking.id);
                    ref.invalidate(driverBookingsProvider);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Delete Booking',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    double? lat,
    double? lng,
  }) {
    final hasCoordinates = lat != null && lng != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            if (hasCoordinates)
              IconButton(
                icon: const Icon(Icons.open_in_new, color: Colors.blue),
                tooltip: 'Open in Maps',
                onPressed: () => _openMap(lat, lng),
              ),
          ],
        ),
        if (hasCoordinates) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _openMap(lat, lng),
            child: Container(
              height: 150,
              width: double.infinity,
              margin: const EdgeInsets.only(left: 32), // Align with text
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(lat, lng),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.gotosco.v3',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(lat, lng),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.open_in_new,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openMap(dynamic lat, dynamic lng) async {
    if (lat == null || lng == null) return;
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
