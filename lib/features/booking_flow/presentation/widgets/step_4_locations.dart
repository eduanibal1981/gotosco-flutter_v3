import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/booking_draft_model.dart';
import '../../data/models/school_location_model.dart';
import '../../../shared/schools/data/schools_repository.dart';
import '../../../shared/schools/data/school_model.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/widgets/map_picker_screen.dart';
import '../controllers/booking_flow_controller.dart';
import '../../../auth/application/user_provider.dart';

/// Step 4: Set pickup and dropoff locations
class Step4Locations extends ConsumerStatefulWidget {
  const Step4Locations({super.key});

  @override
  ConsumerState<Step4Locations> createState() => _Step4LocationsState();
}

class _Step4LocationsState extends ConsumerState<Step4Locations> {
  bool _hasAttemptedAutoFill = false;

  @override
  void initState() {
    super.initState();
    // Attempt auto-fill on init, deferring to next frame to ensure providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptAutoFill();
    });
  }

  void _attemptAutoFill() {
    if (_hasAttemptedAutoFill) return;

    final userState = ref.read(currentUserProfileProvider);
    final controller = ref.read(bookingFlowControllerProvider.notifier);
    final draft = ref.read(bookingFlowControllerProvider);

    userState.whenData((user) {
      if (user == null) return;

      final homeText = user.locationText;
      final homeLat = user.locationLat;
      final homeLng = user.locationLng;

      if (homeText != null &&
          homeText.isNotEmpty &&
          homeLat != null &&
          homeLng != null) {
        bool updated = false;

        // Logic: Home is Pickup for (Two Way / One Way to School)
        if (draft.bookingType == 'Two Way' ||
            draft.bookingType == 'One Way to School') {
          if (draft.pickupLocationText == null ||
              draft.pickupLocationText!.isEmpty) {
            controller.setPickupLocation(
              locationText: homeText,
              lat: homeLat,
              lng: homeLng,
            );
            updated = true;
          }
        }
        // Logic: Home is Dropoff for (One Way Back Home)
        else if (draft.bookingType == 'One Way Back Home') {
          if (draft.dropoffLocationText == null ||
              draft.dropoffLocationText!.isEmpty) {
            controller.setDropoffLocation(
              locationText: homeText,
              lat: homeLat,
              lng: homeLng,
            );
            updated = true;
          }
        }

        if (updated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Home location auto-filled from profile'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      _hasAttemptedAutoFill = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingDraft = ref.watch(bookingFlowControllerProvider);
    final bookingType = bookingDraft.bookingType ?? '';

    // Listen to user profile changes if it wasn't ready at init
    ref.listen(currentUserProfileProvider, (previous, next) {
      if (!_hasAttemptedAutoFill && next.hasValue && next.value != null) {
        _attemptAutoFill();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set Locations',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose pickup and dropoff locations',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Pickup Location (for Two Way and Go Only)
                if (bookingType == 'Two Way' ||
                    bookingType == 'One Way to School')
                  _buildLocationField(
                    context,
                    ref,
                    label: bookingDraft.tripCategory == 'school'
                        ? 'Pickup Location (Home)'
                        : 'Pickup Location',
                    icon: Icons.location_on,
                    iconColor: Colors.green,
                    hintText: bookingDraft.tripCategory == 'school'
                        ? 'Your home address'
                        : 'Enter pickup location',
                    currentLocation: bookingDraft.pickupLocationText,
                    onTap: () => _pickLocation(context, ref, isPickup: true),
                  ),

                if (bookingType == 'Two Way' ||
                    bookingType == 'One Way to School')
                  const SizedBox(height: 20),

                // Dropoff Location (for Two Way and Go Only)
                if ((bookingType == 'Two Way' ||
                        bookingType == 'One Way to School') &&
                    !bookingDraft.isMultiSchool)
                  _buildLocationField(
                    context,
                    ref,
                    label:
                        'Dropoff Location', // No specific 'dropoff (home)' requested for Go Trip, just generally labels.
                    // User said: school transport --> go only --> pickup location (Home) issue, no Home label.
                    // Oh wait, for Go Only: Pickup (Home) -> Dropoff (School).
                    // For Return Only: Pickup (School) -> Dropoff (Home).

                    // Actually, let's follow specific request:
                    // school transport --> go & return --> pickup location (Home)
                    // school transport --> go only --> pickup location (Home)
                    // Journey Trip --> Return only --> both pickup and dropoff has no suffix.

                    // So Dropoff for standard trips: "Dropoff Location (School)" if school transport?
                    // User didn't complain about School label here, but consistency advises it.
                    // But if it's school transport, Dropoff is usually replaced by MultiSchoolSelector (since we forced it to true above).
                    // So this block only runs for NON-multi-school (i.e. NON-school category).
                    // If non-school category (Journey), then "Dropoff Location" is correct.
                    // So this label is fine.
                    icon: Icons.flag,
                    iconColor: Colors.red,
                    hintText: bookingDraft.tripCategory == 'school'
                        ? 'School address'
                        : 'Enter dropoff location',
                    currentLocation: bookingDraft.dropoffLocationText,
                    onTap: () => _pickLocation(context, ref, isPickup: false),
                  ),

                // Multi-School Dropoff Selector
                if ((bookingType == 'Two Way' ||
                        bookingType == 'One Way to School') &&
                    bookingDraft.isMultiSchool)
                  _buildMultiSchoolSelector(
                    context,
                    ref,
                    bookingDraft,
                    isDropoff: true,
                  ),

                // Pickup Location (for Return Only - same as dropoff)
                if (bookingType == 'One Way Back Home' &&
                    !bookingDraft.isMultiSchool)
                  _buildLocationField(
                    context,
                    ref,
                    label: bookingDraft.tripCategory == 'school'
                        ? 'Pickup Location (School)'
                        : 'Pickup Location',
                    icon: Icons.location_on,
                    iconColor: Colors.green,
                    hintText: bookingDraft.tripCategory == 'school'
                        ? 'School address'
                        : 'Enter pickup location',
                    currentLocation: bookingDraft.pickupLocationText,
                    onTap: () => _pickLocation(context, ref, isPickup: true),
                  ),

                // Multi-School Pickup Selector (for Return Only)
                if (bookingType == 'One Way Back Home' &&
                    bookingDraft.isMultiSchool)
                  _buildMultiSchoolSelector(
                    context,
                    ref,
                    bookingDraft,
                    isDropoff: false,
                  ),

                if (bookingType == 'One Way Back Home')
                  const SizedBox(height: 20),

                // Dropoff Location (for Return Only)
                if (bookingType == 'One Way Back Home')
                  _buildLocationField(
                    context,
                    ref,
                    label: bookingDraft.tripCategory == 'school'
                        ? 'Dropoff Location (Home)'
                        : 'Dropoff Location',
                    icon: Icons.flag,
                    iconColor: Colors.red,
                    hintText: bookingDraft.tripCategory == 'school'
                        ? 'Your home address'
                        : 'Enter dropoff location',
                    currentLocation: bookingDraft.dropoffLocationText,
                    onTap: () => _pickLocation(context, ref, isPickup: false),
                  ),

                // Helper text for school trips
                if (bookingDraft.tripCategory == 'school' &&
                    !bookingDraft.isMultiSchool) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Default locations will be used from child\'s profile if not specified',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required IconData icon,
    required Color iconColor,
    required String hintText,
    required String? currentLocation,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: currentLocation != null && currentLocation.isNotEmpty
                    ? Colors.indigo.shade300
                    : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: currentLocation != null && currentLocation.isNotEmpty
                  ? Colors.indigo.shade50
                  : Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    currentLocation != null && currentLocation.isNotEmpty
                        ? currentLocation
                        : hintText,
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          currentLocation != null && currentLocation.isNotEmpty
                          ? Colors.black87
                          : Colors.grey.shade500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.edit_location_alt,
                  color: Colors.indigo.shade600,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickLocation(
    BuildContext context,
    WidgetRef ref, {
    required bool isPickup,
  }) async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (result == null) return;

    final controller = ref.read(bookingFlowControllerProvider.notifier);

    // Show feedback
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fetching address...'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    // Default to coordinates
    String address =
        '${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}';

    try {
      // Try native geocoding first (Google/Apple)
      final placemarks = await placemarkFromCoordinates(
        result.latitude,
        result.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final addressParts =
            {
                  place.name,
                  place.street,
                  place.subLocality,
                  place.locality,
                  place.administrativeArea,
                }
                .where(
                  (element) =>
                      element != null && element.toString().trim().isNotEmpty,
                )
                .toSet()
                .toList();

        if (addressParts.isNotEmpty) {
          address = addressParts.join(', ');
        }
      } else {
        // Fallback to OSM
        final osmAddress = await _fetchAddressFromOSM(
          result.latitude,
          result.longitude,
        );
        if (osmAddress != null) address = osmAddress;
      }
    } catch (e) {
      // Native failed, try OSM
      final osmAddress = await _fetchAddressFromOSM(
        result.latitude,
        result.longitude,
      );
      if (osmAddress != null) address = osmAddress;
    }

    // Update Controller
    if (isPickup) {
      controller.setPickupLocation(
        locationText: address,
        lat: result.latitude,
        lng: result.longitude,
      );
    } else {
      controller.setDropoffLocation(
        locationText: address,
        lat: result.latitude,
        lng: result.longitude,
      );
    }
  }

  Future<String?> _fetchAddressFromOSM(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'GotoscoApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          final parts = [
            address['amenity'] ?? address['building'],
            address['road'] ?? address['pedestrian'],
            address['neighbourhood'] ?? address['suburb'],
            address['city'] ?? address['town'] ?? address['village'],
            address['state'] ?? address['region'],
          ].where((e) => e != null && e.toString().isNotEmpty).toSet().toList();
          return parts.join(', ');
        }
        return data['display_name'] as String?;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Widget _buildMultiSchoolSelector(
    BuildContext context,
    WidgetRef ref,
    BookingDraftModel draft, {
    required bool isDropoff,
  }) {
    // If we're picking up from school (One Way Back Home), this is the "Pickup" visually
    // If we're dropping off at school (Two Way/Go), this is the "Dropoff" visually

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isDropoff ? Icons.flag : Icons.location_on,
              color: isDropoff ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 8),
            Text(
              isDropoff
                  ? 'Dropoff Locations (School)'
                  : 'Pickup Locations (School)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Multiple schools detected. Please verify or update locations.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),

        ...draft.schoolLocations.asMap().entries.map((entry) {
          final index = entry.key;
          final school = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSchoolCard(context, ref, school, index + 1),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSchoolCard(
    BuildContext context,
    WidgetRef ref,
    SchoolLocationModel school,
    int number,
  ) {
    // Safe access
    final String schoolName = school.schoolName;
    final String? address = school.schoolAddress;
    final List<String> studentIds = school.studentIds;
    final bool isPending = school.schoolId == 'pending_selection';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.indigo.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.indigo.shade50,
      ),
      child: Row(
        children: [
          // Number badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.indigo.shade600,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // School info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schoolName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (address != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${studentIds.length} student(s)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.indigo.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Action (Edit/Select)
          IconButton(
            onPressed: () {
              _showSchoolPicker(context, ref, school, number - 1);
            },
            icon: Icon(
              isPending ? Icons.add_circle : Icons.edit,
              color: Colors.indigo.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSchoolPicker(
    BuildContext context,
    WidgetRef ref,
    SchoolLocationModel currentLocation,
    int index,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _SchoolPickerDialog(
        currentLocation: currentLocation,
        onSchoolSelected: (school) {
          // Update the location in controller
          final newLocation = currentLocation.copyWith(
            schoolId: school.id,
            schoolName: school.name,
            schoolAddress: school.address,
            latitude: school.latitude,
            longitude: school.longitude,
          );

          ref
              .read(bookingFlowControllerProvider.notifier)
              .updateSchoolLocation(index, newLocation);

          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SchoolPickerDialog extends ConsumerStatefulWidget {
  final SchoolLocationModel currentLocation;
  final Function(SchoolModel) onSchoolSelected;

  const _SchoolPickerDialog({
    required this.currentLocation,
    required this.onSchoolSelected,
  });

  @override
  ConsumerState<_SchoolPickerDialog> createState() =>
      _SchoolPickerDialogState();
}

class _SchoolPickerDialogState extends ConsumerState<_SchoolPickerDialog> {
  final _searchController = TextEditingController();
  List<SchoolModel> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _searchSchools(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(schoolsRepositoryProvider);
      // We don't filter by city here yet as we don't have city context easily available
      // unless we check user's location or existing booking data.
      // For now, global search or we can improve later.
      final results = await repo.searchSchools(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchSchools(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Select School',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search for school name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              autofocus: true,
            ),
          ),

          const SizedBox(height: 16),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Type to search for schools'
                              : 'No schools found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final school = _searchResults[index];
                      final isSelected =
                          widget.currentLocation.schoolId == school.id;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade50,
                          child: Icon(
                            Icons.school,
                            color: Colors.indigo.shade600,
                            size: 20,
                          ),
                        ),
                        title: Text(school.name),
                        subtitle: school.address != null
                            ? Text(
                                school.address!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : null,
                        onTap: () => widget.onSchoolSelected(school),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
