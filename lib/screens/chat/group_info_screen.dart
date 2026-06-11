import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../theme/colors.dart';
import '../../utils/helpers.dart';

class GroupInfoScreen extends StatefulWidget {
  final ChatModel chat;

  const GroupInfoScreen({super.key, required this.chat});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = widget.chat.groupAdmin == auth.userId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Group Info')),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: widget.chat.groupPhoto != null
                          ? CachedNetworkImageProvider(widget.chat.groupPhoto!)
                          : null,
                      child: widget.chat.groupPhoto == null
                          ? const Icon(Icons.group, size: 40, color: Colors.white)
                          : null,
                    ),
                    if (isAdmin)
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent,
                          ),
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.chat.groupName ?? 'Unnamed Group',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                if (widget.chat.groupDescription != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      widget.chat.groupDescription!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  '${widget.chat.participants.length} participants',
                  style: TextStyle(color: AppColors.textHint),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Participants', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      if (isAdmin)
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text('Add'),
                        ),
                    ],
                  ),
                ),
                ...widget.chat.participants.map((uid) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Helpers.generateAvatarColor(uid),
                    child: Text(
                      Helpers.getInitials(uid),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(uid == auth.userId ? 'You' : uid),
                  subtitle: uid == widget.chat.groupAdmin
                      ? const Text('Admin', style: TextStyle(color: AppColors.accent, fontSize: 12))
                      : null,
                  trailing: uid == widget.chat.groupAdmin
                      ? const Icon(Icons.star, color: AppColors.accent, size: 20)
                      : (isAdmin ? const Icon(Icons.more_vert) : null),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildAction(Icons.photo, 'Media, links, and docs'),
                _buildAction(Icons.notifications_outlined, 'Mute notifications'),
                _buildAction(Icons.lock_outline, 'Encryption'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                if (isAdmin)
                  _buildAction(Icons.edit, 'Edit group info'),
                _buildAction(Icons.exit_to_app, 'Exit group', color: Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String title, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title: Text(title, style: color != null ? TextStyle(color: color) : null),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textHint),
      onTap: () {},
    );
  }
}
