// lib/features/parent/find_driver/presentation/widgets/driver_ad_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gotosco_v3/core/widgets/optimized_image.dart';
import '../../data/driver_ad_model.dart';
import '../providers/favorites_provider.dart';

class DriverAdCard extends ConsumerWidget {
  final DriverAdModel driver;

  const DriverAdCard({super.key, required this.driver});

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
    // Navigate to the new booking flow wizard
    context.push(
      '/booking-flow',
      extra: {'driverId': driver.driverId, 'driverName': driver.name},
    );
  }

  void _viewProfile(BuildContext context) {
    context.push('/driver-detail', extra: driver);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.value?.contains(driver.driverId) ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _viewProfile(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER SECTION ---
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with optimized image loading
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage:
                              driver.photoUrl != null &&
                                  driver.photoUrl!.isNotEmpty
                              ? OptimizedImageProvider.avatar(
                                  driver.photoUrl!,
                                  size: 64,
                                )
                              : null,
                          child:
                              driver.photoUrl == null ||
                                  driver.photoUrl!.isEmpty
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
                              "${driver.vehicleType} • ${driver.vehicleCapacity} Seats • ${driver.gender}",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          if (driver.coveredSchools.isNotEmpty ||
                              driver.coveredAreas.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                if (driver.coveredSchools.isNotEmpty)
                                  _buildClickableLabel(
                                    context,
                                    '${driver.coveredSchools.length} Schools',
                                    Icons.school,
                                    driver.coveredSchools,
                                    'Schools Covered',
                                  ),
                                if (driver.coveredAreas.isNotEmpty)
                                  _buildClickableLabel(
                                    context,
                                    '${driver.coveredAreas.length} Areas',
                                    Icons.location_city,
                                    driver.coveredAreas,
                                    'Areas Covered',
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Distance Badge (Optional placement)
                    if (driver.distanceKm != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.teal.shade100),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.teal,
                              ),
                              Text(
                                "${driver.distanceKm} km",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.teal.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
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
                        if (driver.otherPrices.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => _showOtherPrices(context),
                            child: const Text(
                              "Other Prices",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
                    _buildActionButton(
                      icon: Icons.chat_bubble_outline,
                      color: Colors.blue,
                      onTap: () => _startChat(context),
                    ),
                    const SizedBox(width: 10),
                    _buildActionButton(
                      icon: Icons.phone_outlined,
                      color: Colors.green,
                      onTap: () {
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
                    _buildActionButton(
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.pink,
                      onTap: () {
                        ref
                            .read(favoritesProvider.notifier)
                            .toggleFavorite(driver.driverId);
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildClickableLabel(
    BuildContext context,
    String label,
    IconData icon,
    List<String> items,
    String dialogTitle,
  ) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(dialogTitle),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.check_circle,
                      color: Colors.indigo,
                      size: 20,
                    ),
                    title: Text(items[index]),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.indigo.shade100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.indigo),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.indigo.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOtherPrices(BuildContext context) {
    // Combine main price with others for a complete list
    final allPrices = <String, double>{
      'price_monthly_two_way': driver.priceMonthlyTwoWay,
      ...driver.otherPrices,
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Price List',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: allPrices.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatPriceKey(e.key),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${e.value.toInt()} OMR',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _formatPriceKey(String key) {
    // Remove 'price_' prefix
    var formatted = key.replaceAll('price_', '');
    // Replace underscores with spaces
    formatted = formatted.replaceAll('_', ' ');
    // Capitalize each word
    return formatted
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }
}
