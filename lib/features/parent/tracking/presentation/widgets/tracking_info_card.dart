import 'package:flutter/material.dart';

/// Information card displayed at the bottom of the tracking screen.
/// Shows driver details and ETA.
class TrackingInfoCard extends StatelessWidget {
  final String driverName;
  final String? driverPhotoUrl;
  final String? status;
  final String? eta;
  final VoidCallback? onCallPressed;
  final VoidCallback? onCancelPressed;

  const TrackingInfoCard({
    super.key,
    required this.driverName,
    this.driverPhotoUrl,
    this.status,
    this.eta,
    this.onCallPressed,
    this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Driver Info Row
          Row(
            children: [
              // Driver Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.indigo.shade100,
                backgroundImage: driverPhotoUrl != null
                    ? NetworkImage(driverPhotoUrl!)
                    : null,
                child: driverPhotoUrl == null
                    ? Icon(Icons.person, color: Colors.indigo.shade700)
                    : null,
              ),
              const SizedBox(width: 12),

              // Driver Name & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (status != null)
                      Text(
                        status!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),

              // ETA Badge
              if (eta != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        eta!,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              // Call Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCallPressed,
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Driver'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.indigo,
                    side: const BorderSide(color: Colors.indigo),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Cancel Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCancelPressed,
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    side: BorderSide(color: Colors.red.shade400),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
