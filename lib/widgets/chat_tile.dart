import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/zeno_colors.dart';
import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/theme_provider.dart';
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
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode;
    final accentColor = theme.accentColor;
    final bubbleColor = theme.bubbleColor;

    final otherUser = auth.userModel;
    final unread = chat.unreadCount[auth.userId] ?? 0;
    final isMuted = chat.mutedBy[auth.userId] ?? false;
    final isPinned = chat.pinnedBy[auth.userId] ?? false;

    return Dismissible(
      key: Key(chat.chatId),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.withValues(alpha: 0.8), Colors.red],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showChatOptions(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
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
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          )
                        : null,
                  ),
                  if (isMuted)
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF1E1E32) : Colors.white,
                          border: Border.all(color: isDark ? const Color(0xFF1E1E32) : Colors.white, width: 1),
                        ),
                        child: Icon(Icons.volume_off_rounded, size: 10, color: Colors.grey[500]),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            chat.displayName.isNotEmpty ? chat.displayName : otherUser?.displayName ?? otherUserId,
                            style: TextStyle(
                              fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 15,
                              color: isDark ? Colors.white : (unread > 0 ? Colors.black87 : Colors.black87),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isPinned)
                          Icon(Icons.push_pin_rounded, size: 14, color: Colors.grey[400]),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (chat.lastMessageSender != null && chat.isGroup)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              '${chat.lastMessageSender}: ',
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            chat.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: unread > 0
                                  ? (isDark ? Colors.white70 : AppColors.textPrimary)
                                  : (isDark ? Colors.white38 : AppColors.textSecondary),
                              fontSize: 13,
                              fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Helpers.formatTime(chat.lastMessageTime),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                      color: unread > 0 ? accentColor : (isDark ? Colors.white38 : AppColors.textHint),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (unread > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentColor, accentColor.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        unread > 99 ? '99+' : '$unread',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (unread == 0 && chat.lastMessageType == 'image')
                    Icon(Icons.photo_rounded, size: 16, color: Colors.grey[400]),
                  if (unread == 0 && chat.lastMessageType == 'video')
                    Icon(Icons.videocam_rounded, size: 16, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = theme.isDarkMode;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  chat.displayName.isNotEmpty ? chat.displayName : 'Chat Options',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[500]),
                ),
              ),
              _menuItem(context, Icons.volume_off_rounded, (chat.mutedBy[context.read<AuthProvider>().userId] ?? false) ? 'Unmute' : 'Mute', () {
                context.read<ChatProvider>().toggleMute(chat.chatId, context.read<AuthProvider>().userId);
                Navigator.pop(context);
              }),
              _menuItem(context, Icons.push_pin_rounded, (chat.pinnedBy[context.read<AuthProvider>().userId] ?? false) ? 'Unpin' : 'Pin', () {
                context.read<ChatProvider>().togglePin(chat.chatId, context.read<AuthProvider>().userId);
                Navigator.pop(context);
              }),
              _menuItem(context, Icons.archive_outlined, (chat.archivedBy[context.read<AuthProvider>().userId] ?? false) ? 'Unarchive' : 'Archive', () {
                context.read<ChatProvider>().toggleArchive(chat.chatId, context.read<AuthProvider>().userId);
                Navigator.pop(context);
              }),
              _menuItem(context, Icons.notifications_off_rounded, 'Mark as Read', () => Navigator.pop(context), color: Colors.orange),
              _menuItem(context, Icons.delete_outline_rounded, 'Delete Chat', () => Navigator.pop(context), color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? color}) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = theme.isDarkMode;
    return ListTile(
      dense: true,
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: (color ?? theme.accentColor).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color ?? theme.accentColor, size: 22),
      ),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
