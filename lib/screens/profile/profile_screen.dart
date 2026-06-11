import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../utils/helpers.dart';
import '../../config/app_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _nameController;
  late TextEditingController _statusController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.userModel?.displayName ?? '');
    _statusController = TextEditingController(text: auth.userModel?.status ?? AppConfig.defaultStatus);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _changePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'),
            onTap: () => Navigator.pop(context, ImageSource.camera)),
          ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery)),
          ListTile(leading: const Icon(Icons.delete), title: const Text('Remove photo'),
            onTap: () => Navigator.pop(context)),
        ]),
      ),
    );
    if (source != null && source != ImageSource.camera) return;
    final xFile = await _picker.pickImage(source: source ?? ImageSource.gallery, imageQuality: 80);
    if (xFile != null) {
      // Upload and update
    }
  }

  void _saveProfile() {
    context.read<AuthProvider>().updateProfile(
      displayName: _nameController.text.trim(),
      status: _statusController.text.trim(),
    );
    setState(() => _isEditing = false);
    Helpers.showSnackBar(context, 'Profile updated');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) _saveProfile();
              else setState(() => _isEditing = true);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _isEditing ? _changePhoto : null,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Helpers.generateAvatarColor(user?.displayName ?? 'U'),
                    backgroundImage: user?.photoURL != null
                        ? CachedNetworkImageProvider(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? Text(
                            Helpers.getInitials(user?.displayName ?? 'U'),
                            style: const TextStyle(fontSize: 40, color: Colors.white),
                          )
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent,
                        ),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (!_isEditing)
            Text(
              'Tap to change photo',
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
            const SizedBox(height: 32),
            _buildInfoTile(
              icon: Icons.person,
              label: 'Name',
              child: _isEditing
                  ? TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(border: InputBorder.none),
                      style: const TextStyle(fontSize: 16),
                    )
                  : Text(user?.displayName ?? '', style: const TextStyle(fontSize: 16)),
            ),
            _buildDivider(),
            _buildInfoTile(
              icon: Icons.phone,
              label: 'Phone',
              child: Text(user?.phoneNumber ?? '', style: const TextStyle(fontSize: 16)),
            ),
            _buildDivider(),
            _buildInfoTile(
              icon: Icons.info_outline,
              label: 'About',
              child: _isEditing
                  ? TextField(
                      controller: _statusController,
                      decoration: const InputDecoration(border: InputBorder.none),
                      style: const TextStyle(fontSize: 16),
                      maxLength: 139,
                    )
                  : Text(user?.status ?? AppConfig.defaultStatus, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildActionTile(Icons.image, 'Media, links, and docs', () {}),
                  _buildDivider(),
                  _buildActionTile(Icons.star_outline, 'Starred messages', () {}),
                  _buildDivider(),
                  _buildActionTile(Icons.group_outlined, 'Groups in common', () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.textHint),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: AppColors.textHint)),
              const SizedBox(height: 4),
              SizedBox(width: MediaQuery.of(context).size.width - 120, child: child),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryLight),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 60, color: AppColors.divider);
  }
}
