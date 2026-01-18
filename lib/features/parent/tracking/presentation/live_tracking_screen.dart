import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/driver_location_model.dart';
import '../data/tracking_repository.dart';
import 'tracking_controller.dart';
import 'widgets/tracking_info_card.dart';

/// Live tracking screen that displays the driver's real-time location on a map.
/// Uses Supabase Realtime for instant location updates.
class LiveTrackingScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String driverId;

  const LiveTrackingScreen({
    super.key,
    required this.bookingId,
    required this.driverId,
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
  bool _hasMovedToDriver = false;

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

    // Only auto-move on first location or if user hasn't manually zoomed/panned
    if (!_hasMovedToDriver) {
      _mapController.move(newPosition, 15.0);
      _hasMovedToDriver = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(driverLocationProvider(widget.driverId));
    final bookingLocationsAsync = ref.watch(
      bookingLocationsProvider(widget.bookingId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Driver'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Re-center button
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Re-center on driver',
            onPressed: () {
              _hasMovedToDriver = false;
              if (_previousPosition != null) {
                _mapController.move(_previousPosition!, 15.0);
                _hasMovedToDriver = true;
              }
            },
          ),
        ],
      ),
      body: bookingLocationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.indigo),
        ),
        error: (error, _) =>
            Center(child: Text('Error loading booking: $error')),
        data: (bookingLocations) => Stack(
          children: [
            // Map Layer
            locationAsync.when(
              data: (location) => _buildMap(location, bookingLocations),
              loading: () => _buildMap(null, bookingLocations),
              error: (error, _) =>
                  _buildMapWithError(error.toString(), bookingLocations),
            ),

            // Loading Overlay (only when loading driver location)
            if (locationAsync.isLoading && !locationAsync.hasValue)
              const Center(
                child: CircularProgressIndicator(color: Colors.indigo),
              ),

            // Bottom Info Card
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildInfoCard(locationAsync, bookingLocations),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    AsyncValue<DriverLocation> locationAsync,
    BookingLocations bookingLocations,
  ) {
    final driverName = bookingLocations.driverName ?? 'Driver';

    String eta = '--';

    // Determine status based on async state
    final String status = locationAsync.when(
      data: (location) {
        if (!location.isOnline) {
          return 'Driver offline';
        }
        // Calculate ETA
        final destination = _getDestination(location, bookingLocations);
        if (destination != null) {
          final repo = ref.read(trackingRepositoryProvider);
          final etaMinutes = repo.calculateEtaMinutes(location, destination);
          if (etaMinutes != null) {
            eta = '${etaMinutes.round()} min';
          }
        }

        // Determine status based on trip type
        switch (location.tripType) {
          case 'pickup':
            return 'Coming to pick up';
          case 'dropoff':
            return 'Heading to school';
          default:
            return 'On the way';
        }
      },
      loading: () => 'Connecting...',
      error: (e, _) => 'Offline',
    );

    return TrackingInfoCard(
      driverName: driverName,
      driverPhotoUrl: null,
      status: status,
      eta: eta,
      onCallPressed: () async {
        final phone = bookingLocations.driverPhone;
        if (phone != null && phone.isNotEmpty) {
          // Remove spaces, dashes, parentheses to ensure valid tel URI
          final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
          final uri = Uri(scheme: 'tel', path: cleanPhone);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not launch phone app')),
              );
            }
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Driver phone number not available')),
            );
          }
        }
      },
      onCancelPressed: () => Navigator.pop(context),
    );
  }

  /// Determines the destination based on trip type.
  /// - pickup: Driver is going to home location
  /// - dropoff: Driver is going to school location
  LatLng? _getDestination(DriverLocation location, BookingLocations booking) {
    switch (location.tripType) {
      case 'pickup':
        return booking.home;
      case 'dropoff':
        return booking.school;
      default:
        // If idle or unknown, assume closest destination
        return booking.home ?? booking.school;
    }
  }

  Widget _buildMap(
    DriverLocation? driverLocation,
    BookingLocations bookingLocations,
  ) {
    final driverPosition = driverLocation?.position;

    if (driverPosition != null && _previousPosition != driverPosition) {
      // Schedule animation after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateToPosition(driverPosition);
      });
    }

    // Determine initial center
    LatLng initialCenter =
        driverPosition ??
        bookingLocations.home ??
        bookingLocations.school ??
        _defaultCenter;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: initialCenter, initialZoom: 15.0),
      children: [
        // OpenStreetMap Tiles with cancellable provider for better web performance
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.gotosco_v3',
          // Use cancellable tile provider for better performance on web
          tileProvider: CancellableNetworkTileProvider(),
          // Evict error tiles to prevent stuck loading states
          evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
          // Reduce tile requests on web
          keepBuffer: kIsWeb ? 2 : 5,
        ),

        // OpenStreetMap Attribution (Required)
        SimpleAttributionWidget(
          source: const Text('© OpenStreetMap'),
          onTap: () =>
              launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
        ),

        // Markers Layer
        MarkerLayer(
          markers: [
            // Driver Marker (animated with rotation)
            if (driverPosition != null && driverLocation != null)
              Marker(
                point: driverPosition,
                width: 50,
                height: 50,
                child: AnimatedBuilder(
                  animation: _markerAnimation,
                  builder: (context, child) => child!,
                  child: _buildDriverMarker(driverLocation.heading),
                ),
              ),

            // Home Location Marker
            if (bookingLocations.home != null)
              Marker(
                point: bookingLocations.home!,
                width: 40,
                height: 40,
                child: _buildLocationMarker(
                  icon: Icons.home,
                  color: Colors.green,
                  label: 'Home',
                ),
              ),

            // School Location Marker
            if (bookingLocations.school != null)
              Marker(
                point: bookingLocations.school!,
                width: 40,
                height: 40,
                child: _buildLocationMarker(
                  icon: Icons.school,
                  color: Colors.orange,
                  label: 'School',
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapWithError(String error, BookingLocations bookingLocations) {
    return Stack(
      children: [
        _buildMap(null, bookingLocations),
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

  Widget _buildDriverMarker(double heading) {
    return Transform.rotate(
      angle: heading * (math.pi / 180), // Convert degrees to radians
      child: Container(
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
      ),
    );
  }

  Widget _buildLocationMarker({
    required IconData icon,
    required Color color,
    String? label,
  }) {
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
}
