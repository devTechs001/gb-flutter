import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../api_service.dart';
import '../../config/zeno_config.dart';

class MediaCATSService {
  static const int maxBatchImages = ZenoConfig.maxBatchImages;
  static const int maxBatchVideos = ZenoConfig.maxBatchVideos;
  static const int maxFileSize = ZenoConfig.maxFileSize;
  
  // Pick multiple images (up to 100)
  static Future<List<XFile>> pickMultipleImages() async {
    final picker = ImagePicker();
    return await picker.pickMultiImage(imageQuality: 100);
  }
  
  // Pick any file type
  static Future<List<PlatformFile>> pickAnyFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ZenoConfig.supportedFileTypes,
    );
    return result?.files ?? [];
  }
  
  // Upload large file
  static Future<String?> uploadLargeFile(File file) async {
    final api = ApiService();
    final res = await api.uploadFile(file.path, 'large_files/${DateTime.now().millisecondsSinceEpoch}', fieldName: 'file');
    return res['url'] as String?;
  }
  
  // Convert voice to MP3 placeholder
  static Future<File?> convertToMP3(File audio) async {
    // In production: use FFmpeg
    return audio;
  }
  
  // Convert video to GIF placeholder
  static Future<File?> convertToGIF(File video) async {
    // In production: use FFmpeg  
    return video;
  }
}
