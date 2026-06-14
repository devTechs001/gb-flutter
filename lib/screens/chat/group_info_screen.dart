import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/socket_service.dart';
import '../../theme/colors.dart';
import '../../utils/helpers.dart';
import 'group_settings_screen.dart';

class GroupInfoScreen extends StatefulWidget {
  final ChatModel chat;

  const GroupInfoScreen({super.key, required this.chat});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final List<String> _sampleReactions = ['❤️', '😂', '👍', '😮', '😢', '🙏'];
  late List<String> _participants;

  @override
  void initState() {
    super.initState();
    _participants = List.from(widget.chat.participants);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final socket = context.read<SocketService>();
    final isAdmin = widget.chat.groupAdmin == auth.userId;
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;
    final bg = isDark ? const Color(0xFF1A1A2E) : AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Group Info'),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
        actions: [
          if (isAdmin)
            IconButton(
              icon: Icon(Icons.settings, color: accent),
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => GroupSettingsScreen(chat: widget.chat),
              )),
            ),
        ],
      ),
      body: ListView(
        children: [
          _buildGroupHeader(isDark, accent, auth),
          const SizedBox(height: 8),
          _buildParticipantsSection(isDark, accent, auth, socket),
          const SizedBox(height: 8),
          _buildOptionsSection(isDark, accent, chatProvider),
          const SizedBox(height: 8),
          _buildActionsSection(isDark, accent, auth, socket),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(bool isDark, Color accent, AuthProvider auth) {
    return Container(
      color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Helpers.generateAvatarColor(widget.chat.groupName ?? 'G'),
                backgroundImage: widget.chat.groupPhoto != null
                    ? CachedNetworkImageProvider(widget.chat.groupPhoto!)
                    : null,
                child: widget.chat.groupPhoto == null
                    ? Text(Helpers.getInitials(widget.chat.groupName ?? 'G'), style: const TextStyle(fontSize: 28, color: Colors.white))
                    : null,
              ),
              if (widget.chat.groupAdmin == auth.userId)
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
                    child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: widget.chat.groupAdmin == auth.userId ? () => _editGroupInfo(context) : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.chat.groupName ?? 'Unnamed Group', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                if (widget.chat.groupAdmin == auth.userId) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.edit, size: 18, color: accent),
                ],
              ],
            ),
          ),
          if (widget.chat.groupDescription != null && widget.chat.groupDescription!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(widget.chat.groupDescription!, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary)),
            ),
          const SizedBox(height: 12),
          Text('${_participants.length} participants', style: TextStyle(color: isDark ? Colors.white38 : AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(bool isDark, Color accent, AuthProvider auth, SocketService socket) {
    return Container(
      color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Participants', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                if (widget.chat.groupAdmin == auth.userId)
                  TextButton.icon(
                    onPressed: () => _addParticipant(context),
                    icon: Icon(Icons.person_add, size: 18, color: accent),
                    label: Text('Add', style: TextStyle(color: accent)),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _participants.length,
              itemBuilder: (_, i) {
                final uid = _participants[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Helpers.generateAvatarColor(uid),
                            child: Text(Helpers.getInitials(uid), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          if (uid == widget.chat.groupAdmin)
                            Positioned(
                              bottom: -2, right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.amber, border: Border.all(color: isDark ? const Color(0xFF2A2A3E) : Colors.white, width: 2)),
                                child: const Icon(Icons.star, size: 10, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(uid == auth.userId ? 'You' : uid.length > 6 ? '${uid.substring(0, 6)}..' : uid, style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(bool isDark, Color accent, ChatProvider chatProvider) {
    return Container(
      color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
      child: Column(
        children: [
          _buildTile(Icons.photo, 'Media, links, and docs', accent, isDark, () => _showMedia(context, chatProvider)),
          _buildTile(Icons.emoji_emotions_outlined, 'Reactions', accent, isDark, () => _showReactions(context)),
          _buildTile(Icons.notifications_outlined, 'Mute notifications', accent, isDark, () => _muteGroup(context)),
          _buildTile(Icons.lock_outline, 'Encryption', accent, isDark, () => _showEncryptionInfo(context)),
          _buildTile(Icons.search, 'Search in group', accent, isDark, () => Helpers.showSnackBar(context, 'Search in group messages')),
        ],
      ),
    );
  }

  Widget _buildActionsSection(bool isDark, Color accent, AuthProvider auth, SocketService socket) {
    return Container(
      color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
      child: Column(
        children: [
          if (widget.chat.groupAdmin == auth.userId)
            _buildTile(Icons.edit, 'Edit group info', accent, isDark, () => _editGroupInfo(context)),
          _buildTile(Icons.share_outlined, 'Share group link', accent, isDark, () => _shareGroupLink(context)),
          _buildTile(Icons.content_copy, 'Copy group ID', accent, isDark, () => _copyGroupId(context)),
          _buildTile(Icons.exit_to_app, 'Exit group', Colors.red, isDark, () => _exitGroup(context, auth, socket)),
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, Color color, bool isDark, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
      trailing: Icon(Icons.chevron_right, size: 20, color: isDark ? Colors.white24 : AppColors.textHint),
      onTap: onTap,
    );
  }

  void _editGroupInfo(BuildContext context) {
    final theme = context.read<ThemeProvider>();
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;
    final nameCtl = TextEditingController(text: widget.chat.groupName);
    final descCtl = TextEditingController(text: widget.chat.groupDescription ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A3E) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Group Info', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtl,
              decoration: InputDecoration(labelText: 'Group Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: isDark ? const Color(0xFF1A1A2E) : Colors.grey[50]),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtl,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: isDark ? const Color(0xFF1A1A2E) : Colors.grey[50]),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (nameCtl.text.trim().isNotEmpty) {
                context.read<SocketService>().updateGroupInfo(widget.chat.chatId, {'groupName': nameCtl.text.trim(), 'groupDescription': descCtl.text.trim()});
                Helpers.showSnackBar(context, 'Group info updated via socket');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addParticipant(BuildContext context) {
    final theme = context.read<ThemeProvider>();
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;
    final uidCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A3E) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Participant', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: TextField(
          controller: uidCtl,
          decoration: InputDecoration(hintText: 'Enter user ID or phone', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: isDark ? const Color(0xFF1A1A2E) : Colors.grey[50]),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (uidCtl.text.trim().isNotEmpty) {
                final uid = uidCtl.text.trim();
                setState(() => _participants.add(uid));
                context.read<SocketService>().addGroupMember(widget.chat.chatId, uid, context.read<AuthProvider>().userId);
                Helpers.showSnackBar(context, '$uid added to group');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showMedia(BuildContext context, ChatProvider chatProvider) {
    final theme = context.read<ThemeProvider>();
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;
    final images = chatProvider.messages.where((m) => m.type == 'image').toList();
    final videos = chatProvider.messages.where((m) => m.type == 'video').toList();
    final docs = chatProvider.messages.where((m) => m.type == 'document').toList();
    final links = chatProvider.messages.where((m) => m.linkPreviewUrl != null).toList();

    IconData _docIcon(String? fileName) {
      final name = (fileName ?? '').toLowerCase();
      if (name.endsWith('.pdf')) return Icons.picture_as_pdf;
      if (name.endsWith('.doc') || name.endsWith('.docx')) return Icons.description;
      if (name.endsWith('.xls') || name.endsWith('.xlsx')) return Icons.table_chart;
      if (name.endsWith('.ppt') || name.endsWith('.pptx')) return Icons.slideshow;
      if (name.endsWith('.txt')) return Icons.text_snippet;
      if (name.endsWith('.zip') || name.endsWith('.rar')) return Icons.folder_zip;
      return Icons.insert_drive_file;
    }

    Color _docColor(String? fileName) {
      final name = (fileName ?? '').toLowerCase();
      if (name.endsWith('.pdf')) return Colors.red;
      if (name.endsWith('.doc') || name.endsWith('.docx')) return Colors.blue;
      if (name.endsWith('.xls') || name.endsWith('.xlsx')) return Colors.green;
      if (name.endsWith('.ppt') || name.endsWith('.pptx')) return Colors.orange;
      return Colors.grey;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 12),
              Text('Shared Media', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 4),
              Text('${images.length} images · ${videos.length} videos · ${docs.length} docs', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey)),
              const SizedBox(height: 12),
              DefaultTabController(
                length: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TabBar(
                      isScrollable: true, tabAlignment: TabAlignment.start,
                      indicatorColor: accent, labelColor: accent,
                      unselectedLabelColor: isDark ? Colors.white54 : Colors.grey,
                      tabs: [
                        Tab(text: 'Media (${images.length + videos.length})'),
                        Tab(text: 'Docs (${docs.length})'),
                        Tab(text: 'Links (${links.length})'),
                        Tab(text: 'Polls'),
                      ],
                    ),
                    SizedBox(
                      height: 250,
                      child: TabBarView(
                        children: [
                          images.isEmpty && videos.isEmpty
                              ? Center(child: Text('No media shared', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey)))
                              : GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 4, crossAxisSpacing: 4),
                                  itemCount: images.length + videos.length,
                                  itemBuilder: (_, i) {
                                    if (i < images.length) {
                                      final img = images[i];
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: isDark ? const Color(0xFF2A2A3E) : Colors.grey[200],
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: img.mediaURL != null
                                            ? CachedNetworkImage(
                                                imageUrl: img.mediaURL!,
                                                fit: BoxFit.cover,
                                                placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                                errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 28, color: Colors.grey)),
                                              )
                                            : const Center(child: Icon(Icons.image, size: 32, color: Colors.grey)),
                                      );
                                    }
                                    final vid = videos[i - images.length];
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: isDark ? const Color(0xFF2A2A3E) : Colors.grey[200],
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          if (vid.thumbnailURL != null)
                                            CachedNetworkImage(
                                              imageUrl: vid.thumbnailURL!,
                                              fit: BoxFit.cover,
                                              width: double.infinity, height: double.infinity,
                                              placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                              errorWidget: (_, __, ___) => const Center(child: Icon(Icons.videocam, size: 28, color: Colors.grey)),
                                            )
                                          else
                                            const Center(child: Icon(Icons.videocam, size: 28, color: Colors.grey)),
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.5)),
                                            child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                          docs.isEmpty
                              ? Center(child: Text('No documents', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey)))
                              : ListView.builder(
                                  itemCount: docs.length,
                                  itemBuilder: (_, i) {
                                    final doc = docs[i];
                                    return ListTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _docColor(doc.fileName).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(_docIcon(doc.fileName), color: _docColor(doc.fileName)),
                                      ),
                                      title: Text(doc.fileName ?? 'Document', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      subtitle: Text(doc.content.isNotEmpty ? doc.content : 'No preview', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    );
                                  },
                                ),
                          links.isEmpty
                              ? Center(child: Text('No links shared', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey)))
                              : ListView.builder(
                                  itemCount: links.length,
                                  itemBuilder: (_, i) {
                                    final link = links[i];
                                    return Card(
                                      color: isDark ? const Color(0xFF2A2A3E) : Colors.grey[50],
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      child: ListTile(
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: accent.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.link, color: accent, size: 20),
                                        ),
                                        title: Text(
                                          link.linkPreviewTitle ?? (link.linkPreviewUrl ?? 'Link'),
                                          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (link.linkPreviewDescription != null && link.linkPreviewDescription!.isNotEmpty)
                                              Text(link.linkPreviewDescription!, style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            Text(link.linkPreviewUrl ?? '', style: TextStyle(color: accent, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          Center(child: Text('No polls', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showReactions(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 12),
              Text('Quick Reactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _sampleReactions.map((e) => ActionChip(
                  avatar: Text(e, style: const TextStyle(fontSize: 20)),
                  label: Text(e == '❤️' ? 'Love' : e == '😂' ? 'Haha' : e == '👍' ? 'Like' : e == '😮' ? 'Wow' : e == '😢' ? 'Sad' : 'Pray'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Helpers.showSnackBar(context, 'Reaction disabled for this group');
                  },
                )).toList(),
              ),
              const SizedBox(height: 12),
              Text('Custom reactions coming soon', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  void _showEncryptionInfo(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A3E) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [Icon(Icons.lock, color: Colors.green, size: 22), const SizedBox(width: 8), const Text('Encryption')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Messages in this group are secured with end-to-end encryption.', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 12),
            Text('Only participants can read or listen to them.', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it'))],
      ),
    );
  }

  void _muteGroup(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final accent = context.read<ThemeProvider>().accentColor;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Mute Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.access_time, size: 20)),
                title: const Text('8 hours'),
                trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                onTap: () { Navigator.pop(ctx); Helpers.showSnackBar(context, 'Group muted for 8 hours'); },
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.access_time, size: 20)),
                title: const Text('1 week'),
                trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                onTap: () { Navigator.pop(ctx); Helpers.showSnackBar(context, 'Group muted for 1 week'); },
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.volume_off, size: 20)),
                title: const Text('Always'),
                trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                onTap: () { Navigator.pop(ctx); Helpers.showSnackBar(context, 'Group muted permanently'); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareGroupLink(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final groupLink = 'https://chatwave.app/join/${widget.chat.chatId}';
    Clipboard.setData(ClipboardData(text: groupLink));
    Helpers.showSnackBar(context, 'Group link copied to clipboard');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A3E) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Share Group Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Anyone with this link can join the group:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: isDark ? const Color(0xFF1A1A2E) : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: SelectableText(groupLink, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13)),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done'))],
      ),
    );
  }

  void _copyGroupId(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.chat.chatId));
    Helpers.showSnackBar(context, 'Group ID copied: ${widget.chat.chatId}');
  }

  void _exitGroup(BuildContext context, AuthProvider auth, SocketService socket) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit Group'),
        content: const Text('Are you sure you want to exit this group? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              socket.exitGroup(widget.chat.chatId, auth.userId);
              Navigator.of(context).popUntil((route) => route.isFirst);
              Helpers.showSnackBar(context, 'You left the group');
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
