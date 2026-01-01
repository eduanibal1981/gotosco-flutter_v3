// lib/features/parent/dashboard/presentation/widgets/featured_drivers.dart
import 'package:flutter/material.dart';

class FeaturedDrivers extends StatelessWidget {
  const FeaturedDrivers({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildDriverCard(
            name: "Salim Al-Harthi",
            rating: "4.9",
            area: "Al Seeb",
            isVerified: true,
            color: Colors.blue.shade50,
          ),
          const SizedBox(width: 12),
          _buildDriverCard(
            name: "Noor Transport",
            rating: "4.8",
            area: "Bawshar",
            isVerified: true,
            color: Colors.orange.shade50,
          ),
          const SizedBox(width: 12),
          _buildDriverCard(
            name: "Safe Kids Bus",
            rating: "5.0",
            area: "Muscat",
            isVerified: false,
            color: Colors.purple.shade50,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard({
    required String name,
    required String rating,
    required String area,
    required bool isVerified,
    required Color color,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 16,
                child: Text(name[0]),
              ),
              const Spacer(),
              const Icon(Icons.star, size: 14, color: Colors.amber),
              Text(
                rating,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (isVerified)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "Verified",
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            area,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
