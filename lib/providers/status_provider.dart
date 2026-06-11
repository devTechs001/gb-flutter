import 'dart:io';
import 'package:flutter/material.dart';
import '../models/status_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class StatusProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final StorageService _storageService = StorageService();
  List<StatusModel> _statuses = [];
  bool _isLoading = false;

  List<StatusModel> get statuses => _statuses;
  bool get isLoading => _isLoading;
  StorageService get storageService => _storageService;

  void loadStatuses(List<String> contactIds) {
    _fetchStatuses(contactIds);
  }

  Future<void> _fetchStatuses(List<String> contactIds) async {
    try {
      final res = await _api.get('/api/status?userIds=${contactIds.join(',')}');
      final list = res['statuses'] as List? ?? [];
      _statuses = list.map((s) => StatusModel.fromMap(s, s['statusId'] ?? '')).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> postStatus({
    required String userId,
    required String userName,
    String? userPhoto,
    required String mediaURL,
    String? thumbnailURL,
    required String type,
    String caption = '',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _api.post('/api/status', {
        'statusId': '',
        'userId': userId,
        'userName': userName,
        'userPhoto': userPhoto,
        'mediaURL': mediaURL,
        'thumbnailURL': thumbnailURL,
        'type': type,
        'caption': caption,
      });
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addViewer(String statusId, String viewerId, String viewerName) async {
    await _api.post('/api/status/$statusId/view', {
      'userId': viewerId,
      'userName': viewerName,
    });
  }

  Future<void> deleteStatus(String statusId) async {
    await _api.delete('/api/status/$statusId');
    _statuses.removeWhere((s) => s.statusId == statusId);
    notifyListeners();
  }

  Future<String?> uploadStatusMedia(String filePath, String type) async {
    final file = File(filePath);
    final folder = type == 'image' ? 'status_images' : 'status_videos';
    return await _storageService.uploadFile(file: file, folder: folder);
  }
}
