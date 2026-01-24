import 'package:flutter/material.dart';

class BookingDetailsView extends StatelessWidget {
  final String title;
  final String childName;
  final String? childGender;
  final String? childGrade;
  final String tripCategory;
  final String bookingType;
  final bool isMultiSchool;
  final List<Map<String, String>>
  locations; // [{'label': 'Pickup', 'value': '...'}, ...]
  final String scheduleType;
  final String scheduleDescription;
  final double? price;
  final String? notes;
  final bool isPublicRequest;
  final bool isEditable;
  final bool isDriverView;
  final ValueChanged<double>? onPriceChanged;
  final ValueChanged<String>? onNotesChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onClose;

  final List<Map<String, dynamic>>?
  children; // [{'name':, 'gender':, 'grade':}, ...]
  final List<Map<String, dynamic>>? schools; // [{'name':, 'address':}, ...]

  const BookingDetailsView({
    super.key,
    required this.title,
    required this.childName,
    this.childGender,
    this.childGrade,
    this.children,
    this.schools,
    required this.tripCategory,
    required this.bookingType,
    required this.locations,
    required this.scheduleType,
    required this.scheduleDescription,
    this.isMultiSchool = false,
    this.price,
    this.notes,
    this.isPublicRequest = false,
    this.isEditable = false,
    this.isDriverView = false,
    this.onPriceChanged,
    this.onNotesChanged,
    this.onDelete,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Determine displaying name based on privacy rules
    String displayChildTitle = childName;
    String privacyNote = '';

    if (isPublicRequest) {
      if (isDriverView) {
        // Driver only sees Gender (Grade)
        displayChildTitle = _formatPublicChildStr();
      } else {
        // Parent viewing creation or their own ad
        // Show real name but indicate privacy
        displayChildTitle = childName;
        // If it's a public request, we emphasize that drivers see something else
        privacyNote = 'Drivers will see: "${_formatPublicChildStr()}"';
      }
    }

    final priceLabel = isPublicRequest
        ? 'Proposal Price'
        : 'Estimated Price / Agreed Price';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title (if not provided by parent scaffold)
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
          ],

          if (!isDriverView && !isEditable)
            // Intro text for view mode
            Text(
              'Review details below',
              style: TextStyle(color: Colors.grey.shade600),
            ),

          const SizedBox(height: 24),

          // Main Card Content
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                // Child (Multi or Single)
                if (children != null && children!.length > 1)
                  ...children!.map(
                    (child) => _buildRow(
                      label: 'Child',
                      value: _formatChildName(child),
                      subValue: isDriverView
                          ? null
                          : (isPublicRequest
                                ? 'Drivers see: "${_formatPublicChildStr(child)}"'
                                : null),
                      icon: Icons.child_care,
                      iconColor: Colors.purple,
                    ),
                  )
                else
                  _buildRow(
                    label: 'Child',
                    value: displayChildTitle,
                    subValue: privacyNote.isNotEmpty ? privacyNote : null,
                    icon: Icons.child_care,
                    iconColor: Colors.purple,
                  ),
                const Divider(height: 32),

                // Trip Type
                _buildRow(
                  label: 'Trip Type',
                  value: tripCategory,
                  icon: Icons.category,
                  iconColor: Colors.blue,
                ),
                const Divider(height: 32),

                // Direction
                _buildRow(
                  label: 'Direction',
                  value: bookingType,
                  icon: Icons.alt_route,
                  iconColor: Colors.orange,
                ),
                const Divider(height: 32),

                // Locations
                _buildLocationsSection(),
                const Divider(height: 32),

                // Schedule
                _buildRow(
                  label: 'Schedule',
                  value: scheduleType,
                  subValue: scheduleDescription,
                  icon: Icons.calendar_today,
                  iconColor: Colors.indigo,
                ),
                const Divider(height: 32),

                // Notes
                _buildNotesSection(),
                const SizedBox(height: 24),

                // Price Section
                _buildPriceSection(context, priceLabel),
              ],
            ),
          ),

          // Action Buttons (Close / Delete) - Only for View Mode
          if (!isEditable && (onClose != null || onDelete != null)) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                if (onClose != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onClose,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                if (onClose != null && onDelete != null)
                  const SizedBox(width: 16),
                if (onDelete != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 20),
                      label: const Text('Delete'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatChildName(Map<String, dynamic> child) {
    if (isPublicRequest && isDriverView) {
      return _formatPublicChildStr(child);
    }
    return child['name'] ?? 'Child';
  }

  String _formatPublicChildStr([Map<String, dynamic>? child]) {
    // If specific child map provided
    if (child != null) {
      final g = child['gender'] as String? ?? 'Child';
      final gr = child['grade'] as String?;
      final formattedGender = g.isNotEmpty
          ? g[0].toUpperCase() + g.substring(1)
          : 'Child';
      return '$formattedGender${gr != null ? ' ($gr)' : ''}';
    }
    // Fallback to single props
    final g = childGender ?? 'Child';
    final formattedGender = g.isNotEmpty
        ? g[0].toUpperCase() + g.substring(1)
        : 'Child';
    return '$formattedGender${childGrade != null ? ' ($childGrade)' : ''}';
  }

  Widget _buildRow({
    required String label,
    required String value,
    String? subValue,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (subValue != null) ...[
                const SizedBox(height: 4),
                Text(
                  subValue,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Locations',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // If School Transport AND schools list provided (Multi-School view)
        if (schools != null &&
            schools!.isNotEmpty &&
            (tripCategory == 'School Transport' ||
                tripCategory == 'school')) ...[
          // Pickup
          if (locations.isNotEmpty)
            _buildLocationItem(
              locations.first['label'] ?? 'Pickup',
              locations.first['value'] ?? '',
            ),

          // Schools
          ...schools!.map(
            (s) => _buildLocationItem(
              'School',
              '${s['name'] ?? 'School'}${s['address'] != null ? '\n${s['address']}' : ''}',
            ),
          ),
        ] else
          // Legacy / Journey / Single School View
          ...locations.map((loc) {
            final label = loc['label'] ?? '';
            final val = loc['value'] ?? '';
            return _buildLocationItem(label, val);
          }),
      ],
    );
  }

  Widget _buildLocationItem(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          if (label.isNotEmpty) const SizedBox(height: 2),
          Text(
            val,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    // If editable, show input. If view, show box.
    if (isEditable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Notes (Optional)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 3,
            controller: TextEditingController(text: notes),
            decoration: InputDecoration(
              hintText: 'Add instructions...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (val) => onNotesChanged?.call(val),
          ),
        ],
      );
    } else {
      if (notes == null || notes!.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow.shade200),
            ),
            child: Text(
              notes!,
              style: TextStyle(color: Colors.brown.shade800, fontSize: 13),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildPriceSection(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          if (isEditable) ...[
            const SizedBox(height: 8),
            Text(
              'Note: add your chat agreed price with the driver or your suggested price',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: (price == null || price == 0)
                  ? ''
                  : price.toString(),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                suffixText: 'OMR',
                suffixStyle: const TextStyle(color: Colors.white70),
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                final p = double.tryParse(val) ?? 0.0;
                onPriceChanged?.call(p);
              },
            ),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              '${price?.toStringAsFixed(2) ?? '0.00'} OMR',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
