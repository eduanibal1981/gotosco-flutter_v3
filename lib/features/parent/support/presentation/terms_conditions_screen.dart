import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Overview',
            'These terms explain how GoToSco works for parents, drivers, '
                'and schools. By using the app, you accept these terms.',
          ),
          _buildSection(
            'Accounts & Eligibility',
            'You must provide accurate personal details and keep your '
                'contact information up to date.',
          ),
          _buildSection(
            'Booking & Cancellations',
            'Bookings are requests until accepted by a driver. You can '
                'cancel at any time; repeated last-minute cancellations may '
                'impact your account.',
          ),
          _buildSection(
            'Payments',
            'Prices are shown before confirmation. Payment status is tracked '
                'per booking. Disputes should be reported through Support.',
          ),
          _buildSection(
            'Safety & Conduct',
            'Drivers must follow trip rules and safety requirements. Parents '
                'must provide accurate pickup/dropoff details and emergency '
                'contacts.',
          ),
          _buildSection(
            'Notifications',
            'We send ride updates like approaching, picked up, and dropped off. '
                'You can manage notification settings in your profile.',
          ),
          _buildSection(
            'Location Usage',
            'Location is used to match nearby drivers and enable live tracking. '
                'We only share the minimum route information needed for rides.',
          ),
          _buildSection(
            'Liability',
            'GoToSco facilitates booking and communication. Drivers are '
                'independent service providers responsible for transport.',
          ),
          _buildSection(
            'Changes',
            'We may update these terms as the service evolves. Important changes '
                'will be communicated in-app.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
