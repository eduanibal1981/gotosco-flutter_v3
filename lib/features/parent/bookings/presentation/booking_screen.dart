import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotosco_v3/features/parent/bookings/presentation/widgets/location_input_field.dart';
import 'package:gotosco_v3/features/parent/dashboard/presentation/dashboard_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../find_driver/presentation/drivers_controller.dart';
import '../../children/data/children_repository.dart';
import 'bookings_controller.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String driverId;
  final String driverName;
  final Map<String, dynamic>? initialData;

  const BookingScreen({
    super.key,
    required this.driverId,
    required this.driverName,
    this.initialData,
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
  final _schoolNameController = TextEditingController();

  // Form State
  String _bookingType = 'Two Way'; // Default
  TimeOfDay? _homePickupTime;
  TimeOfDay? _schoolPickupTime;
  final List<String> _selectedChildIds = [];
  String? _selectedCityId;
  String? _selectedSchoolId;
  String? _selectedSchoolName;
  bool _useManualSchool = false;

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

  List<String>? _initialChildNames;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _prefillData(widget.initialData!);
    }
    if (_selectedSchoolId != null &&
        (_schoolLat == null || _schoolLng == null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadSchoolDetails(_selectedSchoolId!);
      });
    }
  }

  void _prefillData(Map<String, dynamic> data) {
    _bookingType = data['booking_type'] ?? 'Two Way';
    if (!_bookingTypes.contains(_bookingType)) {
      _bookingType = _bookingTypes.first;
    }

    _homeLocController.text = data['home_location'] ?? '';
    _schoolLocController.text = data['school_location'] ?? '';
    _selectedSchoolId = data['school_id'];
    _selectedSchoolName = data['school_name'];
    _schoolNameController.text = data['school_name'] ?? '';
    _useManualSchool =
        _selectedSchoolId == null && _schoolLocController.text.isNotEmpty;
    _notesController.text = data['notes'] ?? '';

    _homeLat = data['home_lat'] as double?;
    _homeLng = data['home_lng'] as double?;
    _schoolLat = data['school_lat'] as double?;
    _schoolLng = data['school_lng'] as double?;

    // Parse times
    if (data['home_pickup_time'] != null) {
      _homePickupTime = _parseTime(data['home_pickup_time']);
    }
    if (data['school_pickup_time'] != null) {
      _schoolPickupTime = _parseTime(data['school_pickup_time']);
    }

    // Recurring
    _isRecurring = data['is_recurring'] == true;
    _isMonthlySubscription = data['is_monthly_subscription'] == true;

    if (data['recurring_days'] != null) {
      final days = data['recurring_days'];
      if (days is List) {
        _selectedDays.addAll(days.map((e) => e.toString()));
      }
    }

    // Child Names to select later
    if (data['child_names'] != null &&
        (data['child_names'] as List).isNotEmpty) {
      _initialChildNames =
          (data['child_names'] as List).map((e) => e.toString()).toList();
    }
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _homeLocController.dispose();
    _schoolLocController.dispose();
    _schoolNameController.dispose();
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

  Future<void> _loadSchoolDetails(String schoolId) async {
    try {
      final data = await Supabase.instance.client
          .from('schools')
          .select('id, name, address, city_id, location')
          .eq('id', schoolId)
          .maybeSingle();
      if (!mounted || data == null) return;
      _applySchoolSelection(data, data['city_id'] as String?);
    } catch (_) {
      // Ignore load errors; user can switch to manual if needed.
    }
  }

  void _applySchoolSelection(Map<String, dynamic> school, String? cityId) {
    final coords =
        _parseSchoolLocation(school['location']) ?? _coordsFromSchool(school);
    final address = (school['address'] as String?)?.trim();

    setState(() {
      _selectedCityId = cityId;
      _selectedSchoolId = school['id'] as String?;
      _selectedSchoolName = school['name'] as String?;
      _useManualSchool = false;
      _schoolNameController.text = _selectedSchoolName ?? '';
      _schoolLocController.text = address?.isNotEmpty == true ? address! : '';
      _schoolLat = coords?['lat'];
      _schoolLng = coords?['lng'];
    });
  }

  Map<String, double>? _parseSchoolLocation(dynamic location) {
    if (location == null) return null;
    if (location is Map) {
      final coords = location['coordinates'];
      if (coords is List && coords.length >= 2) {
        final lng = (coords[0] as num).toDouble();
        final lat = (coords[1] as num).toDouble();
        return {'lat': lat, 'lng': lng};
      }
    }
    if (location is String) {
      final text = location.trim();
      try {
        if (text.startsWith('{')) {
          final decoded = json.decode(text);
          final coords = decoded['coordinates'];
          if (coords is List && coords.length >= 2) {
            final lng = (coords[0] as num).toDouble();
            final lat = (coords[1] as num).toDouble();
            return {'lat': lat, 'lng': lng};
          }
        }
      } catch (_) {
        // fallthrough
      }
      final pointMatch = RegExp(r'POINT\\(([-\\d\\.]+) ([-\\d\\.]+)\\)')
          .firstMatch(text);
      if (pointMatch != null) {
        final lng = double.tryParse(pointMatch.group(1)!);
        final lat = double.tryParse(pointMatch.group(2)!);
        if (lat != null && lng != null) {
          return {'lat': lat, 'lng': lng};
        }
      }
    }
    return null;
  }

  Map<String, double>? _coordsFromSchool(Map<String, dynamic> school) {
    final lat = school['latitude'];
    final lng = school['longitude'];
    if (lat is num && lng is num) {
      return {'lat': lat.toDouble(), 'lng': lng.toDouble()};
    }
    return null;
  }

  Future<void> _submitRequest() async {
    try {
      if (_useManualSchool && _schoolNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter the school name'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await ref
          .read(bookingsControllerProvider.notifier)
          .submitBooking(
            driverId: widget.driverId,
            childIds: _selectedChildIds,
            bookingType: _bookingType,
            schoolId: _useManualSchool ? null : _selectedSchoolId,
            schoolName: _useManualSchool
                ? _schoolNameController.text.trim()
                : _selectedSchoolName,
            homeLocation: _homeLocController.text.trim(),
            schoolLocation: _useManualSchool
                ? _schoolLocController.text.trim()
                : (_schoolLocController.text.trim().isEmpty
                    ? null
                    : _schoolLocController.text.trim()),
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
          _schoolNameController.clear();
          _homePickupTime = null;
          _schoolPickupTime = null;
          _selectedCityId = null;
          _selectedSchoolId = null;
          _selectedSchoolName = null;
          _useManualSchool = false;
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
                // Auto-select children if initial data provided and not yet selected
                if (_initialChildNames != null &&
                    _initialChildNames!.isNotEmpty &&
                    _selectedChildIds.isEmpty) {
                  // Run after build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted &&
                        _selectedChildIds.isEmpty &&
                        _initialChildNames != null) {
                      final idsToSelect = children
                          .where((c) => _initialChildNames!.contains(c.name))
                          .map((c) => c.id)
                          .toList();
                      if (idsToSelect.isNotEmpty) {
                        setState(() {
                          _selectedChildIds.addAll(idsToSelect);
                          // Clear so we don't re-select if user unchecks
                          _initialChildNames = null;
                        });
                      }
                    }
                  });
                }

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

          const Text(
            "School",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildSchoolSelector(context),
          if (!_useManualSchool) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _schoolLocController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'School Location',
                hintText: _selectedSchoolId == null
                    ? 'Select a school to set the location'
                    : 'Location set from school',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Location is pulled from the school record.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ] else ...[
            const SizedBox(height: 12),
            TextField(
              controller: _schoolNameController,
              decoration: InputDecoration(
                labelText: 'School Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
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
          ],

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

  Widget _buildSchoolSelector(BuildContext context) {
    final label = _selectedSchoolName ?? 'Select School';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            if (_useManualSchool) return;
            final result =
                await showModalBottomSheet<Map<String, dynamic>>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => _SchoolSelectionSheet(
                initialCityId: _selectedCityId,
                initialSchoolId: _selectedSchoolId,
              ),
            );
            if (result == null) return;
            final school = result['school'] as Map<String, dynamic>?;
            if (school == null) return;
            _applySchoolSelection(school, result['cityId'] as String?);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
              color: _useManualSchool ? Colors.grey.shade100 : Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              setState(() {
                _useManualSchool = !_useManualSchool;
                _selectedSchoolId = null;
                _selectedSchoolName = null;
                _selectedCityId = null;
                _schoolLocController.clear();
                if (_useManualSchool) {
                  _schoolNameController.clear();
                }
                _schoolLat = null;
                _schoolLng = null;
              });
            },
            child: Text(
              _useManualSchool ? 'Use school list' : 'School not listed?',
            ),
          ),
        ),
      ],
    );
  }
}

