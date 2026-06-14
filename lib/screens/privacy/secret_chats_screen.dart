import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/privacy_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/zeno_colors.dart';
import '../../models/chat_model.dart';

class SecretChatsScreen extends StatefulWidget {
  final int initialTab;

  const SecretChatsScreen({super.key, this.initialTab = 0});

  @override
  State<SecretChatsScreen> createState() => _SecretChatsScreenState();
}

class _SecretChatsScreenState extends State<SecretChatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secret Chats'),
        backgroundColor: ZenoColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Hidden Chats'),
            Tab(text: 'Archived Chats'),
          ],
        ),
      ),
      backgroundColor: bgColor,
      body: TabBarView(
        controller: _tabController,
        children: [
          _ChatList(type: ChatListType.hidden),
          _ChatList(type: ChatListType.archived),
        ],
      ),
    );
  }
}

enum ChatListType { hidden, archived }

class _ChatList extends StatelessWidget {
  final ChatListType type;

  const _ChatList({required this.type});

  @override
  Widget build(BuildContext context) {
    final privacy = context.watch<PrivacyProvider>();
    final chatIds = type == ChatListType.hidden
        ? privacy.hiddenChats
        : privacy.archivedChats;
    final isEmpty = chatIds.isEmpty;

    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type == ChatListType.hidden
                  ? Icons.lock_outline
                  : Icons.archive_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              type == ChatListType.hidden
                  ? 'No hidden chats'
                  : 'No archived chats',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type == ChatListType.hidden
                  ? 'Chats you hide will appear here'
                  : 'Chats you archive will appear here',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: chatIds.length,
      itemBuilder: (context, index) {
        final chatId = chatIds[index];
        return _ChatSwipeTile(
          chatId: chatId,
          type: type,
        );
      },
    );
  }
}

class _ChatSwipeTile extends StatelessWidget {
  final String chatId;
  final ChatListType type;

  const _ChatSwipeTile({required this.chatId, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Dismissible(
      key: ValueKey(chatId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: ZenoColors.primary,
        child: Icon(
          type == ChatListType.hidden ? Icons.visibility : Icons.unarchive,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) {
        final privacy = context.read<PrivacyProvider>();
        if (type == ChatListType.hidden) {
          privacy.removeHiddenChat(chatId);
        } else {
          privacy.removeArchivedChat(chatId);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              type == ChatListType.hidden
                  ? 'Chat unhidden'
                  : 'Chat unarchived',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ZenoColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.lock_outline,
              color: ZenoColors.primary,
              size: 22,
            ),
          ),
          title: Text(
            chatId,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            type == ChatListType.hidden ? 'Hidden chat' : 'Archived chat',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
          onTap: () {
            // TODO: Navigate to the actual chat
          },
        ),
      ),
    );
  }
}
