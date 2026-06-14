import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../theme/zeno_colors.dart';

class ArchivedScreen extends StatelessWidget {
  const ArchivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final userId = context.watch<AuthProvider>().userId;
    final archivedChats = chatProvider.chats
        .where((c) => c.archivedBy[userId] == true)
        .toList();

    return Scaffold(
      backgroundColor: ZenoColors.background,
      appBar: AppBar(
        title: const Text('Archived'),
        backgroundColor: ZenoColors.primary,
      ),
      body: archivedChats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.archive_outlined, size: 80, color: ZenoColors.textHint),
                  const SizedBox(height: 16),
                  Text('No archived chats', style: TextStyle(color: ZenoColors.textSecondary, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: archivedChats.length,
              itemBuilder: (context, index) {
                final chat = archivedChats[index];
                final displayName = chat.displayName.isNotEmpty ? chat.displayName : chat.chatId;
                return Card(
                  color: ZenoColors.surface,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ZenoColors.primary,
                      child: Text(
                        displayName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(chat.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.unarchive_rounded, color: ZenoColors.primary),
                    onTap: () => chatProvider.toggleArchive(chat.chatId, userId),
                  ),
                );
              },
            ),
    );
  }
}
