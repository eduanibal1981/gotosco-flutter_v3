// lib/features/parent/dashboard/presentation/widgets/active_booking_card.dart
import 'package:flutter/material.dart';

class ActiveBookingCard extends StatelessWidget {
  final String driverName;
  final String? driverPhoto;
  final String status; // 'active' or 'accepted'
  final VoidCallback onViewAll;
  final VoidCallback onTrack;

  const ActiveBookingCard({
    super.key,
    required this.driverName,
    this.driverPhoto,
    required this.status,
    required this.onViewAll,
    required this.onTrack,
  });

  bool get isActive => status == 'active';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTrack,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. Map Placeholder (Only if Active)
              if (isActive)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.network(
                      'https://maps.googleapis.com/maps/api/staticmap?center=23.5880,58.3829&zoom=13&size=600x300&key=YOUR_API_KEY_HERE',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey.shade100),
                    ),
                  ),
                )
              else
                // Blue Gradient for Scheduled
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

              // 2. Status Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatusBadge(),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      isActive ? 'Arriving at Home' : 'Scheduled Trip',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isActive ? '5 min away' : 'Driver Offline',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.directions_bus,
                          size: 16,
                          color: isActive
                              ? Colors.indigo.shade700
                              : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Driver: $driverName',
                          style: TextStyle(
                            color: isActive
                                ? Colors.indigo.shade700
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = isActive ? Colors.green : Colors.blue;
    final text = isActive ? 'LIVE TRIP' : 'SCHEDULED';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
