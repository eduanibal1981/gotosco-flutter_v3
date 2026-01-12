// lib/features/driver/availability/presentation/availability_control_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'driver_availability_controller.dart';

/// Bottom sheet for controlling driver availability settings
class AvailabilityControlSheet extends ConsumerWidget {
  const AvailabilityControlSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AvailabilityControlSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(driverAvailabilityControllerProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: settingsAsync.when(
          data: (settings) => _buildContent(context, ref, settings),
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) =>
              SizedBox(height: 200, child: Center(child: Text('Error: $e'))),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, dynamic settings) {
    final controller = ref.read(driverAvailabilityControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: settings.isOnline
                      ? Colors.green.shade100
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  settings.isOnline ? Icons.wifi : Icons.wifi_off,
                  color: settings.isOnline
                      ? Colors.green.shade700
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Availability Control',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      settings.isSmartMode ? 'Smart Mode' : 'Manual Mode',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Online/Offline Toggle
          _buildMainToggle(context, ref, controller, settings),

          const SizedBox(height: 24),

          // Mode Selector
          _buildModeSelector(context, ref, controller, settings),

          const SizedBox(height: 24),

          // Smart Mode Settings (only visible in smart mode)
          if (settings.isSmartMode) ...[
            _buildSectionTitle('Smart Automation'),
            const SizedBox(height: 12),
            _buildAutoOfflineSetting(context, ref, controller, settings),
            const SizedBox(height: 12),
            _buildAutoOnlineSetting(context, ref, controller, settings),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMainToggle(
    BuildContext context,
    WidgetRef ref,
    DriverAvailabilityController controller,
    dynamic settings,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: settings.isOnline
              ? [Colors.green.shade500, Colors.green.shade600]
              : [Colors.grey.shade400, Colors.grey.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (settings.isOnline ? Colors.green : Colors.grey).withValues(
              alpha: 0.3,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.isOnline ? 'You are Online' : 'You are Offline',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  settings.isOnline
                      ? 'Parents can see you in search'
                      : 'You are hidden from search',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: settings.isOnline,
              onChanged: (_) => controller.toggleOnline(),
              activeColor: Colors.white,
              activeTrackColor: Colors.white.withValues(alpha: 0.4),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(
    BuildContext context,
    WidgetRef ref,
    DriverAvailabilityController controller,
    dynamic settings,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeOption(
              'Smart',
              Icons.auto_awesome,
              settings.isSmartMode,
              () => controller.setMode('smart'),
            ),
          ),
          Expanded(
            child: _buildModeOption(
              'Manual',
              Icons.touch_app,
              settings.isManualMode,
              () => controller.setMode('manual'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.shade500 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildAutoOfflineSetting(
    BuildContext context,
    WidgetRef ref,
    DriverAvailabilityController controller,
    dynamic settings,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.power_settings_new,
              color: Colors.orange.shade700,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Auto go offline after trips',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'When all trips are completed',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: settings.autoOfflineAfterTrip,
            onChanged: (val) => controller.setAutoOffline(val),
            activeColor: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildAutoOnlineSetting(
    BuildContext context,
    WidgetRef ref,
    DriverAvailabilityController controller,
    dynamic settings,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.alarm, color: Colors.blue.shade700, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Auto go online before trips',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${settings.autoOnlineMinutesBefore} min before first trip',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.autoOnlineBeforeTrip,
                onChanged: (val) => controller.setAutoOnline(enabled: val),
                activeColor: Colors.teal,
              ),
            ],
          ),
          if (settings.autoOnlineBeforeTrip) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 48),
                Text(
                  'Minutes before:',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const Spacer(),
                _buildMinutesPicker(context, controller, settings),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMinutesPicker(
    BuildContext context,
    DriverAvailabilityController controller,
    dynamic settings,
  ) {
    final options = [5, 10, 15, 20, 30];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: options.contains(settings.autoOnlineMinutesBefore)
              ? settings.autoOnlineMinutesBefore
              : 15,
          items: options
              .map(
                (min) => DropdownMenuItem(value: min, child: Text('$min min')),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              controller.setAutoOnline(minutesBefore: val);
            }
          },
          isDense: true,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
