import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';
import '../../models/chat_model.dart';
import '../../theme/colors.dart';

class ChatSettingsScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatSettingsScreen({super.key, required this.chat});

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  String _wallpaperKey = 'default';

  @override
  void initState() {
    super.initState();
    _loadWallpaper();
  }

  Future<void> _loadWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _wallpaperKey = prefs.getString('chat_wallpaper_${widget.chat.chatId}') ?? 'default';
    });
  }

  Future<void> _setWallpaper(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_wallpaper_${widget.chat.chatId}', key);
    setState(() => _wallpaperKey = key);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(key == 'default' ? 'Wallpaper reset' : 'Wallpaper changed'), duration: const Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Chat Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSection('Notifications', [
            _buildSwitchTile(Icons.notifications_rounded, 'Notifications', true, (v) {}, accent, isDark),
            _buildSwitchTile(Icons.vibration_rounded, 'Vibrate', true, (v) {}, accent, isDark),
            _buildTile(Icons.ring_volume_rounded, 'Ringtone', 'Default', () {}, accent, isDark),
            _buildTile(Icons.music_note_rounded, 'Message Tone', 'Default', () {}, accent, isDark),
          ], isDark),
          _buildSection('Media & Files', [
            _buildTile(Icons.photo_library_rounded, 'Media Visibility', 'Show in gallery', () {}, accent, isDark),
            _buildSwitchTile(Icons.download_rounded, 'Auto-Download Media', true, (v) {}, accent, isDark),
            _buildSwitchTile(Icons.save_alt_rounded, 'Save to Gallery', false, (v) {}, accent, isDark),
          ], isDark),
          _buildSection('Privacy', [
            _buildSwitchTile(Icons.visibility_off_rounded, 'Disappearing Messages', false, (v) {}, accent, isDark),
            _buildSwitchTile(Icons.lock_outline_rounded, 'Encryption', true, (v) {}, accent, isDark),
            _buildTile(Icons.block_rounded, 'Block Contact', 'Block this contact', () {}, accent, isDark, color: Colors.red),
          ], isDark),
          _buildSection('Wallpaper', [
            _buildWallpaperTile('default', 'Default', null, const Color(0xFFE8E8E8), accent, isDark),
            _buildWallpaperTile('dark', 'Solid Dark', const Color(0xFF0D0D1A), const Color(0xFF0D0D1A), accent, isDark),
            _buildWallpaperTile('ocean', 'Ocean Blue', const Color(0xFF0A1628), const Color(0xFF0D2137), accent, isDark),
            _buildWallpaperTile('forest', 'Forest Green', const Color(0xFF0A1A0A), const Color(0xFF0F2A0F), accent, isDark),
            _buildWallpaperTile('warm', 'Warm Sunset', const Color(0xFF1A0A0A), const Color(0xFF2A100A), accent, isDark),
            _buildWallpaperTile('purple', 'Deep Purple', const Color(0xFF1A0A28), const Color(0xFF2A0F3A), accent, isDark),
            _buildWallpaperTile('gradient1', 'Blue-Purple', const LinearGradient(colors: [Color(0xFF0A1628), Color(0xFF1A0A28)]), null, accent, isDark),
            _buildWallpaperTile('gradient2', 'Sunset', const LinearGradient(colors: [Color(0xFF1A0A0A), Color(0xFF2A1A0A)]), null, accent, isDark),
            _buildWallpaperTile('gradient3', 'Teal-Green', const LinearGradient(colors: [Color(0xFF0A1A0A), Color(0xFF0A1A1A)]), null, accent, isDark),
            _buildWallpaperTile('pattern1', 'Dots Pattern', null, null, accent, isDark, isPattern: true),
            _buildWallpaperTile('pattern2', 'Lines Pattern', null, null, accent, isDark, isPattern: true),
            _buildWallpaperTile('pattern3', 'Stars Pattern', null, null, accent, isDark, isPattern: true),
          ], isDark),
          _buildSection('Actions', [
            _buildTile(Icons.star_rounded, 'Star All Messages', 'Mark all as important', () {}, accent, isDark),
            _buildTile(Icons.archive_rounded, 'Archive Chat', 'Move to archive', () {}, accent, isDark),
            _buildTile(Icons.report_rounded, 'Report', 'Report this chat', () {}, accent, isDark, color: Colors.red),
            _buildTile(Icons.exit_to_app_rounded, 'Leave Group', widget.chat.isGroup ? 'Remove yourself' : null, () {}, accent, isDark, color: Colors.red),
          ], isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : Colors.black54,
              letterSpacing: 0.8,
            ),
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

  Widget _buildTile(IconData icon, String title, String? subtitle, VoidCallback onTap, Color accent, bool isDark, {Color? color}) {
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
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey[500])) : null,
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildWallpaperTile(String key, String label, dynamic bg, Color? fallback, Color accent, bool isDark, {bool isPattern = false}) {
    final selected = _wallpaperKey == key;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => _setWallpaper(key),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: bg is Color ? bg : (isPattern ? null : fallback ?? (isDark ? const Color(0xFF2A2A3E) : Colors.grey[200])),
                  gradient: bg is Gradient ? bg : null,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? accent : (isDark ? Colors.white12 : Colors.grey[300]!),
                    width: selected ? 2.5 : 1,
                  ),
                ),
                child: selected
                    ? Icon(Icons.check, color: Colors.white, size: 22)
                    : Icon(isPattern ? Icons.grid_view_rounded : Icons.wallpaper, color: Colors.white70, size: 20),
              ),
              const SizedBox(width: 14),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: isDark ? Colors.white : Colors.black87)),
              const Spacer(),
              if (selected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(10)),
                  child: Text('Active', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),
      ),
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: accent,
      ),
    );
  }
}
