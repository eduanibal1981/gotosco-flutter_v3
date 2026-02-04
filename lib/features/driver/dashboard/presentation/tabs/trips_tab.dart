// lib/features/driver/dashboard/presentation/tabs/trips_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/driver_dashboard_repository.dart';

class TripsTab extends ConsumerWidget {
  const TripsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(todaysTripsProvider);
    final statsAsync = ref.watch(driverStatsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
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
                    'My Trips',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  // Quick Stats
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMiniStat(
                          'Today',
                          tripsAsync.when(
                            data: (t) => '${t.length}',
                            loading: () => '-',
                            error: (_, __) => '0',
                          ),
                        ),
                        Container(width: 1, height: 30, color: Colors.white24),
                        _buildMiniStat(
                          'Students',
                          statsAsync.when(
                            data: (s) => '${s['active_students'] ?? 0}',
                            loading: () => '-',
                            error: (_, __) => '0',
                          ),
                        ),
                        Container(width: 1, height: 30, color: Colors.white24),
                        _buildMiniStat(
                          'Pending',
                          statsAsync.when(
                            data: (s) => '${s['pending_requests'] ?? 0}',
                            loading: () => '-',
                            error: (_, __) => '0',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Generate Trips Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildGenerateButton(context, ref),
            ),
          ),

          // Today's Trips
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: tripsAsync.when(
              data: (trips) {
                if (trips.isEmpty) {
                  return SliverToBoxAdapter(child: _buildEmptyState());
                }

                final goTrips = trips
                    .where(
                      (t) => (t['trip_type'] as String?) == 'Go to School(s)',
                    )
                    .toList();
                final returnTrips = trips
                    .where(
                      (t) =>
                          (t['trip_type'] as String?) ==
                          'Return from School(s)',
                    )
                    .toList();

                return SliverList(
                  delegate: SliverChildListDelegate([
                    if (goTrips.isNotEmpty) ...[
                      _buildSectionHeader('🏫 Go to School(s)', goTrips.length),
                      ...goTrips.map((t) => _buildTripCard(context, ref, t)),
                      const SizedBox(height: 16),
                    ],
                    if (returnTrips.isNotEmpty) ...[
                      _buildSectionHeader(
                        '🏠 Return from School(s)',
                        returnTrips.length,
                      ),
                      ...returnTrips.map(
                        (t) => _buildTripCard(context, ref, t),
                      ),
                    ],
                    const SizedBox(height: 24),

                    const SizedBox(height: 24),

                    // Students Section
                    _buildStudentsSection(ref),

                    const SizedBox(height: 40),
                  ]),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) =>
                  SliverFillRemaining(child: Center(child: Text('Error: $e'))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildGenerateButton(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(todaysTripsProvider);
    final dashboardStateAsync = ref.watch(driverDashboardStateProvider);
    final statsAsync = ref.watch(driverStatsProvider);

    return tripsAsync.when(
      data: (trips) {
        if (trips.isNotEmpty) {
          // Trips exist - show success state with regenerate option
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Today\'s Trips Generated',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showRegenerateDialog(context, ref),
                  icon: Icon(
                    Icons.refresh,
                    size: 16,
                    color: Colors.orange.shade700,
                  ),
                  label: Text(
                    'Regenerate',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ],
            ),
          );
        }

        // Check requirements for generating trips
        final dashboardState = dashboardStateAsync.asData?.value;
        final stats = statsAsync.asData?.value;

        final bool isProfileComplete =
            dashboardState != null &&
            dashboardState != DriverDashboardState.noProfile &&
            dashboardState != DriverDashboardState.profileIncomplete;

        final int activeBookings = stats?['active_bookings'] ?? 0;
        final bool hasActiveBookings = activeBookings > 0;

        final bool canGenerate = isProfileComplete && hasActiveBookings;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!canGenerate)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Colors.orange.shade800,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Requirements to Generate Trips:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildRequirementCheck(
                      'Complete Profile & Schedule',
                      isProfileComplete,
                    ),
                    _buildRequirementCheck(
                      'Have Active Bookings',
                      hasActiveBookings,
                    ),
                  ],
                ),
              ),
            ElevatedButton.icon(
              onPressed: canGenerate
                  ? () async {
                      try {
                        await ref
                            .read(driverDashboardRepositoryProvider)
                            .generateDailyTrips();
                        ref.invalidate(todaysTripsProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Trips generated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  : null,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Generate Daily Trips'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildRequirementCheck(String label, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isMet ? Colors.green : Colors.red.shade300,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isMet ? Colors.grey.shade700 : Colors.red.shade400,
              decoration: isMet ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_bus,
              size: 48,
              color: Colors.teal.shade300,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Trips Scheduled',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Generate Daily Trips" to create\ntoday\'s pickup and dropoff routes',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: Colors.teal.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> trip,
  ) {
    final status = trip['status'] as String? ?? 'scheduled';
    final stops = (trip['route_stops'] as List?)?.length ?? 0;
    final tripType = trip['trip_type'] as String? ?? 'Trip';

    Color statusColor;
    switch (status) {
      case 'in_progress':
        statusColor = Colors.green;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  tripType.contains('Go') ? Icons.school : Icons.home,
                  size: 18,
                  color: tripType.contains('Go') ? Colors.blue : Colors.green,
                ),
                const SizedBox(width: 6),
                Text(
                  tripType,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '$stops stops',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (status == 'scheduled')
              _TripActionButton(
                label: 'Start Trip',
                icon: Icons.play_arrow,
                color: Colors.teal,
                onPressed: () async {
                  await ref
                      .read(driverDashboardRepositoryProvider)
                      .startTrip(trip['id']);
                  ref.invalidate(todaysTripsProvider);
                  ref.invalidate(driverDashboardStateProvider);
                },
              )
            else if (status == 'in_progress')
              _TripActionButton(
                label: 'End Trip',
                icon: Icons.stop,
                color: Colors.red,
                isOutlined: true,
                onPressed: () async {
                  await ref
                      .read(driverDashboardRepositoryProvider)
                      .endTrip(trip['id']);
                  ref.invalidate(todaysTripsProvider);
                  ref.invalidate(driverDashboardStateProvider);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsSection(WidgetRef ref) {
    final studentsAsync = ref.watch(driverStudentsProvider);

    return studentsAsync.when(
      data: (students) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.people, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  const Text(
                    'My Students',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${students.length}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (students.isEmpty)
                Text(
                  'No students enrolled yet',
                  style: TextStyle(color: Colors.grey.shade500),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: students
                      .take(6)
                      .map(
                        (s) => Chip(
                          label: Text(
                            s['name'] ?? '',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.blue.shade50,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }

  void _showRegenerateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Regenerate Trips?'),
        content: const Text(
          'This will delete today\'s trips and create new ones based on current schedules. Any in-progress trips will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(driverDashboardRepositoryProvider)
                    .regenerateDailyTrips();
                ref.invalidate(todaysTripsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Trips regenerated!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );
  }
}

class _TripActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Future<void> Function() onPressed;
  final bool isOutlined;

  const _TripActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  State<_TripActionButton> createState() => _TripActionButtonState();
}

class _TripActionButtonState extends State<_TripActionButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOutlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _isLoading ? null : _handlePress,
          icon: _isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.color,
                  ),
                )
              : Icon(widget.icon, size: 18),
          label: Text(widget.label),
          style: OutlinedButton.styleFrom(
            foregroundColor: widget.color,
            side: BorderSide(color: widget.color),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handlePress,
        icon: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(widget.icon, size: 18),
        label: Text(widget.label),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}
