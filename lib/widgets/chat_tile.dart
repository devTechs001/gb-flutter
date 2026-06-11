import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../utils/helpers.dart';

class ChatTile extends StatelessWidget {
  final ChatModel chat;
  final String otherUserId;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chat,
    required this.otherUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final otherUser = auth.userModel; // In real app, fetch from user cache

    final unread = chat.unreadCount[auth.userId] ?? 0;
    final isMuted = chat.mutedBy[auth.userId] ?? false;
    final isPinned = chat.pinnedBy[auth.userId] ?? false;

    return Dismissible(
      key: Key(chat.chatId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {},
      child: ListTile(
        onTap: onTap,
        onLongPress: () => _showChatOptions(context),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Helpers.generateAvatarColor(
                chat.displayName.isNotEmpty ? chat.displayName : otherUserId,
              ),
              backgroundImage: chat.displayPhoto.isNotEmpty
                  ? CachedNetworkImageProvider(chat.displayPhoto)
                  : null,
              child: chat.displayPhoto.isEmpty
                  ? Text(
                      Helpers.getInitials(
                        chat.displayName.isNotEmpty ? chat.displayName : otherUserId,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            if (isMuted)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.volume_off, size: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
        title: Text(
          chat.displayName.isNotEmpty ? chat.displayName : otherUser?.displayName ?? otherUserId,
          style: TextStyle(
            fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            if (chat.lastMessageSender != null && chat.isGroup)
              Text(
                '${chat.lastMessageSender}: ',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            Expanded(
              child: Text(
                chat.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: unread > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Helpers.formatTime(chat.lastMessageTime),
              style: TextStyle(
                fontSize: 11,
                color: unread > 0 ? AppColors.accent : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 4),
            if (unread > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isPinned)
              const Icon(Icons.push_pin, size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.volume_off),
              title: Text((chat.mutedBy[context.read<AuthProvider>().userId] ?? false)
                  ? 'Unmute'
                  : 'Mute'),
              onTap: () {
                context.read<ChatProvider>().toggleMute(
                      chat.chatId,
                      context.read<AuthProvider>().userId,
                    );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.push_pin),
              title: Text((chat.pinnedBy[context.read<AuthProvider>().userId] ?? false)
                  ? 'Unpin'
                  : 'Pin'),
              onTap: () {
                context.read<ChatProvider>().togglePin(
                      chat.chatId,
                      context.read<AuthProvider>().userId,
                    );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: Text((chat.archivedBy[context.read<AuthProvider>().userId] ?? false)
                  ? 'Unarchive'
                  : 'Archive'),
              onTap: () {
                context.read<ChatProvider>().toggleArchive(
                      chat.chatId,
                      context.read<AuthProvider>().userId,
                    );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete chat', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
