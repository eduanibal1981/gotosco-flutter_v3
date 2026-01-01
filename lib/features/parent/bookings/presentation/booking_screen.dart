import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../children/data/children_repository.dart'; // Import to fetch kids
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
  final _notesController = TextEditingController();
  final List<String> _selectedChildIds = []; // Stores IDs of selected kids
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // --- ACTIONS ---
  Future<void> _submitRequest() async {
    if (_selectedChildIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one child")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(bookingsRepositoryProvider)
          .createBooking(
            driverId: widget.driverId,
            childIds: _selectedChildIds,
            notes: _notesController.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request Sent Successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form and Switch to History Tab
      setState(() {
        _selectedChildIds.clear();
        _notesController.clear();
      });
      _tabController.animateTo(1); // Go to "History"
    } catch (e) {
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
        title: Text("Booking: ${widget.driverName}"),
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
        children: [_buildRequestTab(), _buildHistoryTab()],
      ),
    );
  }

  // --- TAB 1: REQUEST FORM ---
  Widget _buildRequestTab() {
    final myChildren = ref.watch(myChildrenProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Children",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Children List Selection
          myChildren.when(
            data: (children) {
              if (children.isEmpty)
                return const Text("Please add children to your profile first.");
              return Column(
                children: children.map((child) {
                  final isSelected = _selectedChildIds.contains(child.id);
                  return CheckboxListTile(
                    value: isSelected,
                    activeColor: Colors.indigo,
                    title: Text(
                      child.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${child.schoolName} • ${child.grade}"),
                    secondary: CircleAvatar(
                      backgroundColor: isSelected
                          ? Colors.indigo.shade100
                          : Colors.grey.shade200,
                      child: Icon(
                        Icons.person,
                        color: isSelected ? Colors.indigo : Colors.grey,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedChildIds.add(child.id);
                        } else {
                          _selectedChildIds.remove(child.id);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text("Error loading children: $e"),
          ),

          const SizedBox(height: 24),
          const Text(
            "Notes for Driver (Optional)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "E.g., Start date next week, specific pick-up point...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),

          const SizedBox(height: 32),
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
                      "Send Request",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: HISTORY ---
  Widget _buildHistoryTab() {
    final historyAsync = ref.watch(myBookingsProvider);

    return historyAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return const Center(child: Text("No booking history yet."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final item = bookings[index];
            return _buildBookingCard(item);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error: $e")),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> item) {
    final status = (item['status'] as String).toLowerCase();

    // Status Logic
    Color statusColor;
    switch (status) {
      case 'accepted':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'completed':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: item['driver_photo'] != null
                      ? NetworkImage(item['driver_photo'])
                      : null,
                  child: item['driver_photo'] == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['driver_name'] ?? 'Driver',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat.yMMMd().format(
                          DateTime.parse(item['created_at']),
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${item['kids_count']} Children Included",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (status == 'pending')
                  const Text(
                    "Waiting for approval...",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
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
