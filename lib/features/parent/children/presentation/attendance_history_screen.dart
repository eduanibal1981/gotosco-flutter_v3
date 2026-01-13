import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../data/attendance_model.dart';
import 'children_controller.dart';

class AttendanceHistoryScreen extends ConsumerStatefulWidget {
  final String childId;
  final String childName;

  const AttendanceHistoryScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  ConsumerState<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends ConsumerState<AttendanceHistoryScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  /// Get events for a specific day
  List<AttendanceRecord> _getEventsForDay(
    List<AttendanceRecord> events,
    DateTime day,
  ) {
    return events.where((event) {
      return isSameDay(event.timestamp, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(
      attendanceHistoryProvider(widget.childId),
    );

    return Scaffold(
      appBar: AppBar(title: Text('${widget.childName}\'s Activity')),
      body: attendanceAsync.when(
        data: (attendanceRecords) {
          return Column(
            children: [
              TableCalendar<AttendanceRecord>(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now(),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                  // CalendarFormat.twoWeeks: '2 Weeks',
                  // CalendarFormat.week: 'Week',
                },
                eventLoader: (day) => _getEventsForDay(attendanceRecords, day),
                startingDayOfWeek: StartingDayOfWeek.sunday, // Start on Sunday
                calendarStyle: const CalendarStyle(
                  // Use markers to show presence
                  markerDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        bottom: 1,
                        child: _buildEventsMarker(events),
                      );
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(child: _buildEventList(attendanceRecords)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEventsMarker(List<AttendanceRecord> events) {
    // Check if there are any 'picked_up' events (Green)
    final hasPickup = events.any((e) => e.eventType == 'picked_up');
    final hasDropoff = events.any((e) => e.eventType == 'dropped_off');

    Color markerColor = Colors.grey;
    if (hasPickup && hasDropoff) {
      markerColor = Colors.green; // Complete trip
    } else if (hasPickup) {
      markerColor = Colors.orange; // Picked up but no dropoff yet?
    } else if (hasDropoff) {
      markerColor = Colors.blue; // Dropped off
    } else if (events.any((e) => e.eventType == 'approaching')) {
      return Container(); // Don't mark just for approaching
    }

    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: markerColor),
      width: 7.0,
      height: 7.0,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
    );
  }

  Widget _buildEventList(List<AttendanceRecord> allRecords) {
    if (_selectedDay == null) return Container();

    final events = _getEventsForDay(allRecords, _selectedDay!);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_toggle_off,
                size: 40,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No activity recorded",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "There are no attendance events for this day.",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    // Sort by time
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return ListTile(
          leading: Icon(
            _getEventIcon(event.eventType),
            color: _getEventColor(event.eventType),
          ),
          title: Text(_getEventTitle(event.eventType)),
          subtitle: Text(DateFormat('hh:mm a').format(event.timestamp)),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'picked_up':
        return Icons.directions_bus;
      case 'dropped_off':
        return Icons.school; // or home icon
      case 'approaching':
        return Icons.access_time;
      default:
        return Icons.info;
    }
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'picked_up':
        return Colors.green;
      case 'dropped_off':
        return Colors.blue;
      case 'approaching':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getEventTitle(String type) {
    switch (type) {
      case 'picked_up':
        return 'Picked Up';
      case 'dropped_off':
        return 'Dropped Off';
      case 'approaching':
        return 'Driver Approaching';
      default:
        return type;
    }
  }
}
