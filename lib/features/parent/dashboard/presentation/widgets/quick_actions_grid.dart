// lib/features/parent/dashboard/presentation/widgets/quick_actions_grid.dart
import 'package:flutter/material.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAction(
          context,
          Icons.person_off_outlined,
          'Mark Absent',
          Colors.orange,
          () {},
        ),
        _buildAction(
          context,
          Icons.call_outlined,
          'Call Driver',
          Colors.green,
          () {},
        ),
        _buildAction(
          context,
          Icons.credit_card_outlined,
          'Pay Fees',
          Colors.purple,
          () {},
        ),
        _buildAction(
          context,
          Icons.chat_bubble_outline,
          'Chat',
          Colors.blue,
          () {},
        ),
      ],
    );
  }

  Widget _buildAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: MediaQuery.of(context).size.width / 4.8, // Responsive width
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
