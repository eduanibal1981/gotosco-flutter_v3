// lib/features/driver/dashboard/presentation/tabs/driver_home_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gotosco_v3/features/auth/presentation/user_provider.dart';
import 'package:gotosco_v3/features/auth/data/auth_repository.dart';
import 'package:gotosco_v3/core/widgets/role_switcher_button.dart';
import '../../data/driver_dashboard_repository.dart';
import '../driver_dashboard_screen.dart';
import '../screens/active_trip_screen.dart';
import '../../../profile/data/driver_profile_repository.dart';
import '../../../profile/presentation/controllers/driver_profile_scroll_controller.dart';
import '../../../availability/presentation/availability_control_sheet.dart';
import '../../../availability/presentation/driver_availability_controller.dart';
import '../widgets/booking_requests_card.dart';
import '../../../transport_requests/data/transport_requests_repository.dart';

class DriverHomeTab extends ConsumerStatefulWidget {
  const DriverHomeTab({super.key});

  @override
  ConsumerState<DriverHomeTab> createState() => _DriverHomeTabState();
}

class _DriverHomeTabState extends ConsumerState<DriverHomeTab> {
  bool _isLoading = false;

  /// Switch to Trips tab (Index 3)
  void _navigateToTripsTab() {
    ref.read(driverDashboardIndexProvider.notifier).setIndex(3);
  }

  /// Refresh all dashboard data
  Future<void> _refreshDashboard() async {
    // Invalidate all dashboard-related providers to force refresh
    ref.invalidate(driverDashboardStateProvider);
    ref.invalidate(driverProfileProvider);
    ref.invalidate(driverStatsProvider);
    ref.invalidate(todaysTripsProvider);
    ref.invalidate(activeTripProvider);

    // Wait for the state to reload
    await ref.read(driverDashboardStateProvider.future);
  }

