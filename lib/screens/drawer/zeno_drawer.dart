import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/privacy_provider.dart';
import '../../theme/zeno_colors.dart';
import '../../utils/helpers.dart';
import '../themes/themes_screen.dart';
import '../privacy/privacy_screen.dart';
import '../themes/schedule_screen.dart';
import '../themes/cats_media_screen.dart';
import '../settings/settings_screen.dart';
import '../chat/contact_list_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/archived_screen.dart';
import '../settings/starred_screen.dart';
import '../settings/broadcast_screen.dart';
import '../settings/security_center_screen.dart';
import '../settings/backup_screen.dart';
import '../settings/notification_screen.dart';
import '../status/status_screen.dart';
import '../settings/starred_screen.dart' as settings;

class ZenoDrawer extends StatefulWidget {
  final void Function(Widget) onNavigate;

  const ZenoDrawer({super.key, required this.onNavigate});

  @override
  State<ZenoDrawer> createState() => _ZenoDrawerState();
}

class _ZenoDrawerState extends State<ZenoDrawer> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final privacy = Provider.of<PrivacyProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final userModel = authProvider.userModel;
    final name = userModel?.displayName ?? 'User';
    final phone = userModel?.phoneNumber ?? '+0 000 000 0000';
    final photoUrl = userModel?.photoURL;
    final online = userModel?.isOnline ?? true;
    final totalUnread = chatProvider.chats.fold<int>(
      0, (sum, c) => sum + (c.unreadCount[authProvider.userId] ?? 0),
    );
    final archivedCount = chatProvider.chats.where((c) => c.archivedBy[authProvider.userId] ?? false).length;
    final starredCount = chatProvider.messages.where((m) => m.isStarred).length;

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              children: [
                _buildHeader(context, name, phone, photoUrl, online, isDark),
                _buildMenuItem(Icons.bookmark_rounded, 'Saved Messages', 'Your private cloud', () => _savedMessages(context), isDark, badge: null),
                _buildMenuItem(Icons.person_rounded, 'Profile', 'Edit name, photo, status', () => widget.onNavigate(const ProfileScreen()), isDark),
                _buildDivider(),
                _buildSectionLabel('CHATS'),
                _buildMenuItem(Icons.group_add_rounded, 'New Group', 'Create a group chat', () => widget.onNavigate(const ContactListScreen()), isDark),
                _buildMenuItem(Icons.contacts_rounded, 'Contacts', 'Manage your contacts', () => widget.onNavigate(const ContactListScreen()), isDark),
                _buildMenuItem(Icons.archive_rounded, 'Archived', archivedCount > 0 ? '$archivedCount chats' : 'View archived chats', () => widget.onNavigate(const ArchivedScreen()), isDark, badge: archivedCount > 0 ? archivedCount : null),
                _buildMenuItem(Icons.star_rounded, 'Starred Messages', starredCount > 0 ? '$starredCount messages' : 'Important messages', () => widget.onNavigate(const StarredScreen()), isDark),
                _buildMenuItem(Icons.campaign_rounded, 'Broadcast Lists', 'Send to many', () => widget.onNavigate(const BroadcastScreen()), isDark),
                _buildDivider(),
                _buildSectionLabel('MEDIA & STORIES'),
                _buildMenuItem(Icons.circle_rounded, 'My Stories', 'Share moments', () => widget.onNavigate(const StatusScreen()), isDark),
                _buildMenuItem(Icons.movie_creation_rounded, 'CATS Media', 'Advanced media tools', () => widget.onNavigate(const CATSMediaScreen()), isDark),
                _buildDivider(),
                _buildSectionLabel('FEATURES'),
                _buildMenuItem(Icons.palette_rounded, 'Themes', '${themeProvider.currentThemeName} theme', () => widget.onNavigate(const ThemesScreen()), isDark),
                _buildMenuItem(Icons.lock_rounded, 'Privacy & Lock', '${privacy.appLockEnabled ? 'PIN enabled' : 'Not secured'}', () => widget.onNavigate(const PrivacyScreen()), isDark),
                _buildMenuItem(Icons.schedule_rounded, 'Schedule Message', 'Auto-reply & scheduling', () => widget.onNavigate(const ScheduleScreen()), isDark),
                _buildMenuItem(Icons.backup_rounded, 'Chat Backup', 'Backup & restore', () => widget.onNavigate(const BackupScreen()), isDark),
                _buildMenuItem(Icons.security_rounded, 'Security Center', 'Encryption & safety', () => widget.onNavigate(const SecurityCenterScreen()), isDark),
                _buildDivider(),
                _buildSectionLabel('OTHER'),
                _buildMenuItem(Icons.share_rounded, 'Invite Friends', 'Share ChatWave with friends', () => _inviteFriends(context), isDark),
                _buildMenuItem(Icons.notifications_rounded, 'Notifications', 'Tones, vibration, popups', () => widget.onNavigate(const NotificationScreen()), isDark),
                _buildMenuItem(Icons.settings_rounded, 'Settings', 'App configuration', () => widget.onNavigate(const SettingsScreen()), isDark),
                _buildDivider(),
                _buildMenuItem(Icons.wallet_rounded, 'ChatWave Pay', 'Send & receive payments', () => _showComingSoon(context, 'ChatWave Pay'), isDark),
                _buildMenuItem(Icons.help_outline_rounded, 'Help & FAQ', 'Get assistance', () => _showComingSoon(context, 'Help Center'), isDark),
              ],
            ),
          ),
          _buildDarkModeToggle(isDark, themeProvider),
          _buildLogoutButton(context, authProvider, isDark),
        ],
      ),
    );
  }

  void _savedMessages(BuildContext context) {
    Helpers.showSnackBar(context, 'Saved Messages - your private cloud storage');
  }

  void _inviteFriends(BuildContext context) {
    Helpers.showSnackBar(context, 'Invite link copied! Share ChatWave with friends.');
  }

  void _showComingSoon(BuildContext context, String feature) {
    Helpers.showSnackBar(context, '$feature coming soon!');
  }

  Widget _buildHeader(BuildContext context, String name, String phone, String? photoUrl, bool online, bool isDark) {
    return GestureDetector(
      onTap: () => widget.onNavigate(const ProfileScreen()),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ZenoColors.primary,
              ZenoColors.primaryDark,
              const Color(0xFF2D1B69),
            ],
          ),
        ),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20, right: 20, bottom: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null
                          ? Text(
                              Helpers.getInitials(name),
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    if (online)
                      Positioned(
                        bottom: 2, right: 2,
                        child: Container(
                          width: 14, height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ZenoColors.online,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
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
                        name,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phone,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: online ? ZenoColors.online : ZenoColors.offline,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            online ? 'Online' : 'Offline',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.6)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: ZenoColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap, bool isDark, {int? badge}) {
    return ListTile(
      dense: true,
      leading: Stack(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: ZenoColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: ZenoColors.primary, size: 22),
          ),
          if (badge != null && badge > 0)
            Positioned(
              top: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge > 9 ? '9+' : '$badge',
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: isDark ? Colors.white : null)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey[500])),
      trailing: Icon(Icons.chevron_right, size: 18, color: isDark ? Colors.white24 : Colors.grey[400]),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.15)),
    );
  }

  Widget _buildDarkModeToggle(bool isDark, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (isDark ? Colors.amber : ZenoColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isDark ? Colors.amber : ZenoColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          ),
          Switch(
            value: isDark,
            onChanged: (_) => themeProvider.toggleDarkMode(),
            activeColor: ZenoColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.15))),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.logout_rounded, color: Colors.red, size: 22),
        ),
        title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 14)),
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    authProvider.signOut();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
