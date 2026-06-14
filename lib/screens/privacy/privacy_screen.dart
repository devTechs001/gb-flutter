import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/privacy_provider.dart';
import '../../providers/theme_provider.dart';
import 'secret_chats_screen.dart';
import '../lock/lock_screen.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrivacyProvider>().getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final privacy = context.watch<PrivacyProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;
    final bgColor = isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? const Color(0xFF1E1E32) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Control'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      ),
      backgroundColor: bgColor,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionHeader('Online Status', accent, isDark),
          _buildSwitchTile(icon: Icons.visibility_off, title: 'Hide Online Status', subtitle: privacy.hideOnlineStatus ? 'Hidden' : 'Visible', value: privacy.hideOnlineStatus, onChanged: (_) => privacy.toggleHideOnline(), cardColor: cardColor, accent: accent, isDark: isDark),
          _buildSwitchTile(icon: Icons.access_time, title: 'Freeze Last Seen', subtitle: privacy.freezeLastSeen ? (privacy.lastSeenFrozen ?? 'Tap to set') : 'Off', value: privacy.freezeLastSeen, onChanged: (_) {
            privacy.toggleFreezeLastSeen();
            if (privacy.freezeLastSeen) _showLastSeenPicker(context, privacy);
          }, cardColor: cardColor, accent: accent, isDark: isDark, onTap: privacy.freezeLastSeen ? () => _showLastSeenPicker(context, privacy) : null),
          _buildSwitchTile(icon: Icons.keyboard, title: 'Hide Typing', subtitle: privacy.hideTypingIndicator ? 'Hidden' : 'Visible', value: privacy.hideTypingIndicator, onChanged: (_) => privacy.toggleTypingIndicator(), cardColor: cardColor, accent: accent, isDark: isDark),
          _buildSwitchTile(icon: Icons.mic, title: 'Hide Recording', subtitle: privacy.hideRecordingIndicator ? 'Hidden' : 'Visible', value: privacy.hideRecordingIndicator, onChanged: (_) => privacy.toggleRecordingIndicator(), cardColor: cardColor, accent: accent, isDark: isDark),
          const SizedBox(height: 8),
          _buildSectionHeader('Notifications', accent, isDark),
          _buildSwitchTile(icon: Icons.notifications_off_rounded, title: 'Do Not Disturb', subtitle: privacy.dndEnabled ? 'On' : 'Off', value: privacy.dndEnabled, onChanged: (_) => privacy.toggleDnd(), cardColor: cardColor, accent: accent, isDark: isDark),
          _buildSwitchTile(icon: Icons.visibility_off_rounded, title: 'Hide Notification Content', subtitle: privacy.notificationHideContent ? 'Hidden' : 'Shown', value: privacy.notificationHideContent, onChanged: (_) => privacy.toggleNotificationHideContent(), cardColor: cardColor, accent: accent, isDark: isDark),
          _buildSwitchTile(icon: Icons.notifications_active_rounded, title: 'Online Notifier', subtitle: privacy.onlineNotifier ? 'On' : 'Off', value: privacy.onlineNotifier, onChanged: (_) => privacy.toggleOnlineNotifier(), cardColor: cardColor, accent: accent, isDark: isDark),
          const SizedBox(height: 8),
          _buildSectionHeader('Chat Modes', accent, isDark),
          _buildSwitchTile(icon: Icons.visibility_off, title: 'Ghost Mode', subtitle: privacy.ghostMode ? 'Invisible to others' : 'Visible', value: privacy.ghostMode, onChanged: (_) => privacy.toggleGhostMode(), cardColor: cardColor, accent: accent, isDark: isDark),
          _buildSwitchTile(icon: Icons.airplanemode_active_rounded, title: 'Airplane Chat Mode', subtitle: privacy.airplaneChatMode ? 'On' : 'Off', value: privacy.airplaneChatMode, onChanged: (_) => privacy.toggleAirplaneChat(), cardColor: cardColor, accent: accent, isDark: isDark),
          _buildSwitchTile(icon: Icons.lock_outline_rounded, title: 'Chat Lock', subtitle: privacy.chatLockEnabled ? 'Locked' : 'Off', value: privacy.chatLockEnabled, onChanged: (_) {
            if (!privacy.chatLockEnabled) {
              _showSetPinDialog(context, privacy);
            } else {
              privacy.toggleAppLock();
            }
          }, cardColor: cardColor, accent: accent, isDark: isDark, onTap: privacy.chatLockEnabled ? () => _showSetPinDialog(context, privacy) : null),
          const SizedBox(height: 8),
          _buildSectionHeader('Message Status', accent, isDark),
          _buildSwitchTile(icon: Icons.done_all, title: 'Show Message Status', subtitle: privacy.showMessageStatus ? 'Seen/Read/Blue ticks' : 'Hidden', value: privacy.showMessageStatus, onChanged: (_) => privacy.toggleMessageStatus(), cardColor: cardColor, accent: accent, isDark: isDark),
          _buildSwitchTile(icon: Icons.access_time_rounded, title: 'Show Online Timestamp', subtitle: privacy.showOnlineTimestamp ? 'h:mm:ss format' : 'Off', value: privacy.showOnlineTimestamp, onChanged: (_) => privacy.toggleOnlineTimestamp(), cardColor: cardColor, accent: accent, isDark: isDark),
          const SizedBox(height: 8),
          _buildSectionHeader('Read Receipts', accent, isDark),
          _buildSwitchTile(icon: Icons.done_all, title: 'Hide Blue Ticks', subtitle: privacy.hideBlueTicks ? 'Hidden' : 'Visible', value: privacy.hideBlueTicks, onChanged: (_) => privacy.toggleBlueTicks(), cardColor: cardColor, accent: accent, isDark: isDark),
          _buildSwitchTile(icon: Icons.done, title: 'Hide Second Tick', subtitle: privacy.hideSecondTick ? 'Hidden' : 'Visible', value: privacy.hideSecondTick, onChanged: (_) => privacy.toggleSecondTick(), cardColor: cardColor, accent: accent, isDark: isDark),
          const SizedBox(height: 8),
          _buildSectionHeader('Anti-Revoke', accent, isDark),
          _buildSwitchTile(icon: Icons.delete_outline, title: 'Anti-Delete Messages', subtitle: privacy.antiDeleteMessages ? 'On' : 'Off', value: privacy.antiDeleteMessages, onChanged: (_) => privacy.toggleAntiDeleteMessages(), cardColor: cardColor, accent: accent, isDark: isDark),
          _buildSwitchTile(icon: Icons.delete_sweep_outlined, title: 'Anti-Delete Status', subtitle: privacy.antiDeleteStatus ? 'On' : 'Off', value: privacy.antiDeleteStatus, onChanged: (_) => privacy.toggleAntiDeleteStatus(), cardColor: cardColor, accent: accent, isDark: isDark),
          const SizedBox(height: 8),
          _buildSectionHeader('Security', accent, isDark),
          _buildSwitchTile(icon: Icons.lock_outline, title: 'App Lock', subtitle: privacy.appLockEnabled ? 'Enabled' : 'Disabled', value: privacy.appLockEnabled, onChanged: (_) {
            if (!privacy.appLockEnabled) {
              _showSetPinDialog(context, privacy);
            } else {
              privacy.toggleAppLock();
            }
          }, cardColor: cardColor, accent: accent, isDark: isDark, onTap: privacy.appLockEnabled ? () => _showSetPinDialog(context, privacy) : null),
          _buildSwitchTile(icon: Icons.fingerprint, title: 'Fingerprint Unlock', subtitle: privacy.fingerprintEnabled ? 'Enabled' : 'Disabled', value: privacy.fingerprintEnabled, onChanged: (_) => privacy.toggleFingerprint(), cardColor: cardColor, accent: accent, isDark: isDark),
          const SizedBox(height: 8),
          _buildSectionHeader('Lockout Settings', accent, isDark),
          _buildSwitchTile(icon: Icons.timer_outlined, title: 'Auto Lock Timer', subtitle: 'After ${privacy.lockoutTimeMinutes} min', value: privacy.appLockEnabled, onChanged: (_) {}, cardColor: cardColor, accent: accent, isDark: isDark, onTap: () => _showLockoutPicker(context, privacy)),
          const SizedBox(height: 8),
          _buildSectionHeader('Secret Chats', accent, isDark),
          _buildNavTile(Icons.lock_outline, 'Hidden Chats', '${privacy.hiddenChats.length} chat(s)', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecretChatsScreen(initialTab: 0))), cardColor, accent, isDark),
          _buildNavTile(Icons.archive_outlined, 'Archived Chats', '${privacy.archivedChats.length} chat(s)', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecretChatsScreen(initialTab: 1))), cardColor, accent, isDark),
          const SizedBox(height: 8),
          _buildSectionHeader('Profile Visibility', accent, isDark),
          _buildDropdownTile(icon: Icons.photo_camera_outlined, title: 'Profile Photo', value: privacy.profilePhotoVisibility, items: const ['everyone', 'my_contacts', 'nobody'], labels: {'everyone': 'Everyone', 'my_contacts': 'My Contacts', 'nobody': 'Nobody'}, onChanged: (v) => privacy.profilePhotoVisibility = v!, cardColor: cardColor, accent: accent, isDark: isDark),
          _buildDropdownTile(icon: Icons.info_outline, title: 'About', value: privacy.aboutVisibility, items: const ['everyone', 'my_contacts', 'nobody'], labels: {'everyone': 'Everyone', 'my_contacts': 'My Contacts', 'nobody': 'Nobody'}, onChanged: (v) => privacy.aboutVisibility = v!, cardColor: cardColor, accent: accent, isDark: isDark),
          _buildDropdownTile(icon: Icons.emoji_emotions_outlined, title: 'Status', value: privacy.statusVisibility, items: const ['everyone', 'my_contacts', 'nobody'], labels: {'everyone': 'Everyone', 'my_contacts': 'My Contacts', 'nobody': 'Nobody'}, onChanged: (v) => privacy.statusVisibility = v!, cardColor: cardColor, accent: accent, isDark: isDark),
          _buildDropdownTile(icon: Icons.access_time, title: 'Last Seen', value: privacy.lastSeenVisibility, items: const ['everyone', 'my_contacts', 'nobody'], labels: {'everyone': 'Everyone', 'my_contacts': 'My Contacts', 'nobody': 'Nobody'}, onChanged: (v) => privacy.lastSeenVisibility = v!, cardColor: cardColor, accent: accent, isDark: isDark),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color accent, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: accent, letterSpacing: 0.5)),
    );
  }

  Widget _buildSwitchTile({required IconData icon, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged, VoidCallback? onTap, required Color cardColor, required Color accent, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: accent, size: 20)),
        title: Text(title, style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey[500])),
        trailing: Switch(value: value, onChanged: onChanged, activeColor: accent),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNavTile(IconData icon, String title, String subtitle, VoidCallback onTap, Color cardColor, Color accent, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: accent, size: 20)),
        title: Text(title, style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey[500])),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDropdownTile({required IconData icon, required String title, required String value, required List<String> items, required Map<String, String> labels, required ValueChanged<String?> onChanged, required Color cardColor, required Color accent, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: accent, size: 20)),
        title: Text(title, style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
        trailing: DropdownButton<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(labels[item] ?? item, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
          underline: const SizedBox(),
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: isDark ? const Color(0xFF2C2C3E) : Colors.white,
        ),
      ),
    );
  }

  void _showLastSeenPicker(BuildContext context, PrivacyProvider privacy) {
    final now = DateTime.now();
    showDatePicker(context: context, initialDate: privacy.lastSeenFrozen != null ? DateTime.tryParse(privacy.lastSeenFrozen!) ?? now : now, firstDate: DateTime(2020), lastDate: now).then((date) {
      if (date != null) {
        showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(now)).then((time) {
          if (time != null) {
            final frozen = DateTime(date.year, date.month, date.day, time.hour, time.minute).toIso8601String();
            privacy.lastSeenFrozen = frozen;
          }
        });
      }
    });
  }

  void _showLockoutPicker(BuildContext context, PrivacyProvider privacy) {
    final controller = TextEditingController(text: privacy.lockoutTimeMinutes);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Auto Lock Timer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Lock app after being in background for:'),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Minutes',
              border: OutlineInputBorder(),
              suffixText: 'min',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () {
          if (controller.text.isNotEmpty) {
            privacy.lockoutTimeMinutes = controller.text;
            Navigator.pop(ctx);
          }
        }, child: const Text('Set')),
      ],
    ));
  }

  void _showSetPinDialog(BuildContext context, PrivacyProvider privacy) {
    final pinController = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Set App Lock PIN'),
      content: TextField(
        controller: pinController,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: const InputDecoration(hintText: 'Enter 4-6 digit PIN', counterText: ''),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () {
          if (pinController.text.length >= 4) {
            privacy.setAppLockPin(pinController.text);
            Navigator.pop(ctx);
          }
        }, child: const Text('Set')),
      ],
    ));
  }
}
