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

  void setSampleStatuses(List<StatusModel> statuses) {
    _statuses = statuses;
    notifyListeners();
  }

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
    String? fontFamily,
    int? backgroundColor,
    String? music,
  }) async {
    final status = StatusModel(
      statusId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      mediaURL: mediaURL,
      thumbnailURL: thumbnailURL,
      type: type,
      caption: caption,
      fontFamily: fontFamily,
      backgroundColor: backgroundColor,
      music: music,
    );
    _statuses.insert(0, status);
    notifyListeners();

    try {
      await _api.post('/api/status', {
        'statusId': status.statusId,
        'userId': userId, 'userName': userName, 'userPhoto': userPhoto,
        'mediaURL': mediaURL, 'thumbnailURL': thumbnailURL,
        'type': type, 'caption': caption,
      });
    } catch (_) {}
  }

  Future<void> addViewer(String statusId, String viewerId, String viewerName) async {
    final idx = _statuses.indexWhere((s) => s.statusId == statusId);
    if (idx >= 0) {
      final viewers = List<Map<String, dynamic>>.from(_statuses[idx].viewers);
      viewers.add({'userId': viewerId, 'userName': viewerName, 'timestamp': DateTime.now().millisecondsSinceEpoch});
      final s = _statuses[idx];
      _statuses[idx] = StatusModel(
        statusId: s.statusId, userId: s.userId, userName: s.userName,
        userPhoto: s.userPhoto, mediaURL: s.mediaURL, thumbnailURL: s.thumbnailURL,
        type: s.type, caption: s.caption, fontFamily: s.fontFamily,
        backgroundColor: s.backgroundColor, music: s.music, timestamp: s.timestamp,
        expiresAt: s.expiresAt, viewers: viewers, isMuted: s.isMuted,
      );
      notifyListeners();
    }
    try { await _api.post('/api/status/$statusId/view', {'userId': viewerId, 'userName': viewerName}); } catch (_) {}
  }

  Future<void> deleteStatus(String statusId) async {
    _statuses.removeWhere((s) => s.statusId == statusId);
    notifyListeners();
    try { await _api.delete('/api/status/$statusId'); } catch (_) {}
  }

  void handleStatusUpdate(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';
    if (type == 'new' && data['status'] != null) {
      final status = StatusModel.fromMap(data['status'], data['status']['statusId'] ?? '');
      final existing = _statuses.indexWhere((s) => s.statusId == status.statusId);
      if (existing < 0) _statuses.insert(0, status);
      notifyListeners();
    } else if (type == 'delete' && data['statusId'] != null) {
      _statuses.removeWhere((s) => s.statusId == data['statusId']);
      notifyListeners();
    } else if (type == 'view' && data['statusId'] != null) {
      final viewerId = data['viewerId'] as String? ?? '';
      final viewerName = data['viewerName'] as String? ?? 'Unknown';
      addViewer(data['statusId'], viewerId, viewerName);
    }
  }

  Future<String?> uploadStatusMedia(String filePath, String type) async {
    final folder = type == 'image' ? 'status_images' : 'status_videos';
    return await _storageService.uploadFile(filePath: filePath, folder: folder);
  }
}
