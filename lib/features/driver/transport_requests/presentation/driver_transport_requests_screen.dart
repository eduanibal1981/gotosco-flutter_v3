import 'package:flutter/material.dart';
import 'transport_requests_tab.dart';

class DriverTransportRequestsScreen extends StatelessWidget {
  const DriverTransportRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Requests'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const TransportRequestsTab(),
    );
  }
}
