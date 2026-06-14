import 'package:flutter/material.dart';
import '../../theme/zeno_colors.dart';
import '../../services/cats/media_cats_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class CATSMediaScreen extends StatelessWidget {
  const CATSMediaScreen({super.key});

  static const List<_CATSFeature> _features = [
    _CATSFeature(
      icon: Icons.photo_library,
      title: 'Batch Send',
      subtitle: 'Send up to 100 images at once',
    ),
    _CATSFeature(
      icon: Icons.video_library,
      title: 'Batch Videos',
      subtitle: 'Send up to 50 videos at once',
    ),
    _CATSFeature(
      icon: Icons.insert_drive_file,
      title: 'Large Files',
      subtitle: 'Send files up to 100MB',
    ),
    _CATSFeature(
      icon: Icons.hd,
      title: 'Original Quality',
      subtitle: 'Send media without compression',
    ),
    _CATSFeature(
      icon: Icons.extension,
      title: 'All File Types',
      subtitle: 'APK, ZIP, PDF, DOC, XLS support',
    ),
    _CATSFeature(
      icon: Icons.audiotrack,
      title: 'Audio to MP3',
      subtitle: 'Convert voice notes to MP3 format',
    ),
    _CATSFeature(
      icon: Icons.gif,
      title: 'Video to GIF',
      subtitle: 'Convert video clips to animated GIF',
    ),
    _CATSFeature(
      icon: Icons.edit,
      title: 'Image Editor',
      subtitle: 'Crop, draw, text, filters on images',
    ),
    _CATSFeature(
      icon: Icons.movie_edit,
      title: 'Video Editor',
      subtitle: 'Trim, crop, add music to videos',
    ),
    _CATSFeature(
      icon: Icons.record_voice_over,
      title: 'Voice Changer',
      subtitle: 'Apply effects to voice messages',
    ),
  ];

  void _onFeatureTap(BuildContext context, _CATSFeature feature) {
    if (feature.title == 'All File Types') {
      _pickAnyFiles(context);
    } else {
      _showComingSoon(context, feature.title);
    }
  }

  void _pickAnyFiles(BuildContext context) async {
    final files = await MediaCATSService.pickAnyFiles();
    if (files.isNotEmpty && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected ${files.length} file(s)')),
      );
    }
  }

  void _showComingSoon(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ZenoColors.surface,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: const Text('This feature is coming soon!',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZenoColors.background,
      appBar: AppBar(
        title: const Text('CATS Media'),
        backgroundColor: ZenoColors.primary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _features.length,
        itemBuilder: (context, index) {
          final feature = _features[index];
          return Card(
            color: ZenoColors.surface,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(feature.icon, color: ZenoColors.accent, size: 32),
              title: Text(feature.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text(feature.subtitle,
                  style: const TextStyle(color: Colors.white70)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: () => _onFeatureTap(context, feature),
            ),
          );
        },
      ),
    );
  }
}

class _CATSFeature {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CATSFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
