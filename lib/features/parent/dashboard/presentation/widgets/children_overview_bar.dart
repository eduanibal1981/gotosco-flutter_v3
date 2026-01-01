// lib/features/parent/dashboard/presentation/widgets/children_overview_bar.dart
import 'package:flutter/material.dart';

class ChildrenOverviewBar extends StatelessWidget {
  const ChildrenOverviewBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final children = [
      {'name': 'Ali', 'status': 'Safe', 'color': Colors.green},
      {'name': 'Sara', 'status': 'En Route', 'color': Colors.amber},
      {'name': 'Omar', 'status': 'Absent', 'color': Colors.grey},
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: children.length + 1, // +1 for "Add Child" button
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          if (index == children.length) {
            return _buildAddChildButton();
          }
          return _buildChildAvatar(children[index]);
        },
      ),
    );
  }

  Widget _buildChildAvatar(Map<String, dynamic> child) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: child['color'], width: 2),
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey.shade200,
                // Replace with NetworkImage later
                child: Text(
                  child['name'][0],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: child['color'],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          child['name'],
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAddChildButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
            ),
          ),
          child: const Icon(Icons.add, color: Colors.indigo),
        ),
        const SizedBox(height: 4),
        const Text('Add', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
