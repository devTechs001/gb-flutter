import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../theme/zeno_colors.dart';
import '../../utils/helpers.dart';

class StarredScreen extends StatelessWidget {
  const StarredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final starred = chatProvider.messages.where((m) => m.isStarred).toList();

    return Scaffold(
      backgroundColor: ZenoColors.background,
      appBar: AppBar(
        title: const Text('Starred Messages'),
        backgroundColor: ZenoColors.primary,
      ),
      body: starred.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_outline_rounded, size: 80, color: ZenoColors.textHint),
                  const SizedBox(height: 16),
                  Text('No starred messages', style: TextStyle(color: ZenoColors.textSecondary, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: starred.length,
              itemBuilder: (context, index) {
                final msg = starred[index];
                final chat = chatProvider.chats.where((c) => c.chatId == msg.chatId).firstOrNull;
                return Card(
                  color: ZenoColors.surface,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Helpers.generateAvatarColor(msg.senderName),
                      radius: 18,
                      child: Text(
                        Helpers.getInitials(msg.senderName),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(msg.senderName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.content.length > 60 ? '${msg.content.substring(0, 60)}...' : msg.content,
                          style: TextStyle(color: ZenoColors.textSecondary, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (chat != null)
                          Text(
                            chat.displayName.isNotEmpty ? 'in ${chat.displayName}' : msg.chatId,
                            style: TextStyle(color: ZenoColors.textHint, fontSize: 11),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 18, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          Helpers.formatTime(msg.timestamp),
                          style: TextStyle(color: ZenoColors.textHint, fontSize: 11),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
    );
  }
}
