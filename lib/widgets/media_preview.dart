import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final Function(String filePath, int duration) onComplete;

  const VoiceRecorderWidget({super.key, required this.onComplete});

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isRecording = false;
  int _recordDuration = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordDuration = 0;
    });
    _animController.repeat(reverse: true);
  }

  void _stopRecording() {
    _animController.stop();
    setState(() => _isRecording = false);
    widget.onComplete('/tmp/voice_note.m4a', _recordDuration);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) => Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16 + _animController.value * 20,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: _isRecording ? AppColors.callRed.withValues(alpha: 0.1) : AppColors.background,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mic,
                color: _isRecording ? AppColors.callRed : AppColors.textSecondary,
              ),
              if (_isRecording) ...[
                const SizedBox(width: 8),
                Text(
                  '${_recordDuration ~/ 60}:${(_recordDuration % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(color: AppColors.callRed),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MediaPreviewWidget extends StatelessWidget {
  final String filePath;
  final String type;
  final VoidCallback? onRemove;

  const MediaPreviewWidget({
    super.key,
    required this.filePath,
    required this.type,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (type == 'image')
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(filePath),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            height: 200,
            color: Colors.black,
            child: const Center(child: Icon(Icons.play_circle_fill, size: 60, color: Colors.white)),
          ),
        if (onRemove != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
      ],
    );
  }
}
