import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/active_trip_controller.dart';

class TripStopReorderScreen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> stops;
  final String tripType;

  const TripStopReorderScreen({
    super.key,
    required this.stops,
    required this.tripType,
  });

  @override
  ConsumerState<TripStopReorderScreen> createState() =>
      _TripStopReorderScreenState();
}

class _TripStopReorderScreenState extends ConsumerState<TripStopReorderScreen> {
  late List<Map<String, dynamic>> _pickupStops;
  late List<Map<String, dynamic>> _dropoffStops;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Filter pending stops
    final pendingStops = widget.stops
        .where((s) => s['status'] == 'pending')
        .toList();

    // Split into Pickups and Dropoffs
    _pickupStops = pendingStops
        .where((s) => s['stop_type'] == 'pickup')
        .toList();
    _dropoffStops = pendingStops
        .where((s) => s['stop_type'] == 'dropoff')
        .toList();

    // Sort initially by sequence
    _pickupStops.sort(
      (a, b) =>
          (a['sequence_order'] as int).compareTo(b['sequence_order'] as int),
    );
    _dropoffStops.sort(
      (a, b) =>
          (a['sequence_order'] as int).compareTo(b['sequence_order'] as int),
    );
  }

  String _getChildName(Map<String, dynamic> stop) {
    final childData = stop['children'];
    if (childData == null) return "Student";
    if (childData is Map) {
      return childData['name']?.toString() ?? "Student";
    } else if (childData is List && childData.isNotEmpty) {
      return childData[0]['name']?.toString() ?? "Student";
    }
    return "Student";
  }

  String _getLocationLabel(Map<String, dynamic> stop) {
    final stopType = stop['stop_type'] as String;
    final booking = stop['bookings'];
    if (booking == null) return stopType.toUpperCase();

    final homeTxt = booking['hometxt_location'] as String? ?? '';
    final schoolTxt = booking['schooltxt_location'] as String? ?? '';

    if (widget.tripType == 'Go to School(s)') {
      if (stopType == 'pickup') return homeTxt.isNotEmpty ? homeTxt : "Home";
      if (stopType == 'dropoff')
        return schoolTxt.isNotEmpty ? schoolTxt : "School";
    } else if (widget.tripType == 'Return from School(s)') {
      if (stopType == 'pickup')
        return schoolTxt.isNotEmpty ? schoolTxt : "School";
      if (stopType == 'dropoff') return homeTxt.isNotEmpty ? homeTxt : "Home";
    }
    return stopType.toUpperCase();
  }

  Future<void> _saveOrder() async {
    setState(() => _isSaving = true);

    try {
      // Find the starting sequence number (min of all pending)
      int startSequence = 1;
      final allPending = [..._pickupStops, ..._dropoffStops];

      if (allPending.isNotEmpty) {
        final pendingSequences = widget.stops
            .where((s) => s['status'] == 'pending')
            .map((s) => s['sequence_order'] as int)
            .toList();
        if (pendingSequences.isNotEmpty) {
          startSequence = pendingSequences.reduce((a, b) => a < b ? a : b);
        }
      }

      final updates = <Map<String, dynamic>>[];

      // Assign sequences: Pickups first, then Dropoffs
      int currentSeq = startSequence;

      // 1. Process Pickups
      for (var stop in _pickupStops) {
        updates.add({'id': stop['id'], 'sequence_order': currentSeq++});
      }

      // 2. Process Dropoffs
      for (var stop in _dropoffStops) {
        updates.add({'id': stop['id'], 'sequence_order': currentSeq++});
      }

      await ref
          .read(activeTripControllerProvider.notifier)
          .reorderStops(updates);

      if (mounted) {
        context.pop(); // Go back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Route updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating route: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildList(List<Map<String, dynamic>> stops, String title) {
    if (stops.isEmpty) return const SizedBox.shrink();

    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: true,
          itemCount: stops.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = stops.removeAt(oldIndex);
              stops.insert(newIndex, item);
            });
          },
          itemBuilder: (context, index) {
            final stop = stops[index];
            return ListTile(
              key: ValueKey(stop['id']),
              leading: const Icon(Icons.drag_handle, color: Colors.grey),
              title: Text(
                _getChildName(stop),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(_getLocationLabel(stop)),
              trailing: Chip(
                label: Text(
                  stop['stop_type'].toString().toUpperCase(),
                  style: const TextStyle(fontSize: 10),
                ),
                backgroundColor: Colors.grey.shade200,
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Optimize Route"),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _saveOrder),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildList(_pickupStops, "Pickups"),
            _buildList(_dropoffStops, "Dropoffs"),
            if (_pickupStops.isEmpty && _dropoffStops.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text("No pending stops to reorder."),
              ),
          ],
        ),
      ),
    );
  }
}
