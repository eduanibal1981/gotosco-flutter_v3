// lib/features/parent/profile/presentation/profile_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotosco_v3/features/auth/data/auth_repository.dart';
import 'package:gotosco_v3/features/auth/presentation/user_provider.dart';
import 'package:gotosco_v3/features/parent/children/data/children_repository.dart';
import 'package:gotosco_v3/features/parent/bookings/data/bookings_repository.dart';
import 'package:gotosco_v3/core/providers/user_session_provider.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final childrenAsync = ref.watch(myChildrenProvider);
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("Not logged in"));
          }

          final childrenCount = childrenAsync.when(
            data: (c) => c.length,
            loading: () => 0,
            error: (_, __) => 0,
          );

          final activeBookings = bookingsAsync.when(
            data: (b) => b
                .where(
                  (x) =>
                      (x['status'] == 'accepted' ||
                          x['status'] == 'confirmed' ||
                          x['status'] == 'in_progress') &&
                      (x['subscription_status'] == 'active' ||
                          x['subscription_status'] == null),
                )
                .length,
            loading: () => 0,
            error: (_, __) => 0,
          );

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  // Increased bottom padding to 50 to give more space for the stats card overlap
                  // Added MediaQuery top padding to avoid status bar overlap
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + 20,
                    20,
                    30,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade700, Colors.indigo.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Custom App Bar Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              context.push('/edit-profile', extra: user);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Profile Photo
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            backgroundImage: user.photoUrl != null
                                ? NetworkImage(user.photoUrl!)
                                : null,
                            child: user.photoUrl == null
                                ? Text(
                                    user.fullName.isNotEmpty
                                        ? user.fullName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Email
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildStatItem(
                          icon: Icons.child_care,
                          value: childrenCount.toString(),
                          label: 'Children',
                          color: Colors.blue,
                        ),
                        _buildDivider(),
                        _buildStatItem(
                          icon: Icons.directions_bus,
                          value: activeBookings.toString(),
                          label: 'Active',
                          color: Colors.green,
                        ),
                        _buildDivider(),
                        _buildStatItem(
                          icon: Icons.verified_user,
                          value: 'Member',
                          label: 'Since 2024',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Profile Details
                    _buildSectionTitle('Profile Details'),
                    _buildSettingsCard([
                      _buildListTile(
                        icon: Icons.phone_outlined,
                        title: 'Phone',
                        subtitle: (user.phone == null || user.phone!.isEmpty)
                            ? 'Not set'
                            : user.phone!,
                      ),
                      _buildListTile(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        subtitle: user.email,
                      ),
                      _buildListTile(
                        icon: Icons.location_on_outlined,
                        title: 'Location',
                        subtitle:
                            (user.locationText == null ||
                                user.locationText!.isEmpty)
                            ? 'Not set'
                            : user.locationText!,
                      ),
                      _buildListTile(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/edit-profile', extra: user);
                        },
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Account Settings
                    _buildSectionTitle('Account Settings'),
                    _buildSettingsCard([
                      // Role Switcher for dual-role users
                      Consumer(
                        builder: (context, ref, child) {
                          final sessionAsync = ref.watch(userSessionProvider);
                          return sessionAsync.when(
                            data: (session) {
                              if (session == null || !session.isDualRole) {
                                return const SizedBox.shrink();
                              }

                              final otherRole = session.activeRole == 'driver'
                                  ? 'parent'
                                  : 'driver';
                              final otherRoleName = otherRole == 'driver'
                                  ? 'Driver'
                                  : 'Parent';

                              return _buildListTile(
                                icon: otherRole == 'driver'
                                    ? Icons.directions_bus
                                    : Icons.people,
                                title: 'Switch to $otherRoleName Mode',
                                subtitle:
                                    'You have both parent and driver roles',
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  await ref
                                      .read(userSessionProvider.notifier)
                                      .switchRole(otherRole);
                                  if (context.mounted) {
                                    context.go(
                                      otherRole == 'driver'
                                          ? '/driver-home'
                                          : '/parent-home',
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Switched to $otherRoleName mode',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),
                      _buildListTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        trailing: Switch(
                          value: true,
                          onChanged: (val) {},
                          activeColor: Colors.indigo,
                        ),
                      ),
                      _buildListTile(
                        icon: Icons.language_outlined,
                        title: 'Language',
                        subtitle: 'English',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Language settings coming soon"),
                            ),
                          );
                        },
                      ),
                      _buildListTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        trailing: Switch(
                          value: false,
                          onChanged: (val) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Dark mode coming soon"),
                              ),
                            );
                          },
                          activeColor: Colors.indigo,
                        ),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Support
                    _buildSectionTitle('Support'),
                    _buildSettingsCard([
                      _buildListTile(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/help-support');
                        },
                      ),
                      _buildListTile(
                        icon: Icons.description_outlined,
                        title: 'Terms & Conditions',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/terms');
                        },
                      ),
                      _buildListTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/privacy');
                        },
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(context, ref),
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Version
                    Center(
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade200);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.indigo, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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
