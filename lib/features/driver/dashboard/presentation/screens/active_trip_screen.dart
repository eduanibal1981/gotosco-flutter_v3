import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/active_trip_controller.dart';

class ActiveTripScreen extends ConsumerWidget {
  const ActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(activeTripControllerProvider);
    final controller = ref.read(activeTripControllerProvider.notifier);

    return tripAsync.when(
      data: (trip) {
        if (trip == null) {
          return const Center(child: Text("No active trip found."));
        }

        final currentStop = controller.currentStop;
        final stops = (trip['route_stops'] as List<dynamic>?) ?? [];

        // Filter stops to show only pending/arrived/skipped (hide completed unless we want history)
        final upcomingStops = stops.where((s) {
          final status = s['status'] as String;
          return status == 'pending' || status == 'arrived';
        }).toList();

        // Sort: current stop first, then by sequence
        upcomingStops.sort(
          (a, b) => (a['sequence_order'] as int).compareTo(
            b['sequence_order'] as int,
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text("Active Trip"),
            actions: [
              IconButton(
                icon: const Icon(Icons.map),
                onPressed: () => _launchMaps(currentStop),
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'end') {
                    _confirmEndTrip(context, ref, trip['id']);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'end',
                    child: Text("End Trip Forcefully"),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // 1. Current Stop Card (Big)
              if (currentStop != null)
                _buildCurrentStopCard(context, ref, currentStop)
              else
                _buildTripCompletedCard(context, ref, trip['id']),

              const Divider(height: 1, thickness: 1),

              // 2. Upcoming Stops Header
              if (currentStop != null && upcomingStops.length > 1) ...[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Next Stops",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: upcomingStops.length,
                    itemBuilder: (context, index) {
                      final stop = upcomingStops[index];
                      if (stop['id'] == currentStop['id'])
                        return const SizedBox.shrink(); // Skip current
                      return _buildStopListTile(stop, index + 1);
                    },
                  ),
                ),
              ] else if (currentStop == null) ...[
                const Expanded(child: SizedBox()), // Spacer
              ],
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text("Error: $e"))),
    );
  }

  Widget _buildCurrentStopCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> stop,
  ) {
    final status = stop['status'] as String;
    // We need to fetch child info. Since the RPC return includes join?
    // The query in repo was `select('*, route_stops(*)')`.
    // It does NOT join children/bookings deep.
    // We might need to fetch child details or rely on them being present if the view provides them
    // OR we just use the child_id and generic text for now is safer if we didn't update query.
    // Actually, `activeTrip` provider in repo:
    // .select('*, route_stops(*)')
    // It does NOT include child name. That's a problem for the UI.
    // The previous implementation used separate fetches.
    // I should update the repo to fetch embedded data OR fetch it here.
    // For now, I'll assume we might need to fetch it or it's missing.
    // Let's assume the user wants the flow first, visual polish later.
    // I'll show "Student at Stop #${stop['sequence_order']}".

    // WAIT: `generate_go_trips` puts data in `route_stops`. It doesn't put name.
    // We heavily need child data.
    // I will add a TODO or try to map it if possible.

    // Ideally the repository `getActiveTrip` should use `.select('*, route_stops(*, children(*))')` if relations exist.
    // `booking_id` and `child_id` are in route_stops.

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.indigo.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "STOP #${stop['sequence_order']}",
            style: TextStyle(
              color: Colors.indigo.shade300,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Show Actual Child Name
          Text(
            _getChildName(stop),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: status == 'arrived'
                  ? Colors.orange.shade100
                  : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: status == 'arrived'
                    ? Colors.orange.shade800
                    : Colors.blue.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),

          if (status == 'pending')
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(activeTripControllerProvider.notifier)
                      .arriveAtStop(stop['id']);
                },
                icon: const Icon(Icons.location_on),
                label: const Text("I HAVE ARRIVED"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

          if (status == 'arrived')
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(activeTripControllerProvider.notifier)
                            .processStop(stop['id'], 'skipped');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("SKIP"),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Determine action based on stop_type?
                        // stop_type is in route_stops.
                        final action = stop['stop_type'] == 'pickup'
                            ? 'picked_up'
                            : 'dropped_off';
                        ref
                            .read(activeTripControllerProvider.notifier)
                            .processStop(stop['id'], action);
                      },
                      icon: const Icon(Icons.check),
                      label: Text(
                        stop['stop_type'] == 'pickup' ? "PICK UP" : "DROP OFF",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTripCompletedCard(
    BuildContext context,
    WidgetRef ref,
    String tripId,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          const Text(
            "All Stops Completed!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                _confirmEndTrip(context, ref, tripId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("END TRIP"),
            ),
          ),
        ],
      ),
    );
  }

  String _getChildName(Map<String, dynamic> stop) {
    // Supabase can return joined data as a Map or List depending on relationship
    final childData = stop['children'];
    if (childData == null) return "Student";

    if (childData is Map) {
      return childData['name']?.toString() ?? "Student";
    } else if (childData is List && childData.isNotEmpty) {
      return childData[0]['name']?.toString() ?? "Student";
    }

    return "Student";
  }

  Widget _buildStopListTile(Map<String, dynamic> stop, int index) {
    // Determine title
    String title = "Stop #$index";
    final childName = _getChildName(stop);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Text(stop['sequence_order'].toString()),
      ),
      title: Text(childName),
      subtitle: Text(stop['stop_type'].toString().toUpperCase()),
      trailing: stop['status'] == 'completed'
          ? const Icon(Icons.check_circle, color: Colors.green)
          : stop['status'] == 'skipped'
          ? const Icon(Icons.cancel, color: Colors.red)
          : null,
    );
  }

  Future<void> _launchMaps(Map<String, dynamic>? stop) async {
    if (stop == null) return;
    final lat = stop['location_lat'];
    final lng = stop['location_lng'];
    if (lat == null || lng == null) return;

    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    }
  }

  void _confirmEndTrip(BuildContext context, WidgetRef ref, String tripId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("End Trip?"),
        content: const Text("Are you sure you want to end this trip?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(activeTripControllerProvider.notifier).endTrip(tripId);
            },
            child: const Text("End Trip"),
          ),
        ],
      ),
    );
  }
}
