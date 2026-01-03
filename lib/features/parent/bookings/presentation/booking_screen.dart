import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:gotosco_v3/features/parent/bookings/presentation/widgets/location_input_field.dart';
import '../../children/data/children_repository.dart';
import '../data/bookings_repository.dart';
import 'bookings_controller.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String driverId;
  final String driverName;

  const BookingScreen({
    super.key,
    required this.driverId,
    required this.driverName,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // NEW: State to store precise coordinates
  double? _homeLat, _homeLng;
  double? _schoolLat, _schoolLng;
  // Form Controllers
  final _notesController = TextEditingController();
  final _homeLocController = TextEditingController();
  final _schoolLocController = TextEditingController();

  // Form State
  String _bookingType = 'Two Way'; // Default
  TimeOfDay? _homePickupTime;
  TimeOfDay? _schoolPickupTime;
  final List<String> _selectedChildIds = [];

  final List<String> _bookingTypes = [
    'Two Way',
    'One Way to School',
    'One Way Back Home',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _homeLocController.dispose();
    _schoolLocController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(bool isHomePickup) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
    );
    if (picked != null) {
      setState(() {
        if (isHomePickup) {
          _homePickupTime = picked;
        } else {
          _schoolPickupTime = picked;
        }
      });
    }
  }

  Future<void> _submitRequest() async {
    try {
      final success = await ref
          .read(bookingsControllerProvider.notifier)
          .submitBooking(
            driverId: widget.driverId,
            childIds: _selectedChildIds,
            bookingType: _bookingType,
            homeLocation: _homeLocController.text.trim(),
            schoolLocation: _schoolLocController.text.trim(),
            homeLat: _homeLat,
            homeLng: _homeLng,
            schoolLat: _schoolLat,
            schoolLng: _schoolLng,
            homePickupTime: _homePickupTime,
            schoolPickupTime: _schoolPickupTime,
            notes: _notesController.text.trim(),
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request Sent!"),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        setState(() {
          _selectedChildIds.clear();
          _notesController.clear();
          _homeLocController.clear();
          _schoolLocController.clear();
          _homePickupTime = null;
          _schoolPickupTime = null;
        });
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book ${widget.driverName}"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.indigo,
          indicatorColor: Colors.indigo,
          tabs: const [
            Tab(text: "Request New"),
            Tab(text: "My Bookings"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestTab(),
          _buildHistoryTab(), // (This method remains the same as previous answer)
        ],
      ),
    );
  }

  Widget _buildRequestTab() {
    final myChildren = ref.watch(myChildrenProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. SELECT CHILDREN
          const Text(
            "Select Children",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: myChildren.when(
              data: (children) {
                if (children.isEmpty)
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No children added yet."),
                  );
                return Column(
                  children: children.map((child) {
                    final isSelected = _selectedChildIds.contains(child.id);
                    return CheckboxListTile(
                      value: isSelected,
                      activeColor: Colors.indigo,
                      title: Text(
                        child.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(child.schoolName),
                      onChanged: (val) {
                        setState(() {
                          val == true
                              ? _selectedChildIds.add(child.id)
                              : _selectedChildIds.remove(child.id);
                        });
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, s) => Text("Error: $e"),
            ),
          ),

          const SizedBox(height: 20),

          // 2. BOOKING TYPE
          const Text(
            "Booking Type",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _bookingType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            items: _bookingTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (val) => setState(() => _bookingType = val!),
          ),

          const SizedBox(height: 20),

          // 3. LOCATIONS
          // REPLACE THE OLD ROW WITH THIS:
          // 3. LOCATIONS
          LocationInputField(
            label: "Home Location",
            controller: _homeLocController,
            onLocationSelected: (lat, lng) {
              setState(() {
                _homeLat = lat;
                _homeLng = lng;
              });
            },
          ),

          const SizedBox(height: 16),

          LocationInputField(
            label: "School Location",
            controller: _schoolLocController,
            onLocationSelected: (lat, lng) {
              setState(() {
                _schoolLat = lat;
                _schoolLng = lng;
              });
            },
          ),

          const SizedBox(height: 20),

          // 4. TIMES (Dynamic based on Type)
          const Text(
            "Preferred Times",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Home Pickup (Morning)
              if (_bookingType != 'One Way Back Home')
                Expanded(
                  child: _buildTimePickerCard(
                    "Home Pickup",
                    "Morning",
                    _homePickupTime,
                    () => _selectTime(true),
                  ),
                ),
              if (_bookingType != 'One Way Back Home' &&
                  _bookingType != 'One Way to School')
                const SizedBox(width: 12),

              // School Pickup (Afternoon)
              if (_bookingType != 'One Way to School')
                Expanded(
                  child: _buildTimePickerCard(
                    "School Pickup",
                    "Afternoon",
                    _schoolPickupTime,
                    () => _selectTime(false),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // 5. NOTES
          const Text("Notes", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: "Any special instructions...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // SUBMIT
          SizedBox(
            width: double.infinity,
            height: 54,
            child: Builder(
              builder: (context) {
                final controllerState = ref.watch(bookingsControllerProvider);
                final isSubmitting = controllerState.isLoading;

                return ElevatedButton(
                  onPressed: isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Submit Request",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTimePickerCard(
    String title,
    String subtitle,
    TimeOfDay? time,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.indigo),
                const SizedBox(width: 6),
                Text(
                  time != null ? time.format(context) : "--:--",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No bookings yet",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  "Request a booking to get started!",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Group bookings by status
        final pending = bookings
            .where((b) => b['status'] == 'pending')
            .toList();
        final accepted = bookings
            .where((b) => b['status'] == 'accepted')
            .toList();
        final completed = bookings
            .where((b) => b['status'] == 'completed')
            .toList();
        final rejected = bookings
            .where((b) => b['status'] == 'rejected')
            .toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ACCEPTED (Active) Bookings - Most important
            if (accepted.isNotEmpty) ...[
              _buildStatusHeader(
                "Active Bookings",
                Colors.green,
                accepted.length,
              ),
              ...accepted.map(
                (b) => _buildBookingCard(b, showTrackButton: true),
              ),
              const SizedBox(height: 20),
            ],

            // PENDING Bookings
            if (pending.isNotEmpty) ...[
              _buildStatusHeader(
                "Pending Approval",
                Colors.orange,
                pending.length,
              ),
              ...pending.map((b) => _buildBookingCard(b)),
              const SizedBox(height: 20),
            ],

            // COMPLETED Bookings (History)
            if (completed.isNotEmpty) ...[
              _buildStatusHeader("Completed", Colors.grey, completed.length),
              ...completed.map((b) => _buildBookingCard(b)),
              const SizedBox(height: 20),
            ],

            // REJECTED Bookings
            if (rejected.isNotEmpty) ...[
              _buildStatusHeader("Rejected", Colors.red, rejected.length),
              ...rejected.map((b) => _buildBookingCard(b)),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text("Error: $e"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(String title, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(
    Map<String, dynamic> booking, {
    bool showTrackButton = false,
  }) {
    final status = booking['status'] as String?;
    final driverName = booking['driver_name'] as String? ?? 'Driver';
    final driverPhoto = booking['driver_photo'] as String?;
    final bookingType = booking['booking_type'] as String? ?? '';
    final homeLocation = booking['home_location'] as String? ?? '';
    final schoolLocation = booking['school_location'] as String? ?? '';
    final homePickupTime = booking['home_pickup_time'] as String?;
    final schoolPickupTime = booking['school_pickup_time'] as String?;
    final createdAt = booking['created_at'] != null
        ? DateTime.tryParse(booking['created_at'])
        : null;

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'completed':
        statusColor = Colors.grey;
        statusIcon = Icons.task_alt;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: status == 'accepted' ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: status == 'accepted'
            ? BorderSide(color: Colors.green.shade200, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Driver Info and Status
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.indigo.shade100,
                  backgroundImage: driverPhoto != null
                      ? NetworkImage(driverPhoto)
                      : null,
                  child: driverPhoto == null
                      ? Icon(Icons.person, color: Colors.indigo.shade700)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        bookingType,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status?.toUpperCase() ?? '',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Location Info
            if (homeLocation.isNotEmpty)
              _buildInfoRow(Icons.home, 'Home', homeLocation),
            if (schoolLocation.isNotEmpty)
              _buildInfoRow(Icons.school, 'School', schoolLocation),

            // Time Info
            if (homePickupTime != null || schoolPickupTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    if (homePickupTime != null)
                      _buildTimeBadge('Morning', homePickupTime),
                    if (homePickupTime != null && schoolPickupTime != null)
                      const SizedBox(width: 12),
                    if (schoolPickupTime != null)
                      _buildTimeBadge('Afternoon', schoolPickupTime),
                  ],
                ),
              ),

            // Created Date
            if (createdAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Booked on ${_formatDate(createdAt)}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),

            // TRACK DRIVER BUTTON (only for accepted bookings)
            if (showTrackButton && status == 'accepted') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToTracking(booking),
                  icon: const Icon(Icons.location_on),
                  label: const Text('Track Driver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBadge(String label, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 14, color: Colors.indigo.shade700),
          const SizedBox(width: 4),
          Text(
            '$label: $time',
            style: TextStyle(
              color: Colors.indigo.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _navigateToTracking(Map<String, dynamic> booking) {
    // Extract location data for the tracking screen
    final homeLat = booking['home_lat'] as double?;
    final homeLng = booking['home_lng'] as double?;
    final schoolLat = booking['school_lat'] as double?;
    final schoolLng = booking['school_lng'] as double?;

    context.push(
      '/tracking',
      extra: {
        'bookingId': booking['id'],
        'driverId': booking['driver_id'],
        'driverName': booking['driver_name'] ?? 'Driver',
        'driverPhotoUrl': booking['driver_photo'],
        'homeLocation': (homeLat != null && homeLng != null)
            ? LatLng(homeLat, homeLng)
            : null,
        'schoolLocation': (schoolLat != null && schoolLng != null)
            ? LatLng(schoolLat, schoolLng)
            : null,
      },
    );
  }
}
