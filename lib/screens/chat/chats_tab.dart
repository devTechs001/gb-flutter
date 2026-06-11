import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/chat_model.dart';
import '../../widgets/chat_tile.dart';
import '../chat/chat_screen.dart';
import '../chat/contact_list_screen.dart';

class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChatProvider, AuthProvider>(
      builder: (context, chatProvider, auth, _) {
        final chats = chatProvider.chats
            .where((c) => !(c.archivedBy[auth.userId] ?? false))
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: chats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 80, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      Text(
                        'No chats yet',
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the button below to start a new chat',
                        style: TextStyle(color: AppColors.textHint),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final otherUserId = chat.participants
                        .firstWhere((p) => p != auth.userId);
                    return ChatTile(
                      chat: chat,
                      otherUserId: otherUserId,
                      onTap: () {
                        chatProvider.setCurrentChat(chat);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(chat: chat),
                          ),
                        );
                      },
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactListScreen()),
              );
            },
            child: const Icon(Icons.message),
          ),
        );
      },
    );
  }
}
