import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/privacy_provider.dart';
import '../../config/app_config.dart';
import '../../utils/helpers.dart';
import '../profile/profile_screen.dart';
import '../themes/themes_screen.dart';
import '../privacy/privacy_screen.dart';
import '../lock/lock_screen.dart';
import 'broadcast_screen.dart';
import 'archived_screen.dart';
import 'starred_screen.dart';
import 'security_center_screen.dart';
import 'backup_screen.dart';
import 'notification_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<_GBFeature> _gbFeatures = [
    _GBFeature(Icons.fingerprint, 'Hide Online Status', 'privacy', 'Appear offline to others'),
    _GBFeature(Icons.done_all, 'Hide Blue Ticks', 'privacy', 'Don\'t show read receipts'),
    _GBFeature(Icons.keyboard_hide, 'Hide Typing Indicator', 'privacy', 'Don\'t show when typing'),
    _GBFeature(Icons.mic_off, 'Hide Recording', 'privacy', 'Don\'t show recording status'),
    _GBFeature(Icons.ac_unit, 'Freeze Last Seen', 'privacy', 'Freeze your last seen time'),
    _GBFeature(Icons.delete_sweep, 'Anti-Delete Messages', 'privacy', 'Keep deleted messages visible'),
    _GBFeature(Icons.auto_stories, 'Anti-Delete Status', 'privacy', 'Keep deleted status visible'),
    _GBFeature(Icons.lock, 'App Lock', 'privacy', 'Secure with PIN or fingerprint'),
    _GBFeature(Icons.visibility_off, 'Hide View Status', 'privacy', 'View status without being seen'),
    _GBFeature(Icons.copy_all, 'Copy/Cut Messages', 'privacy', 'Enable copy-cut on messages'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final privacy = Provider.of<PrivacyProvider>(context);
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;
    final user = auth.userModel;
    final bgColor = isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0F2F5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildProfileCard(context, user, isDark, accent),
          const SizedBox(height: 12),
          _buildGBFeaturesGrid(context, privacy, isDark, accent),
          const SizedBox(height: 12),
          _buildSection('General', [
            _buildTile(Icons.star_rounded, 'Starred Messages', 'View starred', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StarredScreen())), accent, isDark),
            _buildTile(Icons.link_rounded, 'ChatWave Web', 'Use on desktop', () => _showComingSoon(context, 'ChatWave Web'), accent, isDark),
            _buildTile(Icons.language_rounded, 'Language', 'English', () => _showLanguagePicker(context, accent, isDark), accent, isDark),
          ], isDark, accent),
          _buildSection('Privacy & Security', [
            _buildTile(Icons.lock_rounded, 'Privacy Settings', 'Controls, lock, security', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen())), accent, isDark),
            _buildTile(Icons.security_rounded, 'Security Center', 'Encryption, safety', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityCenterScreen())), accent, isDark),
            _buildTile(Icons.fingerprint, 'App Lock', privacy.appLockEnabled ? 'PIN enabled' : 'Not secured', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LockScreen())), accent, isDark),
          ], isDark, accent),
          _buildSection('Appearance', [
            _buildTile(Icons.palette_rounded, 'Themes', '${theme.currentThemeName} theme', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemesScreen())), accent, isDark),
            _buildSwitchTile(Icons.dark_mode_rounded, 'Dark Mode', theme.isDarkMode, (v) => theme.toggleDarkMode(), accent, isDark),
            _buildSwitchTile(Icons.brightness_low_rounded, 'AMOLED Mode', theme.isAmoledMode, (v) => theme.toggleAmoled(), accent, isDark),
            _buildSliderTile(Icons.text_fields_rounded, 'Font Size', theme.fontSize, 12, 24, (v) => theme.setFontSize(v), accent, isDark),
          ], isDark, accent),
          _buildSection('Chats', [
            _buildTile(Icons.archive_rounded, 'Archived Chats', 'View archived', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArchivedScreen())), accent, isDark),
            _buildTile(Icons.campaign_rounded, 'Broadcast Lists', 'Send to many', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BroadcastScreen())), accent, isDark),
            _buildTile(Icons.backup_rounded, 'Chat Backup', 'Backup & restore', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen())), accent, isDark),
            _buildTile(Icons.done_all_rounded, 'Message Ticks', privacy.hideBlueTicks && privacy.hideSecondTick ? 'Single tick only' : privacy.hideBlueTicks ? 'Double tick (no blue)' : 'Blue ticks on', () => _showTickSettings(context, privacy, accent, isDark), accent, isDark),
            _buildSwitchTile(Icons.storage_rounded, 'Auto-Download Media', true, (v) {}, accent, isDark),
            _buildTile(Icons.delete_sweep_rounded, 'Clear All Chats', 'Delete conversation history', () => _confirmClearChats(context, accent), accent, isDark, color: Colors.red),
          ], isDark, accent),
          _buildSection('Notifications', [
            _buildTile(Icons.notifications_rounded, 'Notifications', 'Tones, vibration, preview', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())), accent, isDark),
            _buildSwitchTile(Icons.vibration_rounded, 'Vibrate', true, (v) {}, accent, isDark),
            _buildSwitchTile(Icons.music_note_rounded, 'Message sounds', true, (v) {}, accent, isDark),
          ], isDark, accent),
          _buildSection('Calls', [
            _buildTile(Icons.block_rounded, 'Blocked Contacts', 'Manage blocked', () => _showComingSoon(context, 'Blocked Contacts'), accent, isDark),
          ], isDark, accent),
          _buildSection('Data & Storage', [
            _buildTile(Icons.storage_rounded, 'Storage Usage', 'Manage media storage', () => _showComingSoon(context, 'Storage Usage'), accent, isDark),
            _buildTile(Icons.wifi_rounded, 'Network Usage', 'Data saver settings', () => _showComingSoon(context, 'Network Usage'), accent, isDark),
            _buildSwitchTile(Icons.photo_size_select_large_rounded, 'Auto-download Images', true, (v) => _showToast(context, 'Images will auto-download'), accent, isDark),
            _buildSwitchTile(Icons.videocam_rounded, 'Auto-download Videos', false, (v) => _showToast(context, v ? 'Videos will auto-download' : 'Videos won\'t auto-download'), accent, isDark),
          ], isDark, accent),
          _buildSection('About', [
            _buildTile(Icons.info_outline_rounded, 'App Version', 'v${AppConfig.appVersion}', () => _showToast(context, 'ChatWave v${AppConfig.appVersion}'), accent, isDark),
            _buildTile(Icons.code_rounded, 'Open Source Licenses', 'Third-party notices', () => _showToast(context, 'Open source licenses'), accent, isDark),
            _buildTile(Icons.feedback_rounded, 'Send Feedback', 'Help us improve', () => _showToast(context, 'Feedback submitted'), accent, isDark),
            _buildTile(Icons.star_border_rounded, 'Rate ChatWave', 'Rate on Play Store', () => _showToast(context, 'Thanks for rating!'), accent, isDark),
          ], isDark, accent),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic user, bool isDark, Color accent) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E32) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: accent.withValues(alpha: 0.15),
                    child: Text(
                      Helpers.getInitials(user?.displayName ?? 'A'),
                      style: TextStyle(color: accent, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4CAF50),
                        border: Border.all(color: isDark ? const Color(0xFF1E1E32) : Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.check, size: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Alex Dev',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.status ?? 'Building ChatWave 🚀',
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey[500]),
                    ),
                    const SizedBox(height: 2),
                    Text('Tap to edit profile', style: TextStyle(fontSize: 11, color: accent)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.qr_code_rounded, color: accent, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGBFeaturesGrid(BuildContext context, PrivacyProvider privacy, bool isDark, Color accent) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E32) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.auto_awesome, color: accent, size: 16),
                ),
                const SizedBox(width: 8),
                const Text('GB Features', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Enhanced privacy & customization', style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey[500])),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _gbFeatures.map((f) => _buildGBFeatureChip(f, privacy, isDark, accent)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGBFeatureChip(_GBFeature feature, PrivacyProvider privacy, bool isDark, Color accent) {
    bool isEnabled = false;
    switch (feature.key) {
      case 'privacy':
        isEnabled = privacy.hideOnlineStatus || privacy.hideBlueTicks || privacy.appLockEnabled;
        break;
    }

    return Material(
      color: isDark ? const Color(0xFF2A2A42) : const Color(0xFFF5F5FF),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen())),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(feature.icon, size: 18, color: isEnabled ? const Color(0xFF4CAF50) : accent),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  feature.title,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: accent, letterSpacing: 0.8),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
          color: isDark ? const Color(0xFF1E1E32) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile(IconData icon, String title, String subtitle, VoidCallback onTap, Color accent, bool isDark, {Color? color}) {
    final tileColor = color ?? accent;
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: tileColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: tileColor, size: 22),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey[500])),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged, Color accent, bool isDark) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: accent, size: 22),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: accent),
    );
  }

  Widget _buildSliderTile(IconData icon, String title, double value, double min, double max, ValueChanged<double> onChanged, Color accent, bool isDark) {
    return StatefulBuilder(
      builder: (ctx, setInnerState) => ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accent, size: 22),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
        subtitle: Slider(
          value: value,
          min: min,
          max: max,
          divisions: 12,
          label: '${value.round()}px',
          onChanged: (v) {
            setInnerState(() => value = v);
            onChanged(v);
          },
          activeColor: accent,
        ),
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 1)));
  }

  void _showComingSoon(BuildContext context, String feature) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A3E) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(feature, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Text('$feature coming soon!', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, Color accent, bool isDark) {
    final langs = ['English', 'Spanish', 'French', 'German', 'Italian', 'Portuguese', 'Hindi', 'Japanese', 'Chinese', 'Arabic'];
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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              Text('App Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              ...langs.map((l) => ListTile(title: Text(l, style: TextStyle(color: isDark ? Colors.white : Colors.black87)), trailing: l == 'English' ? Icon(Icons.check, color: accent) : null, onTap: () => Navigator.pop(ctx))),
            ],
          ),
        ),
      ),
    );
  }

  void _showTickSettings(BuildContext context, PrivacyProvider privacy, Color accent, bool isDark) {
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
              Text('Message Tick Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text('Show Blue Ticks', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                subtitle: Text(privacy.hideBlueTicks ? 'Read receipts hidden' : 'Blue ticks visible', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12)),
                value: !privacy.hideBlueTicks,
                activeColor: accent,
                onChanged: (v) => privacy.toggleBlueTicks(),
              ),
              SwitchListTile(
                title: Text('Show Second Tick', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                subtitle: Text(privacy.hideSecondTick ? 'Delivered status hidden' : 'Double tick visible', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12)),
                value: !privacy.hideSecondTick,
                activeColor: accent,
                onChanged: (v) => privacy.toggleSecondTick(),
              ),
              SwitchListTile(
                title: Text('Show Message Status', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                subtitle: Text(privacy.showMessageStatus ? 'Sent/Delivered/Read shown' : 'Status hidden', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12)),
                value: privacy.showMessageStatus,
                activeColor: accent,
                onChanged: (v) => privacy.toggleMessageStatus(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClearChats(BuildContext context, Color accent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E32) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Chats'),
        content: const Text('This will delete all conversation histories. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _GBFeature {
  final IconData icon;
  final String title;
  final String key;
  final String description;

  _GBFeature(this.icon, this.title, this.key, this.description);
}
