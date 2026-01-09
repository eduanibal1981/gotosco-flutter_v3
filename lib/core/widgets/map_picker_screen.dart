import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(23.5880, 58.3829); // Default: Muscat
  // CHANGE 1: Set this to false so the map shows immediately
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // CHANGE 3: Keep this commented out so it doesn't ask for permissions immediately
    // _locateUser();
  }

  Future<void> _locateUser() async {
    // CHANGE 2: Manually start loading only when this function is called
    setState(() => _isLoading = true);
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentCenter = LatLng(pos.latitude, pos.longitude);
        _isLoading = false;
      });
      // Move map to user
      _mapController.move(_currentCenter, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15.0,
              onPositionChanged: (position, hasGesture) {
                _currentCenter = position.center;
              },
              // Enable scroll wheel zoom
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.gotosco_v3',
                // Use cancellable tile provider for better performance on web
                tileProvider: CancellableNetworkTileProvider(),
                // Evict error tiles to prevent stuck loading states
                evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
                // Reduce tile requests on web
                keepBuffer: kIsWeb ? 2 : 5,
                // Fix blurry tiles on high-density screens (Android/iOS)
                retinaMode: !kIsWeb, // Enable retina mode for mobile
              ),
              // OpenStreetMap Attribution (Required)
              SimpleAttributionWidget(
                source: const Text('© OpenStreetMap'),
                onTap: () =>
                    launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
              ),
            ],
          ),
          // Center Marker (Fixed)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40), // Offset for pin point
              child: Icon(Icons.location_on, size: 50, color: Colors.red),
            ),
          ),
          // Loading Overlay
          if (_isLoading) const Center(child: CircularProgressIndicator()),

          // Confirm Button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                // Return the selected LatLng
                Navigator.pop(context, _currentCenter);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Confirm Location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Locate Me Button
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _locateUser,
              child: const Icon(Icons.my_location, color: Colors.indigo),
            ),
          ),
        ],
      ),
    );
  }
}
