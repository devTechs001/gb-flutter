import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../theme/colors.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});
  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _autoBackup = false;
  String _backupFrequency = 'Manual';
  String _lastBackup = 'Never';
  bool _isBackingUp = false;
  bool _includeMedia = true;

  @override
  void initState() {
    super.initState();
    _loadBackupPrefs();
  }

  Future<void> _loadBackupPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoBackup = prefs.getBool('backup_auto') ?? false;
      _backupFrequency = prefs.getString('backup_frequency') ?? 'Manual';
      _lastBackup = prefs.getString('backup_last_time') ?? 'Never';
      _includeMedia = prefs.getBool('backup_include_media') ?? true;
    });
  }

  Future<void> _saveBackupPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('backup_auto', _autoBackup);
    await prefs.setString('backup_frequency', _backupFrequency);
    await prefs.setString('backup_last_time', _lastBackup);
    await prefs.setBool('backup_include_media', _includeMedia);
  }

  Future<void> _performBackup() async {
    setState(() => _isBackingUp = true);

    try {
      final chatProvider = context.read<ChatProvider>();
      final dir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${dir.path}/chatwave_backup');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final messagesMap = <String, dynamic>{};
      for (final chat in chatProvider.chats) {
        final msgs = chatProvider.messages;
        if (msgs.isNotEmpty) {
          messagesMap[chat.chatId] = msgs.map((m) => m.toMap()).toList();
        }
      }

      final backup = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'version': '3.0.0',
        'chats': chatProvider.chats.map((c) => c.toMap()).toList(),
        'messages': messagesMap,
      };

      final file = File('${backupDir.path}/chatwave_backup.json');
      await file.writeAsString(jsonEncode(backup));

      final now = DateTime.now();
      final formatted = '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
      setState(() => _lastBackup = formatted);
      await _saveBackupPrefs();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup completed successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() => _isBackingUp = false);
  }

  Future<void> _restoreBackup() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/chatwave_backup/chatwave_backup.json');
      if (!await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No backup found to restore'), backgroundColor: Colors.orange),
        );
        return;
      }

      final data = jsonDecode(await file.readAsString());
      final chatProvider = context.read<ChatProvider>();
      final restoredChats = (data['chats'] as List).map((c) => ChatModel.fromMap(c, c['chatId'] ?? '')).toList();
      final restoredMessages = <String, List<MessageModel>>{};
      if (data['messages'] != null) {
        (data['messages'] as Map).forEach((chatId, msgs) {
          restoredMessages[chatId] = (msgs as List).map((m) => MessageModel.fromMap(m, m['messageId'] ?? '')).toList();
        });
      }

      chatProvider.setSampleData(restoredChats, restoredMessages);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showFrequencyPicker() {
    final options = ['Manual', 'Daily', 'Weekly', 'Monthly'];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Backup Frequency'),
        children: options.map((opt) => RadioListTile<String>(
          title: Text(opt),
          value: opt,
          groupValue: _backupFrequency,
          onChanged: (v) {
            setState(() => _backupFrequency = v!);
            _saveBackupPrefs();
            Navigator.pop(ctx);
          },
          activeColor: AppColors.primary,
        )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Backup'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.backup_rounded, size: 64, color: AppColors.primary),
                  const SizedBox(height: 16),
                  const Text('Local Backup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    'Back up your chats and media to local storage',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isBackingUp ? null : _performBackup,
                      icon: _isBackingUp
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.backup_rounded),
                      label: Text(_isBackingUp ? 'Backing Up...' : 'Back Up Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Last backup: $_lastBackup', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _restoreBackup,
                      icon: const Icon(Icons.restore_rounded),
                      label: const Text('Restore from Backup'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto Backup'),
                  subtitle: const Text('Automatically back up your chats'),
                  value: _autoBackup,
                  onChanged: (v) {
                    setState(() => _autoBackup = v);
                    _saveBackupPrefs();
                  },
                  activeColor: AppColors.primary,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  title: const Text('Backup Frequency'),
                  subtitle: Text(_backupFrequency),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showFrequencyPicker,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  title: const Text('Include Media'),
                  subtitle: const Text('Images, videos, audio'),
                  value: _includeMedia,
                  onChanged: (v) {
                    setState(() => _includeMedia = v);
                    _saveBackupPrefs();
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
