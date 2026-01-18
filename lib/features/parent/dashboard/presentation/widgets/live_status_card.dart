// lib/features/parent/dashboard/presentation/widgets/live_status_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class LiveStatusCard extends StatelessWidget {
  const LiveStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    // In the future, wrap this with StreamBuilder for real-time updates
    return Container(
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
            // 1. Map Placeholder (Use a static image for performance until active)
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CachedNetworkImage(
                  imageUrl:
                      'https://maps.googleapis.com/maps/api/staticmap?center=23.5880,58.3829&zoom=13&size=600x300&key=YOUR_API_KEY_HERE',
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      Container(color: Colors.grey.shade200),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'LIVE TRIP',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    'Arriving at Home',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '5 min away',
                    style: TextStyle(
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
                        color: Colors.indigo.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Driver: Ahmed (Bus #402)',
                        style: TextStyle(
                          color: Colors.indigo.shade700,
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
    );
  }
}
