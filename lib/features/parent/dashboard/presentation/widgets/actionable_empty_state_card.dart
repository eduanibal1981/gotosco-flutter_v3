import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActionableEmptyStateCard extends StatelessWidget {
  const ActionableEmptyStateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180, // Matches LiveStatusCard height for layout stability
      width: double.infinity,
      decoration: BoxDecoration(
        // Professional Gradient: Subtle Indigo/White mix
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.indigo.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 1. Background Decor (Subtle bus icon for branding)
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.directions_bus_filled_outlined,
              size: 140,
              color: Colors.indigo.shade50, // Very subtle watermark
            ),
          ),

          // 2. Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.indigo.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Main Message
                const Text(
                  'Ready to book a ride?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find top-rated drivers in your area.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 16),

                // CTA Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to "Find Driver" tab or screen
                      // Since we are using IndexedStack in ParentDashboardScreen,
                      // we might need a callback or just push a new route.
                      // For now, let's push the filter screen as an example:
                      context.push('/driver-filters'); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text(
                      'Find a Driver Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}