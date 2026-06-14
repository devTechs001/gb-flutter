import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/zeno_colors.dart';
import '../../theme/colors.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/chat_tile.dart';
import '../chat/chat_screen.dart';
import '../chat/contact_list_screen.dart';
import '../settings/settings_screen.dart';

class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> with SingleTickerProviderStateMixin {
  late TabController _folderController;
  final List<String> _folders = ['All', 'Unread', 'Favorites', 'Groups'];
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _folderController = TabController(length: _folders.length, vsync: this);
  }

  @override
  void dispose() {
    _folderController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChatProvider, AuthProvider>(
      builder: (context, chatProvider, auth, _) {
        final allChats = chatProvider.chats
            .where((c) => !(c.archivedBy[auth.userId] ?? false))
            .toList();

        List<MapEntry<String, dynamic>> _getFilteredChats(String folder) {
          var chats = allChats;
          if (folder == 'Unread') {
            chats = chats.where((c) => (c.unreadCount[auth.userId] ?? 0) > 0).toList();
          } else if (folder == 'Favorites') {
            chats = chats.where((c) => c.pinnedBy[auth.userId] ?? false).toList();
          } else if (folder == 'Groups') {
            chats = chats.where((c) => c.isGroup).toList();
          }
          if (_searchQuery.isNotEmpty) {
            chats = chats.where((c) =>
              c.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase())
            ).toList();
          }
          return chats.map((c) => MapEntry(c.chatId, c)).toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search chats...',
                      border: InputBorder.none,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  )
                : GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    )),
                    child: const Text('ChatWave'),
                  ),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _searchQuery = '';
                    }
                  });
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (v) {},
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'new_group', child: ListTile(leading: Icon(Icons.group_add), title: Text('New group'), dense: true)),
                  const PopupMenuItem(value: 'broadcast', child: ListTile(leading: Icon(Icons.campaign), title: Text('New broadcast'), dense: true)),
                  const PopupMenuItem(value: 'chatwave_web', child: ListTile(leading: Icon(Icons.computer), title: Text('ChatWave Web'), dense: true)),
                  const PopupMenuItem(value: 'starred', child: ListTile(leading: Icon(Icons.star), title: Text('Starred messages'), dense: true)),
                ],
              ),
            ],
            bottom: _isSearching
                ? null
                : TabBar(
                    controller: _folderController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: ZenoColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: ZenoColors.primary,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                    tabs: _folders.map((folder) {
                      final count = folder == 'Unread'
                          ? allChats.where((c) => (c.unreadCount[auth.userId] ?? 0) > 0).length
                          : folder == 'Favorites'
                              ? allChats.where((c) => c.pinnedBy[auth.userId] ?? false).length
                              : folder == 'Groups'
                                  ? allChats.where((c) => c.isGroup).length
                                  : allChats.length;
                      return Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(folder),
                            if (count > 0 && folder != 'All') ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: ZenoColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ZenoColors.primary),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          body: chatProvider.chats.isEmpty && !chatProvider.isLoading
              ? _buildEmptyState()
              : chatProvider.isLoading
                  ? _buildShimmerLoading()
                  : TabBarView(
                      controller: _folderController,
                      children: _folders.map((folder) {
                        final filtered = _getFilteredChats(folder);
                        if (filtered.isEmpty) {
                          return _buildFolderEmptyState(folder);
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            await Future.delayed(const Duration(seconds: 1));
                          },
                          color: ZenoColors.primary,
                          child: ListView.builder(
                            itemCount: filtered.length,
                            padding: const EdgeInsets.only(bottom: 80),
                            itemBuilder: (context, index) {
                              final chat = filtered[index].value;
                              final otherUserId = chat.participants.firstWhere((p) => p != auth.userId);
                              return ChatTile(
                                chat: chat,
                                otherUserId: otherUserId,
                                onTap: () {
                                  chatProvider.setCurrentChat(chat);
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => ChatScreen(chat: chat),
                                  ));
                                },
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'new_chat_fab',
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const ContactListScreen(),
            )),
            backgroundColor: ZenoColors.primary,
            child: const Icon(Icons.message_rounded, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: ZenoColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, size: 44, color: ZenoColors.primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 20),
          const Text('No chats yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Tap the button below to start a new chat', style: TextStyle(color: AppColors.textHint)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const ContactListScreen(),
            )),
            icon: const Icon(Icons.add),
            label: const Text('New Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ZenoColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderEmptyState(String folder) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            folder == 'Unread' ? Icons.done_all_rounded :
            folder == 'Favorites' ? Icons.star_rounded :
            folder == 'Groups' ? Icons.group_rounded : Icons.chat_bubble_outline_rounded,
            size: 56,
            color: ZenoColors.textHint.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No $folder chats',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 8,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120, height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 200, height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
