import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/colors.dart';
import '../../utils/helpers.dart';

class GroupSettingsScreen extends StatefulWidget {
  final ChatModel chat;

  const GroupSettingsScreen({super.key, required this.chat});

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  bool _muted = false;
  bool _pinGroup = false;
  bool _onlyAdminsMessage = false;
  bool _onlyAdminsInfo = false;
  bool _approveNewMembers = false;
  String _groupType = 'private';

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final isAdmin = widget.chat.groupAdmin == auth.userId;
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;
    final cardColor = isDark ? const Color(0xFF2A2A3E) : Colors.white;
    final bg = isDark ? const Color(0xFF1A1A2E) : AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Group Settings'),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      ),
      body: ListView(
        children: [
          // Group preview
          Container(
            color: cardColor,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Helpers.generateAvatarColor(widget.chat.groupName ?? 'G'),
                      backgroundImage: widget.chat.groupPhoto != null
                          ? CachedNetworkImageProvider(widget.chat.groupPhoto!)
                          : null,
                      child: widget.chat.groupPhoto == null
                          ? Text(
                              Helpers.getInitials(widget.chat.groupName ?? 'G'),
                              style: const TextStyle(fontSize: 24, color: Colors.white),
                            )
                          : null,
                    ),
                    if (isAdmin)
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(widget.chat.groupName ?? 'Unnamed Group', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                Text('${widget.chat.participants.length} members', style: TextStyle(color: isDark ? Colors.white38 : AppColors.textHint)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Members
          Container(
            color: cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Members (${widget.chat.participants.length})', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                      if (isAdmin)
                        TextButton.icon(
                          onPressed: () => _addMember(context),
                          icon: Icon(Icons.person_add, size: 18, color: accent),
                          label: Text('Add', style: TextStyle(color: accent)),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: widget.chat.participants.length,
                    itemBuilder: (_, i) {
                      final uid = widget.chat.participants[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Helpers.generateAvatarColor(uid),
                              child: Text(Helpers.getInitials(uid), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              uid == auth.userId ? 'You' : uid.substring(0, min(6, uid.length)),
                              style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // General settings
          Container(
            color: cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('General', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                ),
                SwitchListTile(
                  title: Text('Mute notifications', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  subtitle: Text(_muted ? 'All notifications silenced' : 'Notifications on', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12)),
                  value: _muted,
                  activeColor: accent,
                  onChanged: (v) => setState(() => _muted = v),
                ),
                if (isAdmin)
                  SwitchListTile(
                    title: Text('Only admins can message', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text(_onlyAdminsMessage ? 'Members can\'t send messages' : 'Everyone can message', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12)),
                    value: _onlyAdminsMessage,
                    activeColor: accent,
                    onChanged: (v) => setState(() => _onlyAdminsMessage = v),
                  ),
                if (isAdmin)
                  SwitchListTile(
                    title: Text('Only admins can edit group info', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text(_onlyAdminsInfo ? 'Members can\'t change group info' : 'Everyone can edit', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12)),
                    value: _onlyAdminsInfo,
                    activeColor: accent,
                    onChanged: (v) => setState(() => _onlyAdminsInfo = v),
                  ),
                if (isAdmin)
                  SwitchListTile(
                    title: Text('Approve new members', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text(_approveNewMembers ? 'Admin approval required' : 'Anyone can join', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12)),
                    value: _approveNewMembers,
                    activeColor: accent,
                    onChanged: (v) => setState(() => _approveNewMembers = v),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Group type
          Container(
            color: cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Group Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                ),
                RadioListTile<String>(
                  title: Text('Private', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  subtitle: Text('Only admins can add members', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12)),
                  value: 'private',
                  groupValue: _groupType,
                  activeColor: accent,
                  onChanged: isAdmin ? (v) => setState(() => _groupType = v!) : null,
                ),
                RadioListTile<String>(
                  title: Text('Public', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  subtitle: Text('Anyone can join via link', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12)),
                  value: 'public',
                  groupValue: _groupType,
                  activeColor: accent,
                  onChanged: isAdmin ? (v) => setState(() => _groupType = v!) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Actions
          Container(
            color: cardColor,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.share_outlined, color: accent),
                  title: Text('Share group link', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  trailing: Icon(Icons.chevron_right, size: 20, color: isDark ? Colors.white24 : Colors.grey),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.photo_library_outlined, color: accent),
                  title: Text('Shared media', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  trailing: Icon(Icons.chevron_right, size: 20, color: isDark ? Colors.white24 : Colors.grey),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.report_outlined, color: Colors.orange),
                  title: Text('Report group', style: TextStyle(color: Colors.orange)),
                  trailing: Icon(Icons.chevron_right, size: 20, color: isDark ? Colors.white24 : Colors.grey),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.red),
                  title: Text('Exit group', style: TextStyle(color: Colors.red)),
                  trailing: Icon(Icons.chevron_right, size: 20, color: isDark ? Colors.white24 : Colors.grey),
                  onTap: () => _exitGroup(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _addMember(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A3E) : null,
        title: Text('Add Member', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Enter user ID or phone',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Add')),
        ],
      ),
    );
  }

  void _exitGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Group'),
        content: const Text('Are you sure you want to exit this group? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
