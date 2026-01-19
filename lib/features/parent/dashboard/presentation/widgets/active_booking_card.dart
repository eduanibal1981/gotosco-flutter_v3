// lib/features/parent/dashboard/presentation/widgets/active_booking_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ActiveBookingCard extends StatelessWidget {
  final String driverName;
  final String? driverPhoto;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final bool isActive;
  final int? etaMinutes;
  final int? stopsUntilParent;
  final String? nextStopLabel;
  final VoidCallback onViewAll;
  final VoidCallback onTrack;

  const ActiveBookingCard({
    super.key,
    required this.driverName,
    this.driverPhoto,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.isActive,
    this.etaMinutes,
    this.stopsUntilParent,
    this.nextStopLabel,
    required this.onViewAll,
    required this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTrack,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 200,
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
                    child: CachedNetworkImage(
                      imageUrl:
                          'https://maps.googleapis.com/maps/api/staticmap?center=23.5880,58.3829&zoom=13&size=600x300&key=YOUR_API_KEY_HERE',
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          Container(color: Colors.grey.shade100),
                    ),
                  ),
                )
              else
                // Blue Gradient for Scheduled/Inactive
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
                        TextButton.icon(
                          onPressed: onViewAll,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey,
                          ),
                          label: const Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (etaMinutes != null || stopsUntilParent != null)
                      Row(
                        children: [
                          if (etaMinutes != null)
                            _buildInfoChip(
                              Icons.schedule,
                              '${etaMinutes!} min',
                            ),
                          if (etaMinutes != null && stopsUntilParent != null)
                            const SizedBox(width: 8),
                          if (stopsUntilParent != null)
                            _buildInfoChip(
                              Icons.format_list_numbered,
                              '${stopsUntilParent!} stops',
                            ),
                        ],
                      ),
                    if (nextStopLabel != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            nextStopLabel!,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
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
    ));
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            badgeText,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
