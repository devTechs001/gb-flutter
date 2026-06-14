import 'package:flutter/material.dart';
import '../../theme/zeno_colors.dart';
import '../lock/lock_screen.dart';

class SecurityCenterScreen extends StatelessWidget {
  const SecurityCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZenoColors.background,
      appBar: AppBar(
        title: const Text('Security Center'),
        backgroundColor: ZenoColors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildTile(
            context,
            icon: Icons.lock_outline_rounded,
            title: 'Screen Lock',
            subtitle: 'Secure the app with PIN or fingerprint',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LockScreen())),
          ),
          _buildTile(
            context,
            icon: Icons.shield_rounded,
            title: 'Encryption Info',
            subtitle: 'Messages are end-to-end encrypted',
            onTap: () => _showInfoDialog(context, 'Encryption',
                'All messages in ChatWave are protected with end-to-end encryption. This means only you and the person you are communicating with can read them. Even ChatWave cannot read your messages.'),
          ),
          _buildTile(
            context,
            icon: Icons.notifications_active_rounded,
            title: 'Security Notifications',
            subtitle: 'Get alerts about security events',
            onTap: () => _showInfoDialog(context, 'Security Notifications',
                'Security notifications alert you when security-related events occur, such as when your account is accessed from a new device or when a contact\'s security code changes.'),
          ),
          _buildTile(
            context,
            icon: Icons.shield_rounded,
            title: 'Show Security Alerts',
            subtitle: 'Display security notifications in chats',
            onTap: () => _showInfoDialog(context, 'Security Alerts',
                'When enabled, security alerts will be displayed directly in your chat window for important security events, such as when encryption keys change for a contact.'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: ZenoColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message, style: const TextStyle(height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      color: ZenoColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: ZenoColors.primary.withOpacity(0.1),
          child: Icon(icon, color: ZenoColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: ZenoColors.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: ZenoColors.textHint),
        onTap: onTap,
      ),
    );
  }
}
