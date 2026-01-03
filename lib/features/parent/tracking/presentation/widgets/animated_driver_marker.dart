import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Animated marker widget that smoothly transitions between positions.
/// Uses TweenAnimationBuilder for smooth interpolation.
class AnimatedDriverMarker extends StatelessWidget {
  final LatLng position;
  final Duration animationDuration;
  final Widget? child;

  const AnimatedDriverMarker({
    super.key,
    required this.position,
    this.animationDuration = const Duration(milliseconds: 800),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<LatLng>(
      tween: LatLngTween(end: position),
      duration: animationDuration,
      builder: (context, animatedPosition, child) {
        // This widget is used inside the MarkerLayer's builders
        // The actual positioning is handled by the parent Marker widget
        return child ?? _defaultMarker(context);
      },
      child: child ?? _defaultMarker(context),
    );
  }

  Widget _defaultMarker(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.indigo,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.directions_bus, color: Colors.white, size: 28),
    );
  }
}

/// Custom Tween for animating LatLng positions.
class LatLngTween extends Tween<LatLng> {
  LatLngTween({super.begin, required LatLng end}) : super(end: end);

  @override
  LatLng lerp(double t) {
    final startLat = begin?.latitude ?? end!.latitude;
    final startLng = begin?.longitude ?? end!.longitude;
    final endLat = end!.latitude;
    final endLng = end!.longitude;

    return LatLng(
      startLat + (endLat - startLat) * t,
      startLng + (endLng - startLng) * t,
    );
  }
}