class _SchoolSelectionSheet extends ConsumerStatefulWidget {
  final String? initialCityId;
  final String? initialSchoolId;

  const _SchoolSelectionSheet({
    required this.initialCityId,
    required this.initialSchoolId,
  });

  @override
  ConsumerState<_SchoolSelectionSheet> createState() =>
      _SchoolSelectionSheetState();
}

class _SchoolSelectionSheetState extends ConsumerState<_SchoolSelectionSheet> {
  late TextEditingController _searchController;
  String? _selectedCityId;
  String? _selectedSchoolId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedCityId = widget.initialCityId;
    _selectedSchoolId = widget.initialSchoolId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider);
    final schoolsAsync = ref.watch(schoolsProvider(cityId: _selectedCityId));

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select School',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: citiesAsync.when(
                data: (cities) => DropdownButtonFormField<String>(
                  value: _selectedCityId,
                  decoration: InputDecoration(
                    labelText: 'Select City',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Cities'),
                    ),
                    ...cities.map(
                      (c) => DropdownMenuItem(
                        value: c['id'] as String,
                        child: Text(c['name'] as String),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedCityId = val;
                      _selectedSchoolId = null;
                    });
                  },
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => const SizedBox(),
              ),
            ),
            if (_selectedCityId == null)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Please select a city to see available schools',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            if (_selectedCityId != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search school...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: schoolsAsync.when(
                  data: (schools) {
                    final filtered = schools.where((school) {
                      final name = (school['name'] as String?) ?? '';
                      return name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(child: Text('No schools found'));
                    }

                    return ListView.separated(
                      controller: controller,
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final school = filtered[index];
                        final isSelected =
                            school['id'] == _selectedSchoolId;
                        return ListTile(
                          title: Text(school['name'] as String? ?? 'School'),
                          subtitle: school['address'] != null
                              ? Text(
                                  school['address'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          trailing: isSelected
                              ? const Icon(Icons.check, color: Colors.indigo)
                              : null,
                          onTap: () {
                            Navigator.pop(context, {
                              'cityId': _selectedCityId,
                              'school': school,
                            });
                          },
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
