import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotosco_v3/features/parent/find_driver/data/drivers_repository.dart';

class FeaturedDrivers extends ConsumerWidget {
  const FeaturedDrivers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driversAsync = ref.watch(nearbyDriversProvider);

    return SizedBox(
      height: 160,
      child: driversAsync.when(
        data: (drivers) {
          if (drivers.isEmpty) {
            return const Center(child: Text("No drivers found nearby."));
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: drivers.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final driver = drivers[index];
              return _buildDriverCard(
                name: driver.name,
                rating: "${driver.rating}",
                area: "Muscat", // Default area for now
                isVerified:
                    true, // Assuming true for now, add field to model if needed
                color: Colors.blue.shade50, // You can randomize or derive this
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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
