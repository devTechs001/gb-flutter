import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';
import '../../theme/colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _messageNotifications = true;
  bool _groupNotifications = true;
  bool _callNotifications = true;
  bool _vibrate = true;
  bool _soundEnabled = true;
  bool _messagePreview = true;
  bool _showSenderOnly = false;
  bool _hideNotificationContent = false;
  bool _showNoPreview = false;
  bool _ledIndicator = false;
  bool _popupNotification = false;
  bool _priorityMode = false;
  bool _dndEnabled = false;
  bool _exemptStarred = false;
  bool _silentVideos = false;
  bool _silentGroups = false;
  String _selectedRingtone = 'Default';
  String _selectedVibration = 'Default';
  String _selectedPopup = 'No popup';
  String _lightColor = 'Default';
  String _notificationPreviewMode = 'Show content';
  String _dndStartTime = '22:00';
  String _dndEndTime = '07:00';

  static const List<String> _ringtones = [
    'Default', 'Chime', 'Echo', 'Pulse', 'Ripple',
    'Marimba', 'Ascending', 'Lumine', 'Hangouts', 'Xenon',
  ];

  static const List<String> _vibrations = [
    'Default', 'Short', 'Long', 'Double', 'Triple', 'Ticking', 'S.O.S',
  ];

  static const List<String> _popups = [
    'No popup', 'Only when screen off', 'Always show popup',
  ];

  static const List<Color> _ledColors = [
    Colors.white, Colors.red, Colors.green, Colors.blue,
    Colors.amber, Colors.purple, Colors.cyan, Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _messageNotifications = prefs.getBool('notif_messages') ?? true;
      _groupNotifications = prefs.getBool('notif_groups') ?? true;
      _callNotifications = prefs.getBool('notif_calls') ?? true;
      _vibrate = prefs.getBool('notif_vibrate') ?? true;
      _soundEnabled = prefs.getBool('notif_sound') ?? true;
      _messagePreview = prefs.getBool('notif_message_preview') ?? true;
      _showSenderOnly = prefs.getBool('notif_sender_only') ?? false;
      _hideNotificationContent = prefs.getBool('notif_hide_content') ?? false;
      _showNoPreview = prefs.getBool('notif_no_preview') ?? false;
      _ledIndicator = prefs.getBool('notif_led') ?? false;
      _popupNotification = prefs.getBool('notif_popup') ?? false;
      _priorityMode = prefs.getBool('notif_priority') ?? false;
      _dndEnabled = prefs.getBool('notif_dnd') ?? false;
      _exemptStarred = prefs.getBool('notif_exempt_starred') ?? false;
      _silentVideos = prefs.getBool('notif_silent_videos') ?? false;
      _silentGroups = prefs.getBool('notif_silent_groups') ?? false;
      _selectedRingtone = prefs.getString('notif_ringtone') ?? 'Default';
      _selectedVibration = prefs.getString('notif_vibration') ?? 'Default';
      _selectedPopup = prefs.getString('notif_popup_style') ?? 'No popup';
      _lightColor = prefs.getString('notif_led_color') ?? 'Default';
      _notificationPreviewMode = prefs.getString('notif_preview_mode') ?? 'Show content';
      _dndStartTime = prefs.getString('notif_dnd_start') ?? '22:00';
      _dndEndTime = prefs.getString('notif_dnd_end') ?? '07:00';
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void _showPickerSheet(String title, List<String> items, String current, Function(String) onSelected) {
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
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              ...items.map((item) => RadioListTile<String>(
                title: Text(item, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                value: item,
                groupValue: current,
                activeColor: AppColors.primary,
                onChanged: (v) { Navigator.pop(ctx); onSelected(v ?? item); },
              )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final accent = context.watch<ThemeProvider>().accentColor;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSection('MESSAGE NOTIFICATIONS', [
            _buildSwitchTile(Icons.chat_bubble_rounded, 'Message notifications', _messageNotifications, (v) {
              setState(() => _messageNotifications = v);
              _saveBool('notif_messages', v);
            }, accent, isDark),
            _buildSwitchTile(Icons.group_rounded, 'Group notifications', _groupNotifications, (v) {
              setState(() => _groupNotifications = v);
              _saveBool('notif_groups', v);
            }, accent, isDark),
            _buildSwitchTile(Icons.phone_rounded, 'Call notifications', _callNotifications, (v) {
              setState(() => _callNotifications = v);
              _saveBool('notif_calls', v);
            }, accent, isDark),
          ], isDark, accent),
          _buildSection('NOTIFICATION PRIVACY', [
            _buildTile(Icons.visibility_off_rounded, 'Preview mode', _notificationPreviewMode, () {
              _showPreviewModePicker(context, accent, isDark);
            }, accent, isDark),
            if (_notificationPreviewMode == 'Show sender only')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.accent.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Only sender name shown. Message content hidden.', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey[600])),
                      ),
                    ],
                  ),
                ),
              ),
            if (_notificationPreviewMode == 'No preview')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('No preview at all. Notification shows "New message".', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey[600])),
                      ),
                    ],
                  ),
                ),
              ),
            _buildSwitchTile(Icons.short_text_rounded, 'Hide message content', _hideNotificationContent, (v) {
              setState(() {
                _hideNotificationContent = v;
                if (v) { _showSenderOnly = false; _showNoPreview = false; _notificationPreviewMode = 'Show content'; }
              });
              _saveBool('notif_hide_content', v);
            }, accent, isDark),
            _buildSwitchTile(Icons.volume_off_rounded, 'Silent notifications for videos', _silentVideos, (v) {
              setState(() => _silentVideos = v);
              _saveBool('notif_silent_videos', v);
            }, accent, isDark),
            _buildSwitchTile(Icons.group_off_rounded, 'Silent notifications for groups', _silentGroups, (v) {
              setState(() => _silentGroups = v);
              _saveBool('notif_silent_groups', v);
            }, accent, isDark),
          ], isDark, accent),
          _buildSection('DO NOT DISTURB', [
            _buildSwitchTile(Icons.do_not_disturb_alt_rounded, 'Scheduled DND', _dndEnabled, (v) {
              setState(() => _dndEnabled = v);
              _saveBool('notif_dnd', v);
            }, accent, isDark),
            if (_dndEnabled) ...[
              _buildTile(Icons.wb_twilight_rounded, 'Start time', _dndStartTime, () {
                _showTimePicker(context, 'Start time', _dndStartTime, (v) {
                  setState(() => _dndStartTime = v);
                  _saveString('notif_dnd_start', v);
                }, isDark);
              }, accent, isDark),
              _buildTile(Icons.wb_sunny_rounded, 'End time', _dndEndTime, () {
                _showTimePicker(context, 'End time', _dndEndTime, (v) {
                  setState(() => _dndEndTime = v);
                  _saveString('notif_dnd_end', v);
                }, isDark);
              }, accent, isDark),
              _buildSwitchTile(Icons.star_rounded, 'Allow exceptions for starred contacts', _exemptStarred, (v) {
                setState(() => _exemptStarred = v);
                _saveBool('notif_exempt_starred', v);
              }, accent, isDark),
            ],
          ], isDark, accent),
          _buildSection('TONE & VIBRATION', [
            _buildTile(Icons.music_note_rounded, 'Ringtone', _selectedRingtone, () {
              _showPickerSheet('Ringtone', _ringtones, _selectedRingtone, (v) {
                setState(() => _selectedRingtone = v);
                _saveString('notif_ringtone', v);
              });
            }, accent, isDark),
            _buildTile(Icons.vibration_rounded, 'Vibration pattern', _selectedVibration, () {
              _showPickerSheet('Vibration', _vibrations, _selectedVibration, (v) {
                setState(() => _selectedVibration = v);
                _saveString('notif_vibration', v);
              });
            }, accent, isDark),
            _buildSwitchTile(Icons.volume_up_rounded, 'Sound enabled', _soundEnabled, (v) {
              setState(() => _soundEnabled = v);
              _saveBool('notif_sound', v);
            }, accent, isDark),
            _buildSwitchTile(Icons.videocam_rounded, 'Silent video playback', _silentVideos, (v) {
              setState(() => _silentVideos = v);
              _saveBool('notif_silent_videos', v);
            }, accent, isDark),
          ], isDark, accent),
          _buildSection('POPUP & ADVANCED', [
            _buildTile(Icons.notifications_active_rounded, 'Popup notification', _selectedPopup, () {
              _showPickerSheet('Popup notification', _popups, _selectedPopup, (v) {
                setState(() => _selectedPopup = v);
                _saveString('notif_popup_style', v);
              });
            }, accent, isDark),
            _buildSwitchTile(Icons.light_rounded, 'LED indicator', _ledIndicator, (v) {
              setState(() => _ledIndicator = v);
              _saveBool('notif_led', v);
            }, accent, isDark),
            if (_ledIndicator)
              _buildTile(Icons.palette_rounded, 'LED color', _lightColor, () {
                _showColorPicker(context, accent, isDark);
              }, accent, isDark),
            _buildSwitchTile(Icons.priority_high_rounded, 'High priority', _priorityMode, (v) {
              setState(() => _priorityMode = v);
              _saveBool('notif_priority', v);
            }, accent, isDark),
          ], isDark, accent),
          _buildSection('PREVIEW', [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                        ),
                        child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _notificationPreviewMode == 'No preview' ? 'ChatWave' : 'Contact Name',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _notificationPreviewMode == 'No preview'
                                  ? 'New message'
                                  : _notificationPreviewMode == 'Show sender only'
                                      ? 'New message from Contact Name'
                                      : _hideNotificationContent
                                          ? 'Message hidden'
                                          : 'Hey! How are you?',
                              style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Text('Now', style: TextStyle(fontSize: 11, color: isDark ? Colors.white24 : Colors.grey[400])),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ], isDark, accent),
        ],
      ),
    );
  }

  void _showPreviewModePicker(BuildContext context, Color accent, bool isDark) {
    const modes = ['Show content', 'Show sender only', 'No preview'];
    const icons = [Icons.visibility_rounded, Icons.person_rounded, Icons.visibility_off_rounded];
    const descs = [
      'Show sender name + message content',
      'Show sender name only, hide message',
      'Show "New message" only, hide everything',
    ];
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
              Text('Notification Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              ...List.generate(modes.length, (i) => RadioListTile<String>(
                title: Row(
                  children: [
                    Icon(icons[i], size: 20, color: accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(modes[i], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                          Text(descs[i], style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey[500])),
                        ],
                      ),
                    ),
                  ],
                ),
                value: modes[i],
                groupValue: _notificationPreviewMode,
                activeColor: accent,
                onChanged: (v) {
                  Navigator.pop(ctx);
                  setState(() {
                    _notificationPreviewMode = v!;
                    _hideNotificationContent = v == 'No preview';
                    _showSenderOnly = v == 'Show sender only';
                    _showNoPreview = v == 'No preview';
                  });
                  _saveString('notif_preview_mode', v!);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context, String title, String current, Function(String) onSelected, bool isDark) {
    final parts = current.split(':');
    final initialHour = int.tryParse(parts[0]) ?? 22;
    final initialMinute = int.tryParse(parts[1]) ?? 0;
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: isDark ? Brightness.dark : Brightness.light),
      ), child: child!),
    ).then((time) {
      if (time != null) {
        final formatted = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        onSelected(formatted);
      }
    });
  }

  void _showColorPicker(BuildContext context, Color accent, bool isDark) {
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
              Text('LED Color', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12, runSpacing: 12,
                children: _ledColors.map((c) {
                  final name = c == Colors.white ? 'White' : _colorName(c);
                  final selected = _lightColor == name;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _lightColor = name);
                      _saveString('notif_led_color', name);
                      Navigator.pop(ctx);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c,
                            border: Border.all(
                              color: selected ? accent : (isDark ? Colors.white24 : Colors.grey[300]!),
                              width: selected ? 3 : 1,
                            ),
                            boxShadow: selected ? [BoxShadow(color: accent.withOpacity(0.4), blurRadius: 8)] : null,
                          ),
                          child: selected ? Icon(Icons.check, color: c.computeLuminance() > 0.5 ? Colors.black : Colors.white, size: 20) : null,
                        ),
                        const SizedBox(height: 4),
                        Text(name, style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.grey[600])),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _colorName(Color c) {
    if (c == Colors.red) return 'Red';
    if (c == Colors.green) return 'Green';
    if (c == Colors.blue) return 'Blue';
    if (c == Colors.amber) return 'Amber';
    if (c == Colors.purple) return 'Purple';
    if (c == Colors.cyan) return 'Cyan';
    if (c == Colors.pink) return 'Pink';
    return 'White';
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: accent, letterSpacing: 0.8)),
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

  Widget _buildTile(IconData icon, String title, String subtitle, VoidCallback onTap, Color accent, bool isDark) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: accent, size: 22),
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
        decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: accent, size: 22),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: accent),
    );
  }
}
