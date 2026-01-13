import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotosco_v3/features/parent/children/data/child_model.dart';
import 'package:gotosco_v3/features/parent/children/data/children_repository.dart';
import 'package:gotosco_v3/features/parent/children/presentation/set_absence_screen.dart';

class ChildrenSection extends ConsumerWidget {
  const ChildrenSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the real database stream/future
    final childrenAsync = ref.watch(myChildrenProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "My Children",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Only show small "Add" button if we already have children
            childrenAsync.when(
              data: (list) => list.isNotEmpty
                  ? TextButton.icon(
                      onPressed: () =>
                          context.push('/add-student'), // Your route
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text("Add"),
                    )
                  : const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Content Area
        childrenAsync.when(
          data: (children) {
            if (children.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildChildrenList(children);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Text('Error loading children: $err'),
          ),
        ),
      ],
    );
  }

  // --- THE "NO CHILDREN YET" WIDGET ---
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.child_care_rounded,
              size: 40,
              color: Colors.orange.shade400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No children added yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your children to start finding\nthe best drivers for them.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/add-student'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text("Add Child Profile"),
            ),
          ),
        ],
      ),
    );
  }

  // --- THE LIST WIDGET (If data exists) ---
  Widget _buildChildrenList(List<ChildModel> children) {
    return SizedBox(
      height: 110,
      width: double.infinity,
      child: Center(
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: children.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final child = children[index];
            return _buildChildCard(context, child);
          },
        ),
      ),
    );
  }

  Widget _buildChildCard(BuildContext context, ChildModel child) {
    final isFemale = child.gender?.toLowerCase() == 'female';
    final color = isFemale ? Colors.pink : Colors.blue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showChildOptions(context, child),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 130, // Fixed width for uniform cards
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withOpacity(0.1),
                backgroundImage: child.photoUrl != null
                    ? NetworkImage(child.photoUrl!)
                    : null,
                child: child.photoUrl == null
                    ? Text(
                        child.name[0].toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 6),
              // Name
              Text(
                child.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              // School/Grade
              Text(
                child.grade.isNotEmpty ? child.grade : child.schoolName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChildOptions(BuildContext context, ChildModel child) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.red.shade400,
                ),
              ),
              title: const Text('Report Absence'),
              subtitle: const Text('Mark a day your child won\'t ride'),
              onTap: () {
                Navigator.pop(context);
                // Open the SetAbsenceScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SetAbsenceScreen(
                      childId: child.id,
                      childName: child.name,
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.orange),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                context.push('/edit-student', extra: child);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
