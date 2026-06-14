import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/privacy_provider.dart';
import '../../providers/theme_provider.dart';
import 'group_info_screen.dart';

class ChatAdvancedFeaturesScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatAdvancedFeaturesScreen({super.key, required this.chat});

  @override
  State<ChatAdvancedFeaturesScreen> createState() => _ChatAdvancedFeaturesScreenState();
}

class _ChatAdvancedFeaturesScreenState extends State<ChatAdvancedFeaturesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final privacy = context.watch<PrivacyProvider>();
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;
    final bg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF0F2F5);
    final cardColor = isDark ? const Color(0xFF2A2A3E) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(widget.chat.displayName),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: accent),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => GroupInfoScreen(chat: widget.chat),
            )),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Privacy', [
            _buildToggle(privacy.dndEnabled, 'Do Not Disturb', 'Mute all notifications for this chat', (v) => privacy.toggleDnd(), accent, isDark, cardColor),
            _buildToggle(privacy.ghostMode, 'Ghost Mode', 'Appear offline in this chat', (v) => privacy.toggleGhostMode(), accent, isDark, cardColor),
            _buildToggle(privacy.airplaneChatMode, 'Airplane Chat Mode', 'Block incoming & outgoing', (v) => privacy.toggleAirplaneChat(), accent, isDark, cardColor),
            _buildToggle(privacy.onlineNotifier, 'Online Notifier', 'Notify when user comes online', (v) => privacy.toggleOnlineNotifier(), accent, isDark, cardColor),
            _buildToggle(privacy.chatLockEnabled, 'Chat Lock', 'PIN-protect this chat', (v) {
              if (!privacy.chatLockEnabled) {
                _showSetPin();
              } else {
                privacy.toggleAppLock();
              }
            }, accent, isDark, cardColor),
            _buildToggle(privacy.notificationHideContent, 'Hide Notification Content', 'Don\'t show message preview', (v) => privacy.toggleNotificationHideContent(), accent, isDark, cardColor),
            _buildToggle(privacy.showMessageStatus, 'Show Message Status', 'Display read/delivered ticks', (v) => privacy.toggleMessageStatus(), accent, isDark, cardColor),
            _buildToggle(privacy.showOnlineTimestamp, 'Show Online Timestamp', 'Show h:mm:ss online time', (v) => privacy.toggleOnlineTimestamp(), accent, isDark, cardColor),
          ], isDark, accent),

          _buildSection('Chat', [
            _buildLink(Icons.archive_rounded, 'Archive Chat', 'Move to archived', () {}, accent, isDark, cardColor),
            _buildLink(Icons.push_pin_rounded, 'Pin Chat', 'Pin to top', () {}, accent, isDark, cardColor),
            _buildLink(Icons.star_rounded, 'Starred Messages', 'View starred in this chat', () {}, accent, isDark, cardColor),
            _buildLink(Icons.photo_library_rounded, 'Shared Media', 'Photos, videos, links', () {}, accent, isDark, cardColor),
            _buildLink(Icons.schedule_rounded, 'Scheduled Messages', 'View scheduled', () {}, accent, isDark, cardColor),
            _buildLink(Icons.backup_rounded, 'Export Chat', 'Save chat history', () {}, accent, isDark, cardColor),
          ], isDark, accent),

          _buildSection('Security', [
            _buildLink(Icons.lock_rounded, 'Encryption', 'End-to-end encrypted', () {}, accent, isDark, cardColor),
            _buildLink(Icons.delete_sweep_rounded, 'Disappearing Messages', 'Auto-delete after a time', () => _showDisappearingPicker(), accent, isDark, cardColor),
          ], isDark, accent),

          const SizedBox(height: 24),
          _buildDangerButton('Clear Chat', Icons.delete_outline, Colors.red, accent, isDark),
          const SizedBox(height: 8),
          _buildDangerButton('Block User', Icons.block, Colors.red, accent, isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: accent)),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggle(bool value, String title, String subtitle, ValueChanged<bool> onChanged, Color accent, bool isDark, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey)),
        value: value,
        activeColor: accent,
        dense: true,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLink(IconData icon, String title, String subtitle, VoidCallback onTap, Color accent, bool isDark, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: accent, size: 22),
        title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey)),
        trailing: Icon(Icons.chevron_right, size: 18, color: isDark ? Colors.white24 : Colors.grey),
        dense: true,
        onTap: onTap,
      ),
    );
  }

  Widget _buildDangerButton(String title, IconData icon, Color color, Color accent, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: color),
        label: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      ),
    );
  }

  void _showSetPin() {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A3E) : null,
        title: Text('Set Chat Lock PIN', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: InputDecoration(
            hintText: 'Enter 4-digit PIN',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () {
            if (controller.text.length == 4) {
              context.read<PrivacyProvider>().setAppLockPin(controller.text);
              context.read<PrivacyProvider>().toggleAppLock();
              Navigator.pop(ctx);
            }
          }, child: const Text('Set PIN')),
        ],
      ),
    );
  }

  void _showDisappearingPicker() {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final options = ['Off', '24 hours', '7 days', '90 days'];
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text('Disappearing Messages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 12),
              ...options.map((o) => ListTile(title: Text(o, style: TextStyle(color: isDark ? Colors.white : Colors.black87)), onTap: () => Navigator.pop(ctx))),
            ],
          ),
        ),
      ),
    );
  }
}
