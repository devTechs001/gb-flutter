import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  Future<File?> pickImageFromCamera() async {
    final granted = await requestPermission(Permission.camera);
    if (!granted) return null;

    final xFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    return xFile != null ? File(xFile.path) : null;
  }

  Future<File?> pickImageFromGallery() async {
    final granted = await requestPermission(Permission.photos);
    if (!granted) return null;

    final xFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    return xFile != null ? File(xFile.path) : null;
  }

  Future<File?> pickVideoFromGallery() async {
    final xFile = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 30));
    return xFile != null ? File(xFile.path) : null;
  }

  Future<File?> pickVideoFromCamera() async {
    final granted = await requestPermission(Permission.camera);
    if (!granted) return null;

    final xFile = await _picker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(seconds: 30));
    return xFile != null ? File(xFile.path) : null;
  }

  Future<PlatformFile?> pickDocument({List<String>? allowedExtensions}) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
      );
      return result?.files.first;
    } catch (e) {
      return null;
    }
  }

  Future<List<XFile>> pickMultipleImages() async {
    final granted = await requestPermission(Permission.photos);
    if (!granted) return [];

    return await _picker.pickMultiImage(imageQuality: 85);
  }

  Future<File?> pickAudio() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg', 'aac'],
      );
      if (result != null && result.files.isNotEmpty) {
        return File(result.files.first.path!);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<File?> captureVideo() async {
    final granted = await requestPermission(Permission.camera);
    if (!granted) return null;
    final grantedMic = await requestPermission(Permission.microphone);
    if (!grantedMic) return null;

    final xFile = await _picker.pickVideo(source: ImageSource.camera);
    return xFile != null ? File(xFile.path) : null;
  }
}
