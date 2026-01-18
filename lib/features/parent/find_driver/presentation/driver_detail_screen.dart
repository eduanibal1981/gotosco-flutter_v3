import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotosco_v3/features/parent/find_driver/data/driver_ad_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverDetailScreen extends ConsumerWidget {
  final DriverAdModel driver;

  const DriverDetailScreen({super.key, required this.driver});

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch dialer')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error launching call: $e");
    }
  }

  void _startChat(BuildContext context) {
    context.push(
      '/chat',
      extra: {
        'userId': driver.driverId,
        'userName': driver.name,
        'userRole': 'driver',
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. App Bar with Image Carousel
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(background: _buildImageCarousel()),
          ),

          // 2. Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 20,
                                  color: Colors.amber.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${driver.rating} (${driver.totalReviews} reviews)",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${driver.priceMonthlyTwoWay.toInt()} OMR",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          const Text(
                            "monthly / 2-way",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Verification & Status
                  Row(
                    children: [
                      if (driver.isVerified)
                        _buildTag(
                          Icons.verified,
                          "Verified Driver",
                          Colors.blue,
                        ),
                      const SizedBox(width: 8),
                      _buildTag(
                        driver.isOnline ? Icons.circle : Icons.circle_outlined,
                        driver.isOnline ? "Online" : "Offline",
                        driver.isOnline ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bio
                  const Text(
                    "About Driver",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    driver.bio.isNotEmpty ? driver.bio : "No bio available.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Vehicle Info
                  const Text(
                    "Vehicle Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.directions_car,
                    "Type",
                    driver.vehicleType,
                  ),
                  _buildInfoRow(
                    Icons.airline_seat_recline_normal,
                    "Capacity",
                    "${driver.vehicleCapacity} Seats",
                  ),
                  _buildInfoRow(Icons.person, "Gender", driver.gender),
                  const SizedBox(height: 24),

                  // Coverage (Schools & Areas)
                  if (driver.coveredSchools.isNotEmpty) ...[
                    const Text(
                      "Covered Schools",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: driver.coveredSchools
                          .map((s) => _buildChip(s, Icons.school))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (driver.coveredAreas.isNotEmpty) ...[
                    const Text(
                      "Service Areas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: driver.coveredAreas
                          .map((a) => _buildChip(a, Icons.location_city))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Other Prices
                  if (driver.otherPrices.isNotEmpty) ...[
                    const Text(
                      "Other Pricing Options",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: driver.otherPrices.entries.map((e) {
                          return ListTile(
                            title: Text(_formatPriceKey(e.key)),
                            trailing: Text(
                              "${e.value.toInt()} OMR",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.indigo,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Bottom padding for fixed button
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Call Button
              IconButton.filledTonal(
                onPressed: () {
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
                icon: const Icon(Icons.phone),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.shade50,
                  foregroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(width: 8),
              // Chat Button
              IconButton.filledTonal(
                onPressed: () => _startChat(context),
                icon: const Icon(Icons.chat_bubble_outline),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(width: 12),
              // Book Button
              Expanded(
                child: FilledButton(
                  onPressed: () => _navigateToBooking(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Book Now",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    if (driver.adPhotos.isEmpty) {
      // Fallback to single static image or placeholder
      return Container(
        color: Colors.grey.shade200,
        child: driver.photoUrl != null
            ? CachedNetworkImage(
                imageUrl: driver.photoUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade200),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.person, size: 64, color: Colors.grey),
                ),
              )
            : const Center(
                child: Icon(Icons.directions_car, size: 64, color: Colors.grey),
              ),
      );
    }

    return PageView.builder(
      itemCount: driver.adPhotos.length,
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: driver.adPhotos[index],
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey.shade200),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade100,
            child: const Icon(Icons.error),
          ),
        );
      },
    );
  }

  Widget _buildTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.indigo),
      label: Text(label),
      backgroundColor: Colors.indigo.shade50,
      side: BorderSide.none,
      labelStyle: TextStyle(color: Colors.indigo.shade900, fontSize: 12),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPriceKey(String key) {
    var formatted = key.replaceAll('price_', '');
    formatted = formatted.replaceAll('_', ' ');
    return formatted
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }
}
