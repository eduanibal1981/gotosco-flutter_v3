// lib/features/driver/earnings/presentation/earnings_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/application/driver_dashboard_providers.dart';
import '../../dashboard/domain/models/driver_stats_model.dart';
import '../../profile/data/driver_profile_repository.dart';
import '../../dashboard/presentation/driver_dashboard_screen.dart';
import '../../profile/domain/models/driver_profile_model.dart';

class EarningsTab extends ConsumerWidget {
  const EarningsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(driverStatsProvider);
    final profileAsync = ref.watch(currentDriverProfileProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade700, Colors.teal.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Earnings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Track your monthly income',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),

                  // Main earnings card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'This Month',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        statsAsync.when(
                          data: (stats) => Text(
                            '${stats.monthlyEarnings.toStringAsFixed(0)} OMR',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
                            ),
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const Text('--'),
                        ),
                        const SizedBox(height: 8),
                        statsAsync.when(
                          data: (stats) => Text(
                            'From ${stats.activeBookings} active subscription${stats.activeBookings != 1 ? 's' : ''}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats Row
                statsAsync.when(
                  data: (stats) => _buildStatsRow(context, stats),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Text('Error: $e'),
                ),

                const SizedBox(height: 24),

                // Payment Schedule
                _buildSectionTitle('Payment Schedule'),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.calendar_today,
                  title: 'Monthly Collection',
                  subtitle: 'Payments are collected monthly from parents',
                ),

                const SizedBox(height: 24),

                // Pricing Info
                _buildSectionTitle('Your Pricing'),
                const SizedBox(height: 12),
                profileAsync.when(
                  data: (profile) {
                    if (profile == null ||
                        (profile.priceMonthlyTwoWay == 0 &&
                            profile.priceMonthlyOneWay == 0 &&
                            profile.priceDaily == 0)) {
                      return _buildEmptyPricingCard(ref);
                    }
                    return _buildPricingCard(profile);
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Text('Error loading pricing: $e'),
                ),

                const SizedBox(height: 24),

                // Tips
                _buildSectionTitle('Tips to Earn More'),
                const SizedBox(height: 12),
                _buildTipCard(
                  icon: Icons.star,
                  title: 'Get Good Reviews',
                  subtitle: 'Higher ratings attract more parents',
                ),
                const SizedBox(height: 10),
                _buildTipCard(
                  icon: Icons.location_on,
                  title: 'Expand Your Area',
                  subtitle: 'Serve more neighborhoods to get more students',
                ),
                const SizedBox(height: 10),
                _buildTipCard(
                  icon: Icons.verified,
                  title: 'Get Verified',
                  subtitle: 'Verified drivers are trusted more by parents',
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, DriverStats stats) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.people,
            value: '${stats.activeStudents}',
            label: 'Students',
            color: Colors.blue,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.book,
            value: '${stats.activeBookings}',
            label: 'Bookings',
            color: Colors.purple,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.account_balance,
            value: 'Manage',
            label: 'Payments',
            color: Colors.teal,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment methods management coming soon'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    Widget content = Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );

    if (onTap != null) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: content,
          ),
        ),
      );
    }

    return Expanded(child: content);
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade200);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.teal, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPricingCard(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade400, size: 32),
          const SizedBox(height: 12),
          const Text(
            'No Pricing Set',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Set your monthly and daily prices on your profile page to attract more parents.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to Profile tab (index 4)
                ref.read(driverDashboardIndexProvider.notifier).setIndex(4);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Set Prices in Profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(DriverProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          _buildPricingRow(
            'Two-Way Monthly',
            '${profile.priceMonthlyTwoWay.toStringAsFixed(0)} OMR',
          ),
          const Divider(height: 20),
          _buildPricingRow(
            'One-Way Monthly',
            '${profile.priceMonthlyOneWay.toStringAsFixed(0)} OMR',
          ),
          const Divider(height: 20),
          _buildPricingRow(
            'Daily Pricing',
            '${profile.priceDaily.toStringAsFixed(1)} OMR',
          ),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber.shade700, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.amber.shade800, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

