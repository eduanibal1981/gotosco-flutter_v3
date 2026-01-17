import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotosco_v3/features/parent/bookings/presentation/widgets/location_input_field.dart';
import 'package:gotosco_v3/features/parent/dashboard/presentation/dashboard_controller.dart';
import '../../children/data/children_repository.dart';
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

class _BookingScreenState extends ConsumerState<BookingScreen> {
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

  // NEW: Recurring State
  DateTime _startDate = DateTime.now().add(const Duration(days: 1)); // Tomorrow
  DateTime _endDate = DateTime.now().add(
    const Duration(days: 30),
  ); // Next Month
  bool _isRecurring = false;
  bool _isMonthlySubscription = false;
  final List<String> _selectedDays = [];

  final List<String> _bookingTypes = [
    'Two Way',
    'One Way to School',
    'One Way Back Home',
    'Other',
  ];

  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Sunday',
  ]; // Assuming Friday/Saturday is weekend in this region (e.g., Middle East) or standard Mon-Fri.

  @override
  void dispose() {
    _notesController.dispose();
    _homeLocController.dispose();
    _schoolLocController.dispose();
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

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
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
            startDate: _startDate,
            endDate: _endDate,
            isRecurring: _isRecurring,
            recurringDays: _isRecurring ? _selectedDays : null,
            isMonthlySubscription: _isMonthlySubscription,
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
          _isRecurring = false;
          _isMonthlySubscription = false;
          _selectedDays.clear();
        });

        // Navigation Logic:
        // 1. Set the dashboard index to 3 (My Bookings)
        ref.read(parentDashboardIndexProvider.notifier).setIndex(3);

        // 2. Navigate to the parent home/dashboard
        // Assuming '/parent-home' is the route for ParentDashboardScreen
        // If not, we might need to verify routes.
        // But usually it is '/parent-home'.
        context.go('/parent-home');
      } else {
        // Show error from controller if success is false
        final error = ref.read(bookingsControllerProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${error ?? 'Unknown error'}"),
            backgroundColor: Colors.red,
          ),
        );
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
      appBar: AppBar(title: Text("Book ${widget.driverName}")),
      body: _buildRequestForm(),
    );
  }

  Widget _buildRequestForm() {
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
              error: (err, _) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Error loading children"),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. DATES & RECURRING
          const Text(
            "Dates & Schedule",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Date Range Picker
          InkWell(
            onTap: _selectDateRange,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range, color: Colors.indigo),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date Range",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "${_startDate.day}/${_startDate.month}/${_startDate.year} - ${_endDate.day}/${_endDate.month}/${_endDate.year}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Recurring Toggle
          SwitchListTile(
            value: _isRecurring,
            onChanged: (val) {
              setState(() => _isRecurring = val);
            },
            title: const Text("Recurring Trip"),
            subtitle: const Text("Repeat on specific days"),
            activeColor: Colors.indigo,
            contentPadding: EdgeInsets.zero,
          ),

          // Days Selector (Visible if Recurring)
          if (_isRecurring)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Wrap(
                spacing: 8,
                children: _weekDays.map((day) {
                  final isSelected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day.substring(0, 3)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                    selectedColor: Colors.indigo.shade100,
                    checkmarkColor: Colors.indigo,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.indigo.shade900 : Colors.black,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
            ),

          // Monthly Subscription Toggle
          SwitchListTile(
            value: _isMonthlySubscription,
            onChanged: (val) {
              setState(() => _isMonthlySubscription = val);
            },
            title: const Text("Monthly Subscription"),
            subtitle: const Text("Renew automatically (if supported)"),
            activeColor: Colors.indigo,
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 20),

          // 3. BOOKING TYPE
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

          // 4. LOCATIONS
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

          // 5. TIMES (Dynamic based on Type)
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

          // 6. NOTES
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
}
