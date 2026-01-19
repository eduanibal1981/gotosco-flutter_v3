// lib/features/parent/dashboard/presentation/widgets/transport_request_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../transport_requests/data/transport_requests_repository.dart';

class TransportRequestCard extends ConsumerWidget {
  const TransportRequestCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(parentTransportRequestsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade700, Colors.indigo.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildRequestsList(context, ref, requests);
        },
        loading: () => _buildLoadingState(),
        error: (err, _) => _buildErrorState(err.toString()),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Need specific transport?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Post a request and let drivers contact you with offers.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Tip: add the price you want in the notes.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/transport-request');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.post_add, size: 18),
                label: const Text("Add Request"),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _buildDecorIcon(),
      ],
    );
  }

  Widget _buildRequestsList(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> requests,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Requests",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Add another request if you need more routes.",
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildRequestTile(context, ref, request);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/transport-request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add Another"),
              ),
            ),
            const SizedBox(width: 12),
            _buildDecorIcon(),
          ],
        ),
      ],
    );
  }

  Widget _buildRequestTile(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> request,
  ) {
    final childName = request['child_name'] as String? ?? 'Child';
    final schoolName = request['school_name'] as String? ?? 'School';
    final status = request['status'] as String? ?? 'open';
    final id = request['id'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  schoolName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildStatusChip(status),
          IconButton(
            onPressed: id.isEmpty
                ? null
                : () => _confirmDelete(context, ref, id),
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final label = status.toUpperCase();
    final color = status == 'open'
        ? Colors.green
        : status == 'closed'
            ? Colors.orange
            : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDecorIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.campaign_outlined, color: Colors.white, size: 32),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 80,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Text(
      'Error: $message',
      style: const TextStyle(color: Colors.white),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String requestId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete request?'),
        content: const Text(
          'This will remove the request from the marketplace.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(transportRequestsRepositoryProvider)
          .deleteRequest(requestId);
      ref.invalidate(parentTransportRequestsProvider);
    }
  }
}
