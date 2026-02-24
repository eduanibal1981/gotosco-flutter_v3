class AttendanceRecord {
  final String id;
  final String childId;
  final String eventType; // 'picked_up', 'dropped_off'
  final DateTime timestamp;
  final String driverId;

  AttendanceRecord({
    required this.id,
    required this.childId,
    required this.eventType,
    required this.timestamp,
    required this.driverId,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as String,
      childId: map['child_id'] as String,
      eventType: map['event_type'] as String,
      timestamp: DateTime.parse(map['created_at'] as String).toLocal(),
      driverId: map['driver_id'] as String,
    );
  }
}
