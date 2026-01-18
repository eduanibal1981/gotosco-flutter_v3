// lib/features/driver/messages/presentation/driver_messages_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/driver_messages_repository.dart';

class DriverMessagesScreen extends ConsumerStatefulWidget {
  const DriverMessagesScreen({super.key});

  @override
  ConsumerState<DriverMessagesScreen> createState() =>
      _DriverMessagesScreenState();
}

class _DriverMessagesScreenState extends ConsumerState<DriverMessagesScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(driverConversationsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              )
            : null, // Default back button
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.black87),
                decoration: const InputDecoration(
                  hintText: 'Search messages...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text(
                'Messages',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            )
          else
            IconButton(
              icon: Icon(Icons.search, color: Colors.grey.shade600),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
        ],
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          final filteredConversations = _searchQuery.isEmpty
              ? conversations
              : conversations.where((c) {
                  final query = _searchQuery.toLowerCase();
                  return c.parentName.toLowerCase().contains(query) ||
                      c.lastMessage.toLowerCase().contains(query);
                }).toList();

          if (filteredConversations.isEmpty) {
            if (_isSearching) {
              return _buildNoSearchResults();
            }
            return _buildEmptyState();
          }
          return _buildConversationsList(context, ref, filteredConversations);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Error loading messages',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              TextButton(
                onPressed: () =>
                    ref.invalidate(driverConversationsStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.message_outlined,
                size: 64,
                color: Colors.blue.shade300,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Messages Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When parents message you about bookings,\nthey will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with a different keyword',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(
    BuildContext context,
    WidgetRef ref,
    List<ConversationModel> conversations,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: conversations.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, indent: 80, color: Colors.grey.shade200),
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _ConversationTile(
          conversation: conversation,
          onTap: () async {
            // Mark as read
            await ref
                .read(driverMessagesRepositoryProvider)
                .markConversationAsRead(conversation.parentId);

            // Navigate to chat
            if (context.mounted) {
              context.push(
                '/chat',
                extra: {
                  'userId': conversation.parentId,
                  'userName': conversation.parentName,
                },
              );
            }
          },
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: hasUnread ? Colors.blue.shade50.withOpacity(0.3) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: conversation.parentPhotoUrl != null
                      ? NetworkImage(conversation.parentPhotoUrl!)
                      : null,
                  child: conversation.parentPhotoUrl == null
                      ? Text(
                          conversation.parentName.isNotEmpty
                              ? conversation.parentName[0].toUpperCase()
                              : 'P',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        )
                      : null,
                ),
                // Online indicator (optional - could be added later)
              ],
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.parentName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: hasUnread
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(conversation.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: hasUnread
                              ? Colors.blue.shade600
                              : Colors.grey.shade500,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Message preview and unread badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: hasUnread
                                ? Colors.black87
                                : Colors.grey.shade600,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            conversation.unreadCount > 99
                                ? '99+'
                                : conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Chevron
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m';
    } else if (diff.inDays < 1) {
      return DateFormat('h:mm a').format(time);
    } else if (diff.inDays < 7) {
      return DateFormat('EEE').format(time); // Mon, Tue, etc.
    } else {
      return DateFormat('MMM d').format(time); // Jan 15
    }
  }
}
