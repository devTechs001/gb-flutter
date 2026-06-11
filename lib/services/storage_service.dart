import 'dart:io';
import 'api_service.dart';

class StorageService {
  final ApiService _api = ApiService();

  Future<String?> uploadFile({
    required File file,
    required String folder,
    String? fileName,
  }) async {
    try {
      final res = await _api.uploadFile('/api/media/upload', file, 'file');
      return res['url'];
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadImage(File image, String folder) async {
    return await uploadFile(file: image, folder: folder);
  }

  Future<String?> uploadVideo(File video, String folder) async {
    return await uploadFile(file: video, folder: folder);
  }

  Future<String?> uploadAudio(File audio, String folder) async {
    return await uploadFile(file: audio, folder: folder);
  }

  Future<String?> uploadDocument(File document, String folder) async {
    return await uploadFile(file: document, folder: folder);
  }

  Future<bool> deleteFile(String url) async {
    try {
      await _api.delete('/api/media/delete?url=${Uri.encodeComponent(url)}');
      return true;
    } catch (e) {
      return false;
    }
  }
}
