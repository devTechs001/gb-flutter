import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/status_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/colors.dart';
import '../../services/media_service.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final MediaService _mediaService = MediaService();
  final TextEditingController _captionController = TextEditingController();
  File? _mediaFile;
  String _mediaType = 'image';
  String? _selectedFontFamily;
  Color _bgColor = const Color(0xFF128C7E);
  bool _isUploading = false;

  static const List<String> _fontFamilies = [
    'Roboto',
    'Serif',
    'Monospace',
    'Cursive',
    'Sans-serif',
  ];

  static const List<Color> _bgColors = [
    Color(0xFF128C7E),
    Color(0xFF075E54),
    Color(0xFF34B7F1),
    Color(0xFF25D366),
    Color(0xFFFF3B30),
    Color(0xFF5856D6),
    Color(0xFFFF9500),
    Color(0xFF007AFF),
    Color(0xFF000000),
    Color(0xFFFFFFFF),
  ];

  String? _selectedMusic;
  static const List<Map<String, String>> _musicOptions = [
    {'name': 'No music', 'icon': '🎵'},
    {'name': 'Happy Vibes', 'icon': '🎶'},
    {'name': 'Chill LoFi', 'icon': '🎧'},
    {'name': 'Party Mix', 'icon': '🎉'},
    {'name': 'Romantic', 'icon': '💕'},
    {'name': 'Sad Song', 'icon': '😢'},
    {'name': 'Rock Anthem', 'icon': '🤘'},
    {'name': 'Jazz', 'icon': '🎷'},
  ];

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _mediaService.pickImageFromCamera();
    if (file != null) {
      setState(() {
        _mediaFile = file;
        _mediaType = 'image';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final file = await _mediaService.pickImageFromGallery();
    if (file != null) {
      setState(() {
        _mediaFile = file;
        _mediaType = 'image';
      });
    }
  }

  void _showEditPreview(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Preview Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(16),
                  image: _mediaFile != null ? DecorationImage(image: FileImage(_mediaFile!), fit: BoxFit.cover) : null,
                ),
                child: Center(
                  child: _captionController.text.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(_captionController.text, style: TextStyle(fontSize: 22, fontFamily: _selectedFontFamily, color: _bgColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                        )
                      : Text('No caption', style: TextStyle(color: _bgColor.computeLuminance() > 0.5 ? Colors.black38 : Colors.white38)),
                ),
              ),
              if (_selectedMusic != null) Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(children: [const Icon(Icons.music_note, size: 16, color: Colors.green), const SizedBox(width: 6), Text('Song: $_selectedMusic', style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600], fontSize: 12))]),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _sendStatus();
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Post Status'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF128C7E), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendStatus() async {
    if (_isUploading) return;
    setState(() => _isUploading = true);

    try {
      final statusProvider = context.read<StatusProvider>();
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.userId;
      final userName = authProvider.userModel?.displayName ?? 'User';
      final userPhoto = authProvider.userModel?.photoURL;

      String? mediaURL;
      if (_mediaFile != null) {
        mediaURL = await statusProvider.uploadStatusMedia(
          _mediaFile!.path,
          _mediaType,
        );
      }

      await statusProvider.postStatus(
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        mediaURL: mediaURL ?? '',
        type: _mediaType,
        caption: _captionController.text.trim(),
        fontFamily: _selectedFontFamily,
        backgroundColor: _bgColor.value,
        music: _selectedMusic,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post status: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Status'),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _sendStatus,
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'SEND',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Media preview
            Container(
              width: double.infinity,
              height: 300,
              color: _bgColor,
              child: _mediaFile != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          _mediaFile!,
                          fit: BoxFit.contain,
                        ),
                        if (_captionController.text.isNotEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                _captionController.text,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: _bgColor.computeLuminance() > 0.5
                                      ? Colors.black87
                                      : Colors.white,
                                  fontFamily: _selectedFontFamily,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 64,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Add photo or video',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Media source buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Camera'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Text caption
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _captionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Add a caption',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 20),

            // Font family
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Font style',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _fontFamilies.map((font) {
                      final selected = _selectedFontFamily == font;
                      return ChoiceChip(
                        label: Text(
                          font,
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 13,
                          ),
                        ),
                        selected: selected,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        onSelected: (val) {
                          setState(() => _selectedFontFamily = val ? font : null);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Music picker
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Background music', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _musicOptions.map((m) {
                      final selected = _selectedMusic == m['name'];
                      return ChoiceChip(
                        label: Text('${m['icon']} ${m['name']}', style: TextStyle(fontSize: 12, color: selected ? Colors.white : null)),
                        selected: selected,
                        selectedColor: const Color(0xFF128C7E),
                        onSelected: (v) => setState(() => _selectedMusic = v ? m['name'] : null),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Edit preview button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () => _showEditPreview(context),
                icon: const Icon(Icons.preview_rounded, size: 18),
                label: const Text('Preview & Edit before posting'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF128C7E),
                  side: const BorderSide(color: Color(0xFF128C7E)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Background color picker
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Background color',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _bgColors.map((color) {
                      final selected = _bgColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _bgColor = color),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? AppColors.accent : AppColors.divider,
                              width: selected ? 3 : 1,
                            ),
                            boxShadow: selected
                                ? [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 6)]
                                : null,
                          ),
                          child: selected
                              ? const Icon(Icons.check, size: 18, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