  Future<void> _openEditProfile(BuildContext context) async {
    final profile = await ref.read(currentDriverProfileProvider.future);
    if (!context.mounted) {
      return;
    }
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile not found. Please try again.')),
      );
      return;
    }
    context.push('/driver-profile-edit', extra: profile);
  }

  void _openProfileSection(DriverProfileScrollTarget target) {
    ref
        .read(driverProfileScrollTargetControllerProvider.notifier)
        .setTarget(target);
    ref.read(driverDashboardIndexProvider.notifier).setIndex(4);
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(driverDashboardStateProvider);
    final userAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        color: Colors.teal,
        child: stateAsync.when(
          data: (dashboardState) =>
              _buildStateContent(dashboardState, userAsync),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildErrorState(e),
        ),
      ),
    );
  }

  /// Build error state with refresh option
  Widget _buildErrorState(Object error) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '$error',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _refreshDashboard,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStateContent(
    DriverDashboardState dashboardState,
    AsyncValue userAsync,
  ) {
    switch (dashboardState) {
      case DriverDashboardState.noProfile:
        return _buildNoProfileState();
      case DriverDashboardState.profileIncomplete:
        return _buildProfileIncompleteState(userAsync);
      case DriverDashboardState.profileOnly:
        return _buildProfileOnlyState(userAsync);
      case DriverDashboardState.hasRequests:
        return _buildHasRequestsState(userAsync);
      case DriverDashboardState.hasTrips:
        return _buildHasTripsState(userAsync);
      case DriverDashboardState.activeTrip:
        return _buildActiveTripState();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE 1: NO PROFILE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildNoProfileState() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        _buildHeader(
          title: 'School Transport Driver',
          subtitle: 'Get started with your driver account',
          showOnlineToggle: false,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Welcome notification
              _buildNotificationBanner(
                icon: Icons.waving_hand,
                message:
                    'Welcome! Complete your profile to start accepting bookings.',
                color: Colors.amber,
              ),

              const SizedBox(height: 24),

              // Quick Actions
              _buildSectionTitle('Quick Actions'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.person_add,
                      label: 'Create Profile',
                      color: Colors.teal,
                      onTap: () => context.push('/driver-profile-create'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.play_circle_outline,
                      label: 'View Tutorial',
                      color: Colors.blue,
                      onTap: () => context.push('/help-support'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Empty state cards
              _buildEmptyCard(
                icon: Icons.directions_bus,
                title: "Today's Trips",
                subtitle: 'No trips scheduled',
                onTap: _navigateToTripsTab,
              ),
              const SizedBox(height: 12),
              _buildEmptyCard(
                icon: Icons.inbox,
                title: 'Booking Requests',
                subtitle: 'No pending requests',
                onTap: () {
                  ref
                      .read(driverBookingTabIndexNotifierProvider.notifier)
                      .setIndex(0);
                  ref.read(driverDashboardIndexProvider.notifier).setIndex(1);
                },
              ),
              const SizedBox(height: 12),
              _buildEmptyCard(
                icon: Icons.attach_money,
                title: 'Earnings',
                subtitle: '0.00 OMR\nComplete profile to start earning',
                onTap: () {
                  ref.read(driverDashboardIndexProvider.notifier).setIndex(0);
                },
              ),

              const SizedBox(height: 24),

              // Setup Guide
              _buildSetupGuide(),
            ]),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE 2: PROFILE INCOMPLETE (Missing required fields)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildProfileIncompleteState(AsyncValue userAsync) {
    final profileAsync = ref.watch(driverProfileProvider);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        _buildHeader(
          title: userAsync.when(
            data: (u) =>
                'Welcome, ${u?.fullName.split(' ').first ?? 'Driver'}!',
            loading: () => 'Welcome!',
            error: (_, __) => 'Welcome!',
          ),
          subtitle: 'Complete your profile to get started',
          showOnlineToggle: false,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Warning notification
              _buildNotificationBanner(
                icon: Icons.warning_amber_rounded,
                message:
                    'Your profile is incomplete. Please fill in all required fields to start receiving bookings.',
                color: Colors.orange,
              ),

              const SizedBox(height: 24),

              // Missing fields info card - dynamically show completion status
              profileAsync.when(
                data: (profile) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.checklist, color: Colors.teal.shade600),
                          const SizedBox(width: 8),
                          const Text(
                            'Required Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildChecklistItem(
                        'Vehicle Type',
                        profile?['vehicle_type'] != null &&
                            (profile!['vehicle_type'] as String).isNotEmpty,
                      ),
                      _buildChecklistItem(
                        'Vehicle Number',
                        profile?['vehicle_number'] != null &&
                            (profile!['vehicle_number'] as String).isNotEmpty,
                      ),
                      _buildChecklistItem(
                        'Vehicle Capacity',
                        profile?['vehicle_capacity'] != null &&
                            (profile!['vehicle_capacity'] as int) > 0,
                      ),
                      _buildChecklistItem(
                        'License Number',
                        profile?['license_number'] != null &&
                            (profile!['license_number'] as String).isNotEmpty,
                      ),
                      _buildChecklistItem(
                        'License Picture',
                        profile?['license_image_url'] != null &&
                            (profile!['license_image_url'] as String).isNotEmpty,
                      ),
                      _buildChecklistItem(
                        'Registration Picture (Mulkia)',
                        profile?['mulkia_image_url'] != null &&
                            (profile!['mulkia_image_url'] as String).isNotEmpty,
                      ),
                      // Schedule check - use separate FutureBuilder
                      FutureBuilder<List>(
                        future: ref.read(driverSchedulesProvider.future),
                        builder: (context, snapshot) {
                          final hasSchedule =
                              snapshot.hasData && snapshot.data!.isNotEmpty;
                          return _buildChecklistItem(
                            'Weekly Schedule',
                            hasSchedule,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              _buildSectionTitle('Quick Actions'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.edit,
                      label: 'Edit Profile',
                      color: Colors.teal,
                      onTap: () => _openEditProfile(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.help_outline,
                      label: 'Get Help',
                      color: Colors.blue,
                      onTap: () => context.push('/help-support'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Empty state cards
              _buildEmptyCard(
                icon: Icons.directions_bus,
                title: "Today's Trips",
                subtitle: 'Complete profile to schedule trips',
                onTap: _navigateToTripsTab,
              ),
              const SizedBox(height: 12),
              _buildEmptyCard(
                icon: Icons.inbox,
                title: 'Booking Requests',
                subtitle: 'Complete profile to receive requests',
                onTap: () {
                  ref
                      .read(driverBookingTabIndexNotifierProvider.notifier)
                      .setIndex(0);
                  ref.read(driverDashboardIndexProvider.notifier).setIndex(1);
                },
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(String label, bool isComplete) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isComplete ? Colors.green : Colors.grey.shade400,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isComplete ? Colors.grey.shade700 : Colors.grey.shade600,
              decoration: isComplete ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE 3: PROFILE ONLY (No Bookings)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildProfileOnlyState(AsyncValue userAsync) {
    final profileAsync = ref.watch(driverProfileProvider);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        _buildHeader(
          title: userAsync.when(
            data: (u) =>
                'Welcome, ${u?.fullName.split(' ').first ?? 'Driver'}!',
            loading: () => 'Welcome!',
            error: (_, __) => 'Welcome!',
          ),
          subtitle: DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
          showOnlineToggle: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Profile status
              profileAsync.when(
                data: (profile) => _buildProfileStatusCard(profile),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // Ad/Online Button (Only if Offline)
              Consumer(
                builder: (context, ref, child) {
                  final availabilityAsync = ref.watch(
                    driverAvailabilityControllerProvider,
                  );
                  return availabilityAsync.when(
                    data: (settings) {
                      if (!settings.isProfileOnline) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _buildGoOnlineButton(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              ),

              // Quick Actions
              _buildSectionTitle('Quick Actions'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildSmallAction(
                    Icons.edit,
                    'Edit Profile',
                    () => _openEditProfile(context),
                  ),
                  _buildSmallAction(Icons.schedule, 'Edit Schedule', () {}),
                  _buildSmallAction(
                    Icons.directions_bus,
                    'View Vehicle',
                    () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Dashboard cards
              _buildEmptyCard(
                icon: Icons.directions_bus,
                title: "Today's Trips",
                subtitle: 'No trips scheduled',
                onTap: _navigateToTripsTab,
              ),
              const SizedBox(height: 12),
              _buildEmptyCard(
                icon: Icons.inbox,
                title: 'Booking Requests',
                subtitle:
                    'Waiting for requests...\nGo online to receive bookings',
                onTap: () {
                  ref
                      .read(driverBookingTabIndexNotifierProvider.notifier)
                      .setIndex(0);
                  ref.read(driverDashboardIndexProvider.notifier).setIndex(1);
                },
              ),

              const SizedBox(height: 24),

              // Transport Requests Preview
              _buildTransportRequestsPreview(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildGoOnlineButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade600, Colors.teal.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await ref
                .read(driverAvailabilityControllerProvider.notifier)
                .toggleProfileVisibility();
            if (context.mounted) {
              _refreshDashboard();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your Ad is online! Parents can now see you.'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rocket_launch,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Go Your Ad Online',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Become visible to parents',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE 3: HAS REQUESTS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHasRequestsState(AsyncValue userAsync) {
    final statsAsync = ref.watch(driverStatsProvider);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        _buildHeader(
          title: userAsync.when(
            data: (u) =>
                'Welcome, ${u?.fullName.split(' ').first ?? 'Driver'}!',
            loading: () => 'Welcome!',
            error: (_, __) => 'Welcome!',
          ),
          subtitle: 'GoToSco wish you the best day!',
          showOnlineToggle: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Booking Requests Card (Standalone)
              const BookingRequestsCard(),

              const SizedBox(height: 12),

              const SizedBox(height: 20),

              // Quick Actions
              _buildSectionTitle('Quick Actions'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.inbox,
                      label: 'View Requests',
                      color: Colors.orange,
                      badge: statsAsync.when(
                        data: (s) => s['pending_requests'] ?? 0,
                        loading: () => 0,
                        error: (_, __) => 0,
                      ),
                      onTap: () => ref
                          .read(driverDashboardIndexProvider.notifier)
                          .setIndex(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.people,
                      label: 'Manage Children',
                      color: Colors.blue,
                      onTap: () => ref
                          .read(driverDashboardIndexProvider.notifier)
                          .setIndex(2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Today's Schedule Card
              _buildTodayScheduleCard(),

              const SizedBox(height: 12),

              // Capacity Card
              statsAsync.when(
                data: (stats) =>
                    _buildCapacityCard(stats['active_students'] ?? 0, 8),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              _buildTransportRequestsPreview(),
            ]),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE 4: HAS TRIPS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHasTripsState(AsyncValue userAsync) {
    final statsAsync = ref.watch(driverStatsProvider);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        _buildHeader(
          title: DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
          subtitle: 'ONLINE ✓',
          showOnlineToggle: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Booking Requests Card (Standalone)
              const BookingRequestsCard(),

              // Next Trip - Show only the upcoming scheduled trip
              _buildSectionTitle("🚨 Next Trip"),
              const SizedBox(height: 12),

              // Use nextScheduledTripProvider to show only the next trip
              Consumer(
                builder: (context, ref, child) {
                  final nextTripAsync = ref.watch(nextScheduledTripProvider);
                  return nextTripAsync.when(
                    data: (trip) {
                      if (trip == null) {
                        return _buildNoNextTripCard();
                      }
                      return _buildTripCard(trip);
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Generate Trips Button
              _buildGenerateTripsButton(),

              const SizedBox(height: 20),

              // Dashboard Cards
              _buildSectionTitle('Dashboard'),
              const SizedBox(height: 12),

              // Students Card
              statsAsync.when(
                data: (stats) =>
                    _buildStudentsCard(stats['active_students'] ?? 0),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 12),

              // Monthly Earnings
              statsAsync.when(
                data: (stats) =>
                    _buildEarningsCard(stats['monthly_earnings'] ?? 0),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 12),

              // Capacity
              statsAsync.when(
                data: (stats) =>
                    _buildCapacityCard(stats['active_students'] ?? 0, 8),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              _buildTransportRequestsPreview(),
            ]),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE 5: ACTIVE TRIP
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildActiveTripState() {
    return const ActiveTripScreen();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED COMPONENTS
  // ═══════════════════════════════════════════════════════════════════════════

  SliverToBoxAdapter _buildHeader({
    required String title,
    required String subtitle,
    required bool showOnlineToggle,
  }) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logout button (Moved to left side)
                IconButton(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  tooltip: 'Logout',
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Role Switcher (for dual-role users)
                    const RoleSwitcherButton(),
                    // Messages button
                    IconButton(
                      onPressed: () => context.push('/driver-messages'),
                      icon: const Icon(
                        Icons.message_outlined,
                        color: Colors.white,
                      ),
                      tooltip: 'Messages',
                    ),
                    if (showOnlineToggle) ...[
                      const SizedBox(width: 8),
                      _buildOnlineToggle(),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineToggle() {
    final availabilityAsync = ref.watch(driverAvailabilityControllerProvider);

    return availabilityAsync.when(
      data: (settings) => GestureDetector(
        onTap: () async {
          await ref
              .read(driverAvailabilityControllerProvider.notifier)
              .toggleProfileVisibility();
          if (context.mounted) _refreshDashboard();
        },
        onLongPress: () => AvailabilityControlSheet.show(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: settings.isProfileOnline
                ? Colors.green
                : Colors.grey.shade600,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                settings.isProfileOnline ? Icons.circle : Icons.circle_outlined,
                size: 10,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                settings.isProfileOnline ? 'Visible' : 'Hidden',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                settings.isSmartMode ? Icons.auto_awesome : Icons.touch_app,
                size: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const SizedBox(
          width: 60,
          height: 16,
          child: LinearProgressIndicator(
            color: Colors.white,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Offline',
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildNotificationBanner({
    required IconData icon,
    required String message,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: color.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onTap != null) Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 32),
                if (badge > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.teal.shade700),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.teal.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.grey.shade400, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupGuide() {
    final steps = [
      'Create your driver profile',
      'Set your availability schedule',
      'Go online to receive requests',
      'Accept suitable bookings',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: Colors.teal.shade600),
              const SizedBox(width: 8),
              Text(
                'Setup Guide',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.teal.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    entry.value,
                    style: TextStyle(color: Colors.teal.shade700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatusCard(Map<String, dynamic>? profile) {
    if (profile == null) return const SizedBox.shrink();

    final serviceAreas =
        (profile['service_areas'] as List?)?.whereType<String>().toList() ?? [];
    final schools =
        (profile['schools'] as List?)?.whereType<String>().toList() ?? [];
    final startPointText = profile['start_location_text'] as String?;
    final hasStartPoint =
        (startPointText != null && startPointText.trim().isNotEmpty) ||
        profile['start_location_geo'] != null;

    final missingAreas = serviceAreas.isEmpty;
    final missingSchools = schools.isEmpty;
    final missingStartPoint = !hasStartPoint;
    final hasMissingCoverage =
        missingAreas || missingSchools || missingStartPoint;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600),
              const SizedBox(width: 8),
              const Text(
                'Profile: Complete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600),
              const SizedBox(width: 8),
              const Text(
                'Schedule: Set',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (hasMissingCoverage) ...[
            const SizedBox(height: 12),
            Divider(color: Colors.green.shade200),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Complete coverage setup',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (missingAreas)
              _buildCoverageAction(
                icon: Icons.map_outlined,
                label: 'Select your covered parent areas',
                onTap: () =>
                    _openProfileSection(DriverProfileScrollTarget.serviceAreas),
              ),
            if (missingSchools)
              _buildCoverageAction(
                icon: Icons.school_outlined,
                label: 'Select your covered schools',
                onTap: () =>
                    _openProfileSection(DriverProfileScrollTarget.serviceAreas),
              ),
            if (missingStartPoint)
              _buildCoverageAction(
                icon: Icons.my_location,
                label: 'Set your start point (use your location)',
                onTap: () => _openProfileSection(
                  DriverProfileScrollTarget.locationSettings,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildCoverageAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.green.shade700),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.green.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportRequestsPreview() {
    final requestsAsync = ref.watch(transportRequestsProvider(status: 'open'));

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
              const Text(
                'Transport Requests',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/driver-transport-requests'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          requestsAsync.when(
            data: (requests) {
              if (requests.isEmpty) {
                return Text(
                  'No transport requests yet.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                );
              }
              final items = requests.take(2).toList();
              return Column(
                children: items.map((request) {
                  final parentName =
                      request['parent_name'] as String? ?? 'Parent';
                  final childName = request['child_name'] as String? ?? 'Child';
                  final schoolName =
                      request['school_name'] as String? ?? 'School';
                  final bookingType = request['booking_type'] as String? ?? '';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.teal.shade50,
                          child: Text(
                            parentName.isNotEmpty
                                ? parentName[0].toUpperCase()
                                : 'P',
                            style: TextStyle(color: Colors.teal.shade700),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                parentName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$childName · $schoolName',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (bookingType.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              bookingType,
                              style: TextStyle(
                                color: Colors.teal.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(),
            ),
            error: (err, _) => Text(
              'Failed to load requests',
              style: TextStyle(color: Colors.red.shade300),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayScheduleCard() {
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
          const Text(
            "Today's Schedule",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildScheduleTime(
                  'Morning',
                  '06:00 - 08:30',
                  Icons.wb_sunny,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScheduleTime(
                  'Afternoon',
                  '13:00 - 16:00',
                  Icons.nights_stay,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTime(String label, String time, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.teal.shade600),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 12, color: Colors.teal.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityCard(int filled, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.airline_seat_recline_normal,
            color: Colors.purple.shade600,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Capacity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '$filled/$total slots filled',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '$filled',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsCard(int count) {
    return GestureDetector(
      onTap: () {
        // Set the booking tab to "Active" (index 1) before navigating
        ref.read(driverBookingTabIndexNotifierProvider.notifier).setIndex(1);
        // Navigate to Booking tab (index 1) in the dashboard
        ref.read(driverDashboardIndexProvider.notifier).setIndex(1);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.people, color: Colors.blue.shade600),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Children',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$count enrolled',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard(int amount) {
    return GestureDetector(
      onTap: () {
        // Navigate to Earnings tab (index 0) in the dashboard
        ref.read(driverDashboardIndexProvider.notifier).setIndex(0);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.attach_money, color: Colors.green.shade600),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly Earnings',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Estimated',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  '$amount OMR',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Card shown when there's no next scheduled trip
  Widget _buildNoNextTripCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.teal.shade400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'All Caught Up!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'No more scheduled trips for today.\nAll trips have been completed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final tripType = trip['trip_type'] as String? ?? 'Go to School(s)';
    final status = trip['status'] as String? ?? 'scheduled';
    final stops = (trip['route_stops'] as List?)?.length ?? 0;

    final isGoTrip = tripType.contains('Go');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isGoTrip ? Colors.blue.shade200 : Colors.green.shade200,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGoTrip ? Icons.school : Icons.home,
                color: isGoTrip ? Colors.blue : Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tripType,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'in_progress'
                      ? Colors.orange.shade100
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: status == 'in_progress'
                        ? Colors.orange
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('$stops stops', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref
                    .read(driverDashboardRepositoryProvider)
                    .startTrip(trip['id']);
                ref.invalidate(driverDashboardStateProvider);
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Trip'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateTripsButton() {
    final tripsAsync = ref.watch(todaysTripsProvider);

    return tripsAsync.when(
      data: (trips) {
        final hasTrips = trips.isNotEmpty;

        if (hasTrips) {
          // Trips already exist - show success state
          return GestureDetector(
            onTap: _navigateToTripsTab,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Today\'s Trips Generated ✓',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // No trips - show generate button
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() => _isLoading = true);
                    try {
                      await ref
                          .read(driverDashboardRepositoryProvider)
                          .generateDailyTrips();
                      ref.invalidate(todaysTripsProvider);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Trips generated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                    setState(() => _isLoading = false);
                  },
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_fix_high),
            label: Text(_isLoading ? 'Generating...' : 'Generate Daily Trips'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

extension on Color {
  Color get shade700 => this;
}
