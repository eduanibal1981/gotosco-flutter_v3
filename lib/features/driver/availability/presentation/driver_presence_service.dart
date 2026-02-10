import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'driver_availability_controller.dart';

/// Service to handle Driver App Online Status based on lifecycle
class DriverUserPresenceService extends WidgetsBindingObserver {
  final Ref ref;

  DriverUserPresenceService(this.ref);

  void init() {
    WidgetsBinding.instance.addObserver(this);
    _setOnline(true);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setOnline(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _setOnline(true);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _setOnline(false);
        break;
      case AppLifecycleState.inactive:
        // Optional: treat inactive as offline or keep online?
        // Usually inactive is brief (multitasking view), keep online or ignore.
        break;
      case AppLifecycleState.hidden:
        // Hidden is usually minimized but not fully paused yet on some platforms
        // Treat as background?
        // _setOnline(false);
        break;
    }
  }

  void _setOnline(bool isOnline) {
    // Only update if current user is a driver (or has availability controller)
    // We can just call the controller method.
    try {
      ref
          .read(driverAvailabilityControllerProvider.notifier)
          .setUserAppOnline(isOnline);
    } catch (e) {
      // Controller might not be mounted or available if logged out
    }
  }
}

final driverUserPresenceServiceProvider =
    Provider.autoDispose<DriverUserPresenceService>((ref) {
      final service = DriverUserPresenceService(ref);
      service.init();
      ref.onDispose(() => service.dispose());
      return service;
    });
