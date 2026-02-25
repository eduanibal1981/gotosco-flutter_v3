class ParentNextStopInfo {
  final String? statusBadge;
  final String? uiTitle;
  final String? uiSubtitle;
  final int? stopsUntil;
  final int? etaMinutes;
  final bool isGoTrip;

  ParentNextStopInfo({
    this.statusBadge,
    this.uiTitle,
    this.uiSubtitle,
    this.stopsUntil,
    this.etaMinutes,
    this.isGoTrip = true,
  });

  bool get isReturnTrip => !isGoTrip;

  factory ParentNextStopInfo.fromMap(Map<String, dynamic> map) {
    //debugPrint('map: $map');
    return ParentNextStopInfo(
      statusBadge: map['status_badge'] as String?,
      uiTitle: map['ui_title'] as String?,
      uiSubtitle: map['ui_subtitle'] as String?,
      stopsUntil: map['stops_until'] as int?,
      etaMinutes: map['eta_minutes'] as int?,
      isGoTrip: map['is_go_trip'] as bool? ?? true,
    );
  }
}
