// lib/features/parent/dashboard/presentation/widgets/dashboard_header.dart
import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.indigo.shade800,
      actions: [
        // 1. Call Icon (Contact Us)
        IconButton(
          icon: const Icon(Icons.call, color: Colors.white),
          tooltip: 'Contact Us',
          onPressed: () {}, // TODO: Launch Dialler
        ),
        // 2. Favorites (Driver Ads)
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          tooltip: 'Saved Ads',
          onPressed: () {},
        ),
        // 3. Notifications (Messages)
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
            ),
            Positioned(
              right: 12, top: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
            )
          ],
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: const Text(
          "Welcome Back",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade900, Colors.indigo.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }
}