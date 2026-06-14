import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/storage_service.dart';
import '../../theme/colors.dart';

class AvatarEditorScreen extends StatefulWidget {
  const AvatarEditorScreen({super.key});

  @override
  State<AvatarEditorScreen> createState() => _AvatarEditorScreenState();
}

class _AvatarEditorScreenState extends State<AvatarEditorScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TransformationController _transformController = TransformationController();
  bool _isSaving = false;
  int _selectedFilter = -1;

  static const List<Color?> _filters = [
    null,
    Color(0xCCFFD700),
    Color(0x4D0000FF),
    Color(0x4DFF0000),
    Color(0x80000000),
    Color(0x4D00FF00),
    Color(0x80FF69B4),
  ];

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final xFile = await _picker.pickImage(source: source, imageQuality: 90, maxWidth: 1024, maxHeight: 1024);
    if (xFile != null) {
      setState(() => _imageFile = File(xFile.path));
    }
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: const Text('Take Photo'),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.accent),
              title: const Text('Choose from Gallery'),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAvatar() async {
    if (_imageFile == null) return;
    setState(() => _isSaving = true);

    try {
      final auth = context.read<AuthProvider>();
      final storage = StorageService();
      final url = await storage.uploadImage(_imageFile!.path, 'profile_images');

      if (url != null && mounted) {
        await auth.updateProfile(photoURL: url);
        if (mounted) Navigator.pop(context, url);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload photo'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor = isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0F2F5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Edit Profile Photo'),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _imageFile != null && !_isSaving ? _saveAvatar : null,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _imageFile != null
                  ? ColorFiltered(
                      colorFilter: _selectedFilter >= 0
                          ? ColorFilter.mode(_filters[_selectedFilter]!, BlendMode.overlay)
                          : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                      child: InteractiveViewer(
                        transformationController: _transformController,
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: _showPicker,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
                          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_rounded, size: 48, color: AppColors.primary.withOpacity(0.6)),
                            const SizedBox(height: 8),
                            Text('Tap to add photo', style: TextStyle(color: AppColors.primary.withOpacity(0.6), fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          if (_imageFile != null) ...[
            const SizedBox(height: 16),
            Text('Pinch to zoom, drag to reposition', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey[500], fontSize: 12)),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return _filterChip(null, 'Original', i == _selectedFilter + 1, isDark);
                  }
                  return _filterChip(_filters[i - 1], 'Filter $i', i == _selectedFilter + 1, isDark);
                },
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showPicker,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Change Photo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveAvatar,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Set as Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }

  Widget _filterChip(Color? color, String label, bool selected, bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = color == null ? -1 : _filters.indexOf(color)),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? (isDark ? const Color(0xFF2A2A3E) : Colors.grey[200]),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
        ),
        child: color == null
            ? Icon(Icons.filter_vintage, size: 20, color: isDark ? Colors.white60 : Colors.grey[600])
            : null,
      ),
    );
  }
}
