class ParentNextStopInfo {
  final bool nextStopIsParent;
  final String? nextStopLabel;
  final int? stopsUntilParent;
  final int? etaMinutes;
  final String? tripType; // 'Go to School(s)' | 'Return from School(s)'
  final String? stopType; // 'pickup' | 'dropoff'
  final String? stopStatus; // 'pending' | 'arrived'

  ParentNextStopInfo({
    required this.nextStopIsParent,
    this.nextStopLabel,
    this.stopsUntilParent,
    this.etaMinutes,
    this.tripType,
    this.stopType,
    this.stopStatus,
  });

  /// Returns true for morning Go trips, false for afternoon Return trips
  bool get isGoTrip => tripType?.contains('Go') ?? false;

  /// Returns true for afternoon Return trips
  bool get isReturnTrip => tripType?.contains('Return') ?? false;

  /// Returns a user-friendly destination description
  String get destinationLabel {
    if (isGoTrip) return 'school';
    if (isReturnTrip) return 'home';
    return 'destination';
  }

  factory ParentNextStopInfo.fromMap(Map<String, dynamic> map) {
    return ParentNextStopInfo(
      nextStopIsParent: map['next_stop_is_parent'] as bool? ?? false,
      nextStopLabel: map['next_stop_label'] as String?,
      stopsUntilParent: map['stops_until_parent'] as int?,
      etaMinutes: map['eta_minutes'] as int?,
      tripType: map['trip_type'] as String?,
      stopType: map['stop_type'] as String?,
      stopStatus: map['stop_status'] as String?,
    );
  }
}
