import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

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

  Future<File?> downloadMedia(String url, {String? fileName}) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;
      final dir = await getTemporaryDirectory();
      final ext = url.contains('.mp4') ? '.mp4' : url.contains('.png') ? '.png' : '.jpg';
      final file = File('${dir.path}/${fileName ?? 'media_${DateTime.now().millisecondsSinceEpoch}'}$ext');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveToGallery(File file) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final name = file.path.split('/').last;
      final saved = await file.copy('${dir.path}/$name');
      return saved.existsSync();
    } catch (_) {
      return false;
    }
  }

  Future<void> shareMedia(String url, {String? text}) async {
    final file = await downloadMedia(url);
    if (file != null) {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: text,
      );
    }
  }

  Future<void> shareFile(File file, {String? text}) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: text,
    );
  }
}
