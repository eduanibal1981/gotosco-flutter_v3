import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotosco_v3/features/parent/bookings/presentation/widgets/location_input_field.dart';
import 'package:intl/intl.dart';
import '../../children/data/children_repository.dart';
import '../../bookings/data/bookings_repository.dart';

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
  bool _isSubmitting = false;

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
    if (_selectedChildIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one child")),
      );
      return;
    }
    // Basic validation based on type
    if (_bookingType == 'Two Way' &&
        (_homePickupTime == null || _schoolPickupTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select both pickup times for Two Way"),
        ),
      );
      return;
    }
    // NEW: Validation for coordinates (optional but recommended)
    if (_homeLat == null || _schoolLat == null) {
      // You might want to allow text-only, but having coordinates is better for drivers
    }

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(bookingsRepositoryProvider)
          .createBooking(
            driverId: widget.driverId,
            childIds: _selectedChildIds,
            bookingType: _bookingType,
            homeLocation: _homeLocController.text.trim(),
            schoolLocation: _schoolLocController.text.trim(),
            // PASS COORDINATES
            homeLat: _homeLat,
            homeLng: _homeLng,
            schoolLat: _schoolLat,
            schoolLng: _schoolLng,
            homePickupTime: _homePickupTime,
            schoolPickupTime: _schoolPickupTime,
            notes: _notesController.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request Sent!"),
          backgroundColor: Colors.green,
        ),
      );

      // Reset
      setState(() {
        _selectedChildIds.clear();
        _notesController.clear();
        _homeLocController.clear();
        _schoolLocController.clear();
        _homePickupTime = null;
        _schoolPickupTime = null;
      });
      _tabController.animateTo(1);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Submit Request",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

  // Re-use the _buildHistoryTab code from the previous response...
  Widget _buildHistoryTab() {
    // ... (Keep existing history implementation)
    return const Center(
      child: Text("History List Placeholder"),
    ); // Replace with actual history code
  }
}
