import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../utils/helpers.dart';
import '../../config/app_config.dart';
import '../home/home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _statusController = TextEditingController(
    text: AppConfig.defaultStatus,
  );
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt, color: AppColors.primary),
              ),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library, color: AppColors.accent),
              ),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final xFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (xFile != null) {
        setState(() => _imageFile = File(xFile.path));
      }
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Helpers.showSnackBar(context, 'Please enter your name', isError: true);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.uploadAndSetupProfile(
      displayName: name,
      status: _statusController.text.trim(),
      imagePath: _imageFile?.path,
    );

    if (success != null && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else if (mounted) {
      Helpers.showSnackBar(
        context,
        authProvider.error ?? 'Failed to save profile',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Your Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                      border: Border.all(color: AppColors.primary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _imageFile != null
                        ? ClipOval(
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 36, color: AppColors.primary.withValues(alpha: 0.6)),
                              const SizedBox(height: 4),
                              Text(
                                'Add Photo',
                                style: TextStyle(fontSize: 12, color: AppColors.primary.withValues(alpha: 0.6)),
                              ),
                            ],
                          ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.edit, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _imageFile != null ? 'Tap to change' : 'Add a profile photo',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your name',
                  hintText: 'Enter your full name',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  hintStyle: TextStyle(color: AppColors.textHint),
                  prefixIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(20),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _statusController,
                decoration: InputDecoration(
                  labelText: 'Status',
                  hintText: 'What\'s on your mind?',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  hintStyle: TextStyle(color: AppColors.textHint),
                  prefixIcon: Icon(Icons.emoji_emotions_outlined, color: AppColors.accent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(20),
                ),
                maxLength: 139,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(height: 32),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline),
                              SizedBox(width: 8),
                              Text('Save & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Skip for now',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
