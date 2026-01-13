// lib/features/parent/find_driver/presentation/widgets/driver_ad_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <--- Import Riverpod
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/driver_ad_model.dart';
import '../providers/favorites_provider.dart'; // <--- Import the new provider

class DriverAdCard extends ConsumerWidget {
  final DriverAdModel driver;

  const DriverAdCard({super.key, required this.driver});
  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    // 1. Prepare the URI with 'tel' scheme
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

    // 2. Check and Launch
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        // Fallback if simulator or no dialer
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch dialer')),
          );
        }
      }
    } catch (e) {
      print("Error launching call: $e");
    }
  }

  void _startChat(BuildContext context) {
    // Navigate to the Chat Screen.
    // We pass the driver's ID and name as 'extra' data so the Chat Screen
    // can initialize the conversation immediately.
    context.push(
      '/chat',
      extra: {
        'userId': driver.driverId,
        'userName': driver.name,
        'userRole': 'driver', // Optional: Helps if chat logic differs by role
      },
    );
  }

  void _navigateToBooking(BuildContext context) {
    context.push(
      '/booking',
      extra: {'driverId': driver.driverId, 'driverName': driver.name},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    // Check if THIS driver is in the list
    final isFavorite = favorites.value?.contains(driver.driverId) ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          20,
        ), // Slightly rounder for modern look
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. HEADER SECTION ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: driver.photoUrl != null
                          ? NetworkImage(driver.photoUrl!)
                          : null,
                      child: driver.photoUrl == null
                          ? Text(
                              driver.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            )
                          : null,
                    ),
                    if (driver.isVerified)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            size: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Driver Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${driver.rating} (${driver.totalReviews})",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${driver.vehicleType} • ${driver.gender}",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Price Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${driver.priceMonthlyTwoWay.toInt()} OMR",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.indigo,
                      ),
                    ),
                    const Text(
                      "mo/2-way",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.black12),

          // --- 2. BIO SECTION ---
          if (driver.bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                driver.bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),

          // --- 3. ACTION BUTTONS ROW ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Chat Button
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  color: Colors.blue,
                  onTap: () =>
                      _startChat(context), // <--- Connect the function here
                ),
                const SizedBox(width: 10),

                // Call Button
                _buildActionButton(
                  icon: Icons.phone_outlined,
                  color: Colors.green,
                  onTap: () {
                    // Ensure your DriverAdModel has a 'phone' field
                    if (driver.phone.isNotEmpty) {
                      _makePhoneCall(context, driver.phone);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No phone number available'),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 10),

                // 4. FAVORITE BUTTON (CONNECTED)
                _buildActionButton(
                  // Change Icon based on state
                  icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                  // Change Color based on state (optional, or keep pink)
                  color: Colors.pink,
                  onTap: () {
                    // Call the Provider to toggle
                    ref
                        .read(favoritesProvider.notifier)
                        .toggleFavorite(driver.driverId);
                  },
                ),
                const SizedBox(width: 10),
                // BOOK BUTTON
                Expanded(
                  // Use Expanded to fill remaining space nicely
                  child: ElevatedButton(
                    onPressed: () => _navigateToBooking(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Book Now",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // View Profile (text link)
                const SizedBox(width: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for the square icon buttons
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
