import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/driver_location_model.dart';
import 'tracking_controller.dart';
import 'widgets/tracking_info_card.dart';

/// Live tracking screen that displays the driver's real-time location on a map.
/// Uses Supabase Realtime to stream location updates with efficient marker-only repaints.
class LiveTrackingScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String driverId;
  final String driverName;
  final String? driverPhotoUrl;
  final LatLng? homeLocation;
  final LatLng? schoolLocation;

  const LiveTrackingScreen({
    super.key,
    required this.bookingId,
    required this.driverId,
    required this.driverName,
    this.driverPhotoUrl,
    this.homeLocation,
    this.schoolLocation,
  });

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng? _previousPosition;
  late AnimationController _markerAnimationController;
  late Animation<double> _markerAnimation;

  // Default center (Muscat, Oman)
  static const _defaultCenter = LatLng(23.5880, 58.3829);

  @override
  void initState() {
    super.initState();
    _markerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _markerAnimation = CurvedAnimation(
      parent: _markerAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _markerAnimationController.dispose();
    super.dispose();
  }

  void _animateToPosition(LatLng newPosition) {
    if (_previousPosition != null) {
      _markerAnimationController.forward(from: 0);
    }
    _previousPosition = newPosition;

    // Smoothly move map to follow driver
    _mapController.move(newPosition, _mapController.camera.zoom);
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(driverLocationProvider(widget.driverId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Driver'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Simulation button for testing
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            tooltip: 'Simulate Movement',
            onPressed: () => _showSimulationDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map Layer
          locationAsync.when(
            data: (location) => _buildMap(location),
            loading: () => _buildMap(null),
            error: (error, _) => _buildMapWithError(error.toString()),
          ),

          // Loading Overlay
          if (locationAsync.isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            ),

          // Bottom Info Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: TrackingInfoCard(
              driverName: widget.driverName,
              driverPhotoUrl: widget.driverPhotoUrl,
              status: locationAsync.when(
                data: (_) => 'On the way',
                loading: () => 'Connecting...',
                error: (_, __) => 'Connection lost',
              ),
              eta: '5 min', // TODO: Calculate actual ETA
              onCallPressed: () {
                // TODO: Implement call driver
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calling driver...')),
                );
              },
              onCancelPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(DriverLocation? driverLocation) {
    final driverPosition = driverLocation?.position;

    if (driverPosition != null && _previousPosition != driverPosition) {
      // Schedule animation after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateToPosition(driverPosition);
      });
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: driverPosition ?? widget.homeLocation ?? _defaultCenter,
        initialZoom: 15.0,
      ),
      children: [
        // OpenStreetMap Tiles
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.gotosco_v3',
        ),

        // Markers Layer
        MarkerLayer(
          markers: [
            // Driver Marker (animated)
            if (driverPosition != null)
              Marker(
                point: driverPosition,
                width: 50,
                height: 50,
                child: AnimatedBuilder(
                  animation: _markerAnimation,
                  builder: (context, child) => child!,
                  child: _buildDriverMarker(),
                ),
              ),

            // Home Location Marker
            if (widget.homeLocation != null)
              Marker(
                point: widget.homeLocation!,
                width: 40,
                height: 40,
                child: _buildLocationMarker(
                  icon: Icons.home,
                  color: Colors.green,
                ),
              ),

            // School Location Marker
            if (widget.schoolLocation != null)
              Marker(
                point: widget.schoolLocation!,
                width: 40,
                height: 40,
                child: _buildLocationMarker(
                  icon: Icons.school,
                  color: Colors.orange,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapWithError(String error) {
    return Stack(
      children: [
        _buildMap(null),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.indigo,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.directions_bus, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildLocationMarker({required IconData icon, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  void _showSimulationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simulate Driver Movement'),
        content: const Text(
          'This will simulate the driver moving from the current position '
          'to the home location. Use this for testing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startSimulation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Simulation'),
          ),
        ],
      ),
    );
  }

  void _startSimulation() {
    final home = widget.homeLocation ?? _defaultCenter;

    // Start from a position offset from home
    final startLat = home.latitude + 0.01; // ~1km offset
    final startLng = home.longitude + 0.01;

    ref
        .read(trackingControllerProvider.notifier)
        .startSimulation(
          driverId: widget.driverId,
          startLat: startLat,
          startLng: startLng,
          endLat: home.latitude,
          endLng: home.longitude,
          steps: 15,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulation started! Watch the bus move.'),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
