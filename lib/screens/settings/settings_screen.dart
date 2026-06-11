import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/colors.dart';
import '../../config/app_config.dart';
import '../profile/profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _backupEnabled = false;
  bool _mediaAutoDownload = true;
  bool _readReceipts = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final user = auth.userModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildProfileHeader(user?.displayName ?? 'User', user?.phoneNumber ?? '', user?.photoURL),
          const SizedBox(height: 8),
          _buildSectionTitle('Account'),
          _buildSettingsTile(Icons.key, 'Account', 'Privacy, security, change number', () {}),
          _buildSettingsTile(Icons.lock_outline, 'Privacy', 'Last seen, profile photo, about', () => _showPrivacySettings()),
          _buildSettingsTile(Icons.security, 'Security', 'Two-step verification, encryption', () {}),
          _buildDivider(),
          _buildSectionTitle('Notifications'),
          _buildSettingsTile(Icons.notifications_outlined, 'Message notifications', 'Sound, popup, vibration', () {}),
          _buildSettingsTile(Icons.group_outlined, 'Group notifications', 'Sound, popup, vibration', () {}),
          _buildSettingsTile(Icons.phone_in_talk, 'Call notifications', 'Sound, vibration', () {}),
          _buildDivider(),
          _buildSectionTitle('Chats'),
          _buildSettingsTile(Icons.wallpaper, 'Wallpaper', 'Change chat background', () {}),
          _buildSettingsTile(Icons.text_fields, 'Font size', 'Small, medium, large', () {}),
          _buildSwitchTile(Icons.cloud_download_outlined, 'Media auto-download', _mediaAutoDownload, (v) {
            setState(() => _mediaAutoDownload = v);
          }),
          _buildSwitchTile(Icons.done_all, 'Read receipts', _readReceipts, (v) {
            setState(() => _readReceipts = v);
          }),
          _buildSettingsTile(Icons.backup_outlined, 'Chat backup', 'Back up to Google Drive', () => _showBackupDialog()),
          _buildSettingsTile(Icons.history, 'Chat history', 'Export chat, clear all chats', () {}),
          _buildDivider(),
          _buildSectionTitle('Storage & Data'),
          _buildSettingsTile(Icons.storage_outlined, 'Storage usage', 'Manage storage', () {}),
          _buildSettingsTile(Icons.wifi, 'Network usage', 'Data usage statistics', () {}),
          _buildDivider(),
          _buildSectionTitle('Help'),
          _buildSettingsTile(Icons.help_outline, 'Help center', 'FAQ, contact us', () {}),
          _buildSettingsTile(Icons.description_outlined, 'Terms of service', '', () {}),
          _buildSettingsTile(Icons.privacy_tip_outlined, 'Privacy policy', '', () {}),
          _buildDivider(),
          _buildSectionTitle('App Info'),
          _buildSettingsTile(Icons.info_outline, 'App version', 'v${AppConfig.appVersion}', () {}),
          _buildSwitchTile(Icons.dark_mode, 'Dark mode', theme.isDarkMode, (v) {
            theme.toggleTheme();
          }),
          _buildDivider(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Logout', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String name, String phone, String? photoURL) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 28, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(phone, style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(title),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textHint),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(title),
        trailing: Switch(value: value, onChanged: onChanged, activeColor: AppColors.accent),
      ),
    );
  }

  Widget _buildDivider() {
    return const SizedBox(height: 0);
  }

  void _showPrivacySettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Privacy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _privacyOption('Last seen & online', 'Everyone'),
              _privacyOption('Profile photo', 'Everyone'),
              _privacyOption('About', 'Everyone'),
              _privacyOption('Status', 'My contacts'),
              _privacyOption('Read receipts', 'On'),
              _privacyOption('Groups', 'Everyone'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _privacyOption(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: TextStyle(color: AppColors.accent)),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chat Backup'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Back up to Google Drive'),
                value: _backupEnabled,
                activeColor: AppColors.accent,
                onChanged: (v) => setDialogState(() => _backupEnabled = v),
              ),
              const ListTile(
                title: Text('Last backup: Never'),
                leading: Icon(Icons.info_outline),
              ),
              const ListTile(
                title: Text('Backup frequency'),
                subtitle: Text('Daily'),
                trailing: Icon(Icons.chevron_right),
              ),
              const ListTile(
                title: Text('Include videos'),
                trailing: Switch(value: false, onChanged: null),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save')),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
