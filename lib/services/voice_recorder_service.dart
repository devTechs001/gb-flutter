import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceRecorderService {
  bool _isRecording = false;
  DateTime? _startTime;
  Timer? _timer;
  int _elapsedSeconds = 0;
  File? _recordedFile;
  VoidCallback? onTimeUpdate;
  VoidCallback? onRecordingComplete;

  bool get isRecording => _isRecording;
  int get elapsedSeconds => _elapsedSeconds;
  File? get recordedFile => _recordedFile;
  String get formattedTime {
    final min = _elapsedSeconds ~/ 60;
    final sec = _elapsedSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  Future<bool> requestPermissions() async {
    final mic = await Permission.microphone.request();
    final storage = await Permission.storage.request();
    return mic.isGranted && storage.isGranted;
  }

  Future<void> startRecording() async {
    final granted = await requestPermissions();
    if (!granted) return;

    _isRecording = true;
    _startTime = DateTime.now();
    _elapsedSeconds = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      onTimeUpdate?.call();
    });

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _recordedFile = File(path);
    await _recordedFile!.writeAsString('placeholder_audio');
  }

  Future<File?> stopRecording() async {
    _timer?.cancel();
    _isRecording = false;

    if (_recordedFile != null && _elapsedSeconds < 1) {
      _recordedFile = null;
    }

    onRecordingComplete?.call();
    return _recordedFile;
  }

  void cancelRecording() {
    _timer?.cancel();
    _isRecording = false;
    _elapsedSeconds = 0;
    _recordedFile = null;
    _startTime = null;
  }

  void dispose() {
    _timer?.cancel();
    cancelRecording();
  }
}
