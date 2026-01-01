// lib/features/parent/find_driver/presentation/widgets/driver_ad_card.dart
import 'package:flutter/material.dart';
import '../../data/driver_ad_model.dart';

class DriverAdCard extends StatelessWidget {
  final DriverAdModel driver;

  const DriverAdCard({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: driver.photoUrl != null ? NetworkImage(driver.photoUrl!) : null,
                  child: driver.photoUrl == null ? Text(driver.name[0], style: const TextStyle(fontSize: 24)) : null,
                ),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(driver.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          if (driver.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 16, color: Colors.blue),
                          ]
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          Text(" ${driver.rating} (${driver.totalReviews})", style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("${driver.vehicleType} • ${driver.gender}", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${driver.priceMonthlyTwoWay.toInt()} OMR", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    const Text("mo/2-way", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
          const Divider(height: 1),
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    driver.bio.isNotEmpty ? driver.bio : "No description provided.",
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () { 
                    // Navigate to driver details (Feature to be implemented)
                  }, 
                  child: const Text("View Profile"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}