// lib/features/parent/dashboard/presentation/widgets/today_trip_list.dart
import 'package:flutter/material.dart';

class TodayTripList extends StatelessWidget {
  const TodayTripList({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = [
      {
        'tripName': 'Morning School Run',
        'time': '07:30 AM',
        'type': 'Pickup',
        'children': ['Ali', 'Sara'],
        'driver': 'Ahmed',
        'status': 'Done',
      },
      {
        'tripName': 'Football Training',
        'time': '04:00 PM',
        'type': 'Drop-off',
        'children': ['Ali'],
        'driver': 'Khalid',
        'status': 'Scheduled',
      },
    ];

    return Column(children: trips.map((trip) => _buildTripTile(trip)).toList());
  }

  Widget _buildTripTile(Map<String, dynamic> trip) {
    final isDone = trip['status'] == 'Done';
    final children = trip['children'] as List<String>;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Time & Status
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  trip['time'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDone ? Colors.green.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trip['status'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDone
                          ? Colors.green.shade700
                          : Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Body: Trip Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    trip['type'] == 'Pickup'
                        ? Icons.home_work_outlined
                        : Icons.school_outlined,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip['tripName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Children Avatars (Mini)
                          ...children.map(
                            (child) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.grey.shade200,
                                child: Text(
                                  child[0],
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            ' • ${children.join(" & ")}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
