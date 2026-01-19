import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/transport_requests_repository.dart';

class TransportRequestsTab extends ConsumerStatefulWidget {
  const TransportRequestsTab({super.key});

  @override
  ConsumerState<TransportRequestsTab> createState() =>
      _TransportRequestsTabState();
}

class _TransportRequestsTabState extends ConsumerState<TransportRequestsTab> {
  String _status = 'open';
  String _bookingType = 'all';
  final _searchController = TextEditingController();
  final _ageMinController = TextEditingController();
  final _ageMaxController = TextEditingController();
  final _distanceController = TextEditingController();
  final _schoolController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _ageMinController.dispose();
    _ageMaxController.dispose();
    _distanceController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(
      transportRequestsProvider(
        status: _status,
        bookingType: _bookingType,
        searchTerm: _searchController.text,
        ageMin: _parseInt(_ageMinController.text),
        ageMax: _parseInt(_ageMaxController.text),
        schoolName: _schoolController.text,
        maxDistanceKm: _parseDouble(_distanceController.text),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildFilters(context),
          Expanded(
            child: requestsAsync.when(
              data: (requests) {
                if (requests.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _buildRequestCard(context, requests[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search by child, school, or location',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown<String>(
                  label: 'Status',
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: 'open', child: Text('Open')),
                    DropdownMenuItem(value: 'closed', child: Text('Closed')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                    DropdownMenuItem(value: 'all', child: Text('All')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _status = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown<String>(
                  label: 'Trip Type',
                  value: _bookingType,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'Two Way', child: Text('Two Way')),
                    DropdownMenuItem(
                      value: 'One Way to School',
                      child: Text('One Way to School'),
                    ),
                    DropdownMenuItem(
                      value: 'One Way Back Home',
                      child: Text('One Way Back Home'),
                    ),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _bookingType = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageMinController,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Min Age',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _ageMaxController,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Max Age',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _distanceController,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Max KM',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _schoolController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'School',
              prefixIcon: const Icon(Icons.school_outlined),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No transport requests found',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> request) {
    final childName = request['child_name'] as String? ?? 'Child';
    final childAge = request['child_age'];
    final bookingType = request['booking_type'] as String? ?? '';
    final schoolName = request['school_name'] as String? ?? '';
    final homeLocation = request['hometxt_location'] as String? ?? '';
    final schoolLocation = request['schooltxt_location'] as String? ?? '';
    final notes = request['notes'] as String? ?? '';
    final status = request['status'] as String? ?? 'open';
    final createdAt = request['created_at'] != null
        ? DateTime.tryParse(request['created_at'])
        : null;

    final parentName = request['parent_name'] as String? ?? 'Parent';
    final parentPhoto = request['parent_photo'] as String?;
    final parentId = request['parent_id'] as String? ?? '';

    final statusColor = switch (status) {
      'open' => Colors.green,
      'closed' => Colors.blueGrey,
      'cancelled' => Colors.red,
      _ => Colors.grey,
    };

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage:
                      parentPhoto != null ? NetworkImage(parentPhoto) : null,
                  child: parentPhoto == null
                      ? Text(
                          parentName.isNotEmpty
                              ? parentName[0].toUpperCase()
                              : 'P',
                          style: TextStyle(
                            color: Colors.teal.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        bookingType,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
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
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$childName${childAge != null ? ' - $childAge yrs' : ''}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            if (schoolName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  schoolName,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
            const SizedBox(height: 8),
            if (homeLocation.isNotEmpty)
              _buildInfoRow(Icons.home, 'Home', homeLocation),
            if (schoolLocation.isNotEmpty)
              _buildInfoRow(Icons.school, 'School', schoolLocation),
            if (notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  notes,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ),
            if (createdAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Posted on ${_formatDate(createdAt)}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: parentId.isEmpty
                        ? null
                        : () {
                            context.push(
                              '/chat',
                              extra: {
                                'userId': parentId,
                                'userName': parentName,
                              },
                            );
                          },
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Message'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

  int? _parseInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  double? _parseDouble(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }
}
