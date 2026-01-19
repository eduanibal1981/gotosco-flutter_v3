import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gotosco_v3/features/auth/data/auth_repository.dart';
import 'package:gotosco_v3/features/auth/presentation/user_provider.dart';
import 'package:gotosco_v3/core/widgets/role_switcher_button.dart';
import 'package:gotosco_v3/features/parent/notifications/data/notifications_repository.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current User for name
    final userAsync = ref.watch(currentUserProfileProvider);
    final userName = userAsync.maybeWhen(
      data: (user) {
        if (user == null) return 'Back';
        final names = user.fullName.split(' ');
        return names.isNotEmpty ? names.first : 'Back';
      },
      orElse: () => 'Back', // "Welcome Back" fallback
    );

    // Format Date: e.g., "Monday, 13 January"
    final dateStr = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return SliverAppBar(
      expandedHeight: 140.0, // Increased slightly for better spacing
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF0B1E3B),
      // Status bar brightness
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      // Logout on the left ("other side")
      leading: IconButton(
        icon: const Icon(Icons.logout_outlined, color: Colors.white, size: 22),
        tooltip: 'Logout',
        onPressed: () => _showLogoutDialog(context, ref),
      ),
      actions: [
        // Role Switcher
        const RoleSwitcherButton(),
        // Actions wrapper
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              // Chat Icon
              IconButton(
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 22,
                ),
                tooltip: 'Chats',
                onPressed: () {
                  context.push('/parent-chats');
                },
              ),
              // Notifications Icon
              _NotificationsIcon(
                unreadCountStream: ref.watch(parentUnreadNotificationsCountProvider),
                onPressed: () => context.push('/notifications'),
              ),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
        centerTitle: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dateStr.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Welcome, $userName",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        background: ClipPath(
          clipper: _HeaderWaveClipper(),
          child: Stack(
            children: [
              // 1. Gradient Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0B1E3B), Color(0xFF1C3F6E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // 2. Deco Circles (Professional Texture)
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

class _HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 28);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 18,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 36,
      size.width,
      size.height - 12,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _NotificationsIcon extends ConsumerWidget {
  final AsyncValue<int> unreadCountStream;
  final VoidCallback onPressed;

  const _NotificationsIcon({
    required this.unreadCountStream,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = unreadCountStream.maybeWhen(
      data: (value) => value,
      orElse: () => 0,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 22,
          ),
          onPressed: onPressed,
          tooltip: 'Notifications',
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
