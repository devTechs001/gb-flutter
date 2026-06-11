import 'dart:io';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'api_service.dart';

class ChatService {
  final ApiService _api = ApiService();

  Future<List<ChatModel>> getChats(String userId) async {
    final res = await _api.get('/api/chats/$userId');
    final list = res['chats'] as List? ?? [];
    return list.map((c) => ChatModel.fromMap(c, c['chatId'] ?? '')).toList();
  }

  Future<List<MessageModel>> getMessages(String chatId, {int limit = 50, String? before}) async {
    String path = '/api/chats/$chatId/messages?limit=$limit';
    if (before != null) path += '&before=$before';
    final res = await _api.get(path);
    final list = res['messages'] as List? ?? [];
    return list.map((m) => MessageModel.fromMap(m, m['messageId'] ?? '')).toList();
  }

  Future<ChatModel?> getChat(String chatId) async {
    try {
      final res = await _api.get('/api/chats/$chatId');
      if (res['chat'] != null) {
        return ChatModel.fromMap(res['chat'], chatId);
      }
    } catch (_) {}
    return null;
  }

  Future<String> createChat({
    required String currentUid,
    required String otherUid,
    String type = 'individual',
    String? groupName,
    String? groupPhoto,
    String? groupDescription,
    List<String>? groupParticipants,
  }) async {
    final res = await _api.post('/api/chats', {
      'chatId': type == 'individual'
          ? '${[currentUid, otherUid]..sort()}'
          : null,
      'type': type,
      'participants': type == 'individual'
          ? [currentUid, otherUid]
          : [currentUid, ...?groupParticipants],
      'groupName': groupName,
      'groupPhoto': groupPhoto,
      'groupDescription': groupDescription,
      'groupAdmin': type == 'group' ? currentUid : null,
    });
    return res['chat']['id'] ?? res['chat']['chatId'] ?? '';
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    String? senderPhotoURL,
    required String type,
    required String content,
    String? mediaURL,
    String? thumbnailURL,
    String? fileName,
    int? fileSize,
    double? duration,
    double? latitude,
    double? longitude,
    String? contactName,
    String? contactPhone,
    String? replyTo,
    bool isForwarded = false,
    String? forwardedFrom,
  }) async {
    await _api.post('/api/chats/$chatId/messages', {
      'messageId': '', // server generates
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoURL': senderPhotoURL,
      'type': type,
      'content': content,
      'mediaURL': mediaURL,
      'thumbnailURL': thumbnailURL,
      'fileName': fileName,
      'fileSize': fileSize,
      'duration': duration,
      'latitude': latitude,
      'longitude': longitude,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'replyTo': replyTo,
      'isForwarded': isForwarded,
      'forwardedFrom': forwardedFrom,
    });
  }

  Future<bool> deleteMessage(String chatId, String messageId) async {
    final res = await _api.delete('/api/chats/$chatId/messages/$messageId');
    return res['success'] == true;
  }

  Future<bool> editMessage(String chatId, String messageId, String newContent) async {
    final res = await _api.patch('/api/chats/$chatId/messages/$messageId', {
      'content': newContent,
      'edited': true,
    });
    return res['success'] == true;
  }

  Future<bool> reactToMessage(String chatId, String messageId, String userId, String reaction) async {
    final res = await _api.post('/api/chats/$chatId/messages/$messageId/react', {
      'userId': userId,
      'reaction': reaction,
    });
    return res['success'] == true;
  }

  Future<bool> markAsRead(String chatId, String userId, String messageId) async {
    final res = await _api.patch('/api/chats/$chatId/messages/$messageId/read', {
      'userId': userId,
    });
    return res['success'] == true;
  }

  Future<String?> uploadMedia(String filePath, String storagePath) async {
    final file = File(filePath);
    final res = await _api.uploadFile('/api/media/upload', file, 'file');
    return res['url'];
  }

  Future<bool> toggleMute(String chatId, String userId) async {
    final res = await _api.patch('/api/chats/$chatId', {
      'mutedBy.$userId': true,
    });
    return res['success'] == true;
  }

  Future<bool> togglePin(String chatId, String userId) async {
    final res = await _api.patch('/api/chats/$chatId', {
      'pinnedBy.$userId': true,
    });
    return res['success'] == true;
  }
}
