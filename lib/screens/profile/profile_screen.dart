import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/colors.dart';
import '../../utils/helpers.dart';
import '../calls/call_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().userModel;
    _nameController.text = user?.displayName ?? '';
    _aboutController.text = user?.about ?? user?.status ?? 'Hey there! I am using ChatWave';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final user = auth.userModel;
    final name = user?.displayName ?? 'User';
    final photoUrl = user?.photoURL;
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: accent.withValues(alpha: 0.2),
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? Text(
                          Helpers.getInitials(name),
                          style: TextStyle(color: accent, fontSize: 40, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? const Color(0xFF0F0F1A) : Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              user?.status ?? 'Hey there! I am using ChatWave',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionButton(Icons.call_rounded, 'Call', accent, isDark, () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CallScreen(callerName: name, type: 'audio'),
                  ));
                }),
                const SizedBox(width: 20),
                _actionButton(Icons.videocam_rounded, 'Video', accent, isDark, () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CallScreen(callerName: name, type: 'video'),
                  ));
                }),
                const SizedBox(width: 20),
                _actionButton(Icons.search_rounded, 'Search', accent, isDark, () {}),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Personal Info', [
                    _buildEditableField('Name', _nameController, 'Your name', isDark, accent),
                    const SizedBox(height: 16),
                    _buildEditableField('About', _aboutController, 'Write something about yourself', isDark, accent, maxLines: 3),
                  ], isDark),
                  const SizedBox(height: 16),
                  _buildSection('Contact Info', [
                    _infoRow(Icons.phone_rounded, 'Phone', user?.phoneNumber ?? '+0 000 000 0000', accent, isDark),
                  ], isDark),
                  const SizedBox(height: 16),
                  _buildSection('Security', [
                    _infoRow(Icons.shield_rounded, 'Encryption', 'Messages are end-to-end encrypted', accent, isDark),
                    Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? Colors.white12 : Colors.grey[200]),
                    _infoRow(Icons.fingerprint, 'Security Key', 'Tap to verify', accent, isDark, onTap: () {}),
                  ], isDark),
                  const SizedBox(height: 16),
                  _buildSection('Shared Media', [
                    _buildMediaGrid(accent, isDark),
                  ], isDark),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        auth.updateProfile(displayName: _nameController.text, status: _aboutController.text);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Profile updated'),
                          backgroundColor: accent,
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color accent, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E32) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accent, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E32) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white54 : Colors.black54)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, String hint, bool isDark, Color accent, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accent)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A3E) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: hint,
              hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String title, String subtitle, Color accent, bool isDark, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.black87)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey[500])),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 18, color: isDark ? Colors.white24 : Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid(Color accent, bool isDark) {
    return Column(
      children: [
        Row(
          children: List.generate(4, (i) => Expanded(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A3E) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo_library_outlined, color: isDark ? Colors.white24 : Colors.grey[400]),
              ),
            ),
          )),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.photo_library_rounded, size: 18, color: accent),
          label: Text('View all shared media', style: TextStyle(color: accent, fontSize: 13)),
        ),
      ],
    );
  }
}
