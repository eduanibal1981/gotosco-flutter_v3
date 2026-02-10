import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart'; // Add Geolocator
import 'dart:async'; // Add async
import '../../data/models/driver_trip_model.dart';
import '../controllers/active_trip_controller.dart';
import 'trip_stop_reorder_screen.dart';

class ActiveTripScreen extends ConsumerStatefulWidget {
  const ActiveTripScreen({super.key});

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen> {
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startLocationUpdates() async {
    // Ensure permissions
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied) return;
    }

    // Start listening
    // settings: distanceFilter: 10 meters to reduce jitter
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: settings).listen((
          Position? position,
        ) {
          if (position != null) {
            // Feed to controller for geofence check
            ref
                .read(activeTripControllerProvider.notifier)
                .checkArrivalGeofence(position.latitude, position.longitude);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(activeTripControllerProvider);
    final controller = ref.read(activeTripControllerProvider.notifier);

    return tripAsync.when(
      data: (trip) {
        if (trip == null) {
          return const Center(child: Text("No active trip found."));
        }

        final currentStop = controller.currentStop;
        final stops = trip.routeStops;

        // Filter stops to show only pending/arrived/skipped (hide completed unless we want history)
        final upcomingStops = stops.where((s) {
          final status = s.status;
          return status == 'pending' || status == 'arrived';
        }).toList();

        // Sort: current stop first, then by sequence
        upcomingStops.sort(
          (a, b) => (a.sequenceOrder ?? 0).compareTo(b.sequenceOrder ?? 0),
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text("Active Trip"),
            actions: [
              IconButton(
                icon: const Icon(Icons.map),
                onPressed: () => _launchMaps(currentStop),
              ),
              IconButton(
                icon: const Icon(Icons.edit_road),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TripStopReorderScreen(
                        tripId: trip.id,
                        stops: trip.routeStops.map((s) => s.toJson()).toList(),
                        tripType: trip.tripType,
                      ),
                    ),
                  );
                },
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'end') {
                    _confirmEndTrip(context, ref, trip.id);
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
                _buildCurrentStopCard(context, ref, currentStop, trip.tripType)
              else
                _buildTripCompletedCard(context, ref, trip.id),

              const Divider(height: 1, thickness: 1),

              // 2. Upcoming Stops (Grouped)
              if (currentStop != null) ...[
                Builder(
                  builder: (context) {
                    // Filter out current stop
                    final nextStops = upcomingStops
                        .where((s) => s.id != currentStop.id)
                        .toList();

                    if (nextStops.isEmpty) {
                      return const Expanded(child: SizedBox());
                    }

                    final pickups = nextStops
                        .where((s) => s.stopType == 'pickup')
                        .toList();
                    final dropoffs = nextStops
                        .where((s) => s.stopType == 'dropoff')
                        .toList();

                    return Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (pickups.isNotEmpty)
                              _buildStopGroup(
                                "Pickups",
                                pickups,
                                trip.tripType,
                              ),
                            if (dropoffs.isNotEmpty)
                              _buildStopGroup(
                                "Dropoffs",
                                dropoffs,
                                trip.tripType,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ] else ...[
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
    RouteStop stop,
    String tripType,
  ) {
    final status = stop.status ?? 'pending';
    final locationLabel = _getLocationLabel(stop, tripType);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.indigo.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "STOP #${stop.sequenceOrder ?? 0}",
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

          // Location Label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              locationLabel,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
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
                      .arriveAtStop(stop.id);
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
                            .processStop(stop.id, 'skipped');
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
                        final action = stop.stopType == 'pickup'
                            ? 'picked_up'
                            : 'dropped_off';
                        ref
                            .read(activeTripControllerProvider.notifier)
                            .processStop(stop.id, action);
                      },
                      icon: const Icon(Icons.check),
                      label: Text(
                        stop.stopType == 'pickup' ? "PICK UP" : "DROP OFF",
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

  String _getChildName(RouteStop stop) {
    // Use the childName field from the RouteStop model
    return stop.childName ?? "Student";
  }

  String _getLocationLabel(RouteStop stop, String tripType) {
    final stopType = stop.stopType ?? '';

    // Use the location fields from RouteStop
    final homeLocation = stop.homeLocation ?? '';
    final schoolLocation = stop.schoolLocation ?? '';

    if (tripType == 'Go to School(s)') {
      if (stopType == 'pickup') {
        return homeLocation.isNotEmpty ? homeLocation : "Home";
      }
      if (stopType == 'dropoff') {
        return schoolLocation.isNotEmpty ? schoolLocation : "School";
      }
    } else if (tripType == 'Return from School(s)') {
      if (stopType == 'pickup') {
        return schoolLocation.isNotEmpty ? schoolLocation : "School";
      }
      if (stopType == 'dropoff') {
        return homeLocation.isNotEmpty ? homeLocation : "Home";
      }
    }

    return stopType.toUpperCase();
  }

  Widget _buildStopListTile(RouteStop stop, int index, String tripType) {
    // Determine title
    final childName = _getChildName(stop);
    final locationLabel = _getLocationLabel(stop, tripType);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Text((stop.sequenceOrder ?? 0).toString()),
      ),
      title: Text(childName),
      subtitle: Text(
        locationLabel,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: stop.status == 'completed'
          ? const Icon(Icons.check_circle, color: Colors.green)
          : stop.status == 'skipped'
          ? const Icon(Icons.cancel, color: Colors.red)
          : null,
    );
  }

  Widget _buildStopGroup(String title, List<RouteStop> stops, String tripType) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
      children: stops.map((stop) {
        return _buildStopListTile(stop, stop.sequenceOrder ?? 0, tripType);
      }).toList(),
    );
  }

  Future<void> _launchMaps(RouteStop? stop) async {
    if (stop == null) return;
    final lat = stop.latitude;
    final lng = stop.longitude;
    if (lat == null || lng == null) return;

    // 1. Try Native Google Maps Navigation Intent (Android)
    final Uri nativeUri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");

    // 2. Fallback Web URL (iOS / Browser)
    final Uri webUri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving",
    );

    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error launching maps: $e");
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
