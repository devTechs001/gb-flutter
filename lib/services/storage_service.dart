import 'dart:io';
import 'api_service.dart';

class StorageService {
  final ApiService _api = ApiService();

  Future<String?> uploadFile({
    required String filePath,
    required String folder,
    String? fileName,
  }) async {
    try {
      final storagePath = '$folder/${fileName ?? DateTime.now().millisecondsSinceEpoch}';
      final res = await _api.uploadFile(filePath, storagePath, fieldName: 'file');
      return res['url'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadImage(String filePath, String folder) async {
    return await uploadFile(filePath: filePath, folder: folder);
  }

  Future<String?> uploadVideo(String filePath, String folder) async {
    return await uploadFile(filePath: filePath, folder: folder);
  }

  Future<String?> uploadAudio(String filePath, String folder) async {
    return await uploadFile(filePath: filePath, folder: folder);
  }

  Future<String?> uploadDocument(String filePath, String folder) async {
    return await uploadFile(filePath: filePath, folder: folder);
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
