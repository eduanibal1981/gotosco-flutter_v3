import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String _supportEmail = 'support@gotosco.com';
  static const String _supportPhone = '+96800000000';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildIntroCard(),
          const SizedBox(height: 16),
          _buildQuickActions(context),
          const SizedBox(height: 16),
          _buildSectionTitle('Getting Started'),
          _buildFaqItem(
            title: 'How do I add my child?',
            body:
                'Go to Children tab > Add Child. Fill school, grade, and '
                'emergency contact so drivers can support your child safely.',
          ),
          _buildFaqItem(
            title: 'How do I find a driver?',
            body:
                'Use the Find tab to browse verified drivers. Apply filters '
                'by area or school to narrow the list.',
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Bookings'),
          _buildFaqItem(
            title: 'How do I create a booking?',
            body:
                'Open a driver profile and tap Book Now. Choose trip type, '
                'pickup times, and your child.',
          ),
          _buildFaqItem(
            title: 'Can I cancel a booking?',
            body:
                'Yes. Go to Bookings tab and select Cancel. The driver will '
                'be notified.',
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Tracking & Safety'),
          _buildFaqItem(
            title: 'Where do I see live tracking?',
            body:
                'From the Home dashboard or Bookings tab, tap Track to view '
                'the driver on the map.',
          ),
          _buildFaqItem(
            title: 'Who can see my location?',
            body:
                'Only your assigned driver and the GoToSco system can access '
                'route details necessary for transport.',
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Payments'),
          _buildFaqItem(
            title: 'How are payments handled?',
            body:
                'Payments are linked to your booking. You can review the '
                'status in Bookings and your receipts in the profile.',
          ),
          const SizedBox(height: 24),
          _buildSupportCard(context),
          const SizedBox(height: 16),
          _buildLegalLinks(context),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade600,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.support_agent, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'We are here to help you use the app with confidence.',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            icon: Icons.chat_bubble_outline,
            label: 'Open Chats',
            onTap: () => context.push('/parent-chats'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionTile(
            icon: Icons.report_problem_outlined,
            label: 'Report Issue',
            onTap: () => _sendEmail(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.indigo),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFaqItem({required String title, required String body}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            body,
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Support',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Email: $_supportEmail',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            'Phone: $_supportPhone',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _sendEmail,
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Email Us'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _callPhone(context),
                  icon: const Icon(Icons.phone_outlined),
                  label: const Text('Call Us'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegalLinks(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => context.push('/terms'),
          child: const Text('Terms'),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: () => context.push('/privacy'),
          child: const Text('Privacy'),
        ),
      ],
    );
  }

  Future<void> _sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: 'subject=Help%20Request',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _callPhone(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: _supportPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
