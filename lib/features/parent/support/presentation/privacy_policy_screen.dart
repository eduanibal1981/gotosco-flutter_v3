import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'What We Collect',
            'We collect account details, booking data, and safety-related '
                'information (e.g., child profiles and emergency contacts).',
          ),
          _buildSection(
            'Location Data',
            'Location is used for matching nearby drivers, routing, and live '
                'trip tracking. Location sharing is limited to active trips.',
          ),
          _buildSection(
            'Notifications',
            'We use push notifications for critical ride events. You can '
                'manage notification preferences in the Profile section.',
          ),
          _buildSection(
            'How We Use Data',
            'Data is used to fulfill bookings, improve safety, and provide '
                'support. We do not sell personal data.',
          ),
          _buildSection(
            'Sharing',
            'We only share required data with the assigned driver for a ride. '
                'Schools and companies may access limited operational info.',
          ),
          _buildSection(
            'Retention',
            'We keep data as long as necessary for service delivery and legal '
                'requirements.',
          ),
          _buildSection(
            'Your Rights',
            'You can request data access, correction, or deletion via Support.',
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
