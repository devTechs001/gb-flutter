import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  final Map<String, List<MessageModel>> _messageCache = {};
  final Map<String, ChatModel> _chatCache = {};
  List<ChatModel> _allChats = [];
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final chatData = prefs.getString('local_chats');
    if (chatData != null) {
      final list = jsonDecode(chatData) as List;
      _allChats = list.map((c) => ChatModel.fromMap(c, c['chatId'] ?? '')).toList();
      for (final chat in _allChats) {
        _chatCache[chat.chatId] = chat;
        _loadCachedMessages(chat.chatId);
      }
    }
    _initialized = true;
  }

  Future<void> _saveChats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_chats', jsonEncode(_allChats.map((c) => c.toMap()).toList()));
  }

  Future<void> _saveMessages(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final msgs = _messageCache[chatId] ?? [];
    await prefs.setString('local_msgs_$chatId', jsonEncode(msgs.map((m) => m.toMap()).toList()));
  }

  void _loadCachedMessages(String chatId) {
    SharedPreferences.getInstance().then((prefs) {
      final data = prefs.getString('local_msgs_$chatId');
      if (data != null) {
        final list = jsonDecode(data) as List;
        _messageCache[chatId] = list.map((m) => MessageModel.fromMap(m, m['messageId'] ?? '')).toList();
      }
    });
  }

  List<ChatModel> getChats() => _allChats;

  List<MessageModel> getMessages(String chatId) => _messageCache[chatId] ?? [];

  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
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
    final msg = MessageModel(
      messageId: 'local_${DateTime.now().millisecondsSinceEpoch}_${senderId}',
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      type: type,
      content: content,
      mediaURL: mediaURL,
      thumbnailURL: thumbnailURL,
      fileName: fileName,
      fileSize: fileSize,
      duration: duration,
      latitude: latitude,
      longitude: longitude,
      contactName: contactName,
      contactPhone: contactPhone,
      replyTo: replyTo,
      isForwarded: isForwarded,
      forwardedFrom: forwardedFrom,
      timestamp: DateTime.now(),
      deliveredTo: {senderId: true},
      readBy: {senderId: true},
    );

    _messageCache.putIfAbsent(chatId, () => []);
    _messageCache[chatId]!.insert(0, msg);
    await _saveMessages(chatId);

    final chat = _chatCache[chatId];
    if (chat != null) {
      final updated = ChatModel(
        chatId: chat.chatId,
        type: chat.type,
        participants: chat.participants,
        groupName: chat.groupName,
        groupPhoto: chat.groupPhoto,
        groupDescription: chat.groupDescription,
        groupAdmin: chat.groupAdmin,
        lastMessage: content,
        lastMessageSender: senderName,
        lastMessageType: type,
        lastMessageTime: DateTime.now(),
        createdAt: chat.createdAt,
        unreadCount: chat.unreadCount,
        mutedBy: chat.mutedBy,
        pinnedBy: chat.pinnedBy,
        archivedBy: chat.archivedBy,
        isBroadcast: chat.isBroadcast,
        broadcastName: chat.broadcastName,
      );
      final idx = _allChats.indexWhere((c) => c.chatId == chatId);
      if (idx >= 0) _allChats[idx] = updated;
      _chatCache[chatId] = updated;
      await _saveChats();
    }

    return msg;
  }

  Future<void> addChat(ChatModel chat) async {
    _allChats.add(chat);
    _chatCache[chat.chatId] = chat;
    _messageCache[chat.chatId] = [];
    await _saveChats();
  }

  Future<void> removeChat(String chatId) async {
    _allChats.removeWhere((c) => c.chatId == chatId);
    _chatCache.remove(chatId);
    _messageCache.remove(chatId);
    await _saveChats();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('local_msgs_$chatId');
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    final msgs = _messageCache[chatId];
    if (msgs == null) return;
    msgs.removeWhere((m) => m.messageId == messageId);
    await _saveMessages(chatId);
  }

  Future<void> editMessage(String chatId, String messageId, String newContent) async {
    final msgs = _messageCache[chatId];
    if (msgs == null) return;
    final idx = msgs.indexWhere((m) => m.messageId == messageId);
    if (idx >= 0) {
      msgs[idx] = MessageModel(
        messageId: msgs[idx].messageId,
        chatId: chatId,
        senderId: msgs[idx].senderId,
        senderName: msgs[idx].senderName,
        type: msgs[idx].type,
        content: newContent,
        mediaURL: msgs[idx].mediaURL,
        thumbnailURL: msgs[idx].thumbnailURL,
        fileName: msgs[idx].fileName,
        fileSize: msgs[idx].fileSize,
        duration: msgs[idx].duration,
        latitude: msgs[idx].latitude,
        longitude: msgs[idx].longitude,
        contactName: msgs[idx].contactName,
        contactPhone: msgs[idx].contactPhone,
        replyTo: msgs[idx].replyTo,
        isForwarded: msgs[idx].isForwarded,
        forwardedFrom: msgs[idx].forwardedFrom,
        timestamp: msgs[idx].timestamp,
        edited: true,
        deliveredTo: msgs[idx].deliveredTo,
        readBy: msgs[idx].readBy,
        reactions: msgs[idx].reactions,
        deleted: msgs[idx].deleted,
        linkPreviewUrl: msgs[idx].linkPreviewUrl,
        linkPreviewImage: msgs[idx].linkPreviewImage,
        linkPreviewTitle: msgs[idx].linkPreviewTitle,
        linkPreviewDescription: msgs[idx].linkPreviewDescription,
        pollQuestion: msgs[idx].pollQuestion,
        pollOptions: msgs[idx].pollOptions,
        pollVotes: msgs[idx].pollVotes,
        waveform: msgs[idx].waveform,
        senderPhotoURL: msgs[idx].senderPhotoURL,
      );
      await _saveMessages(chatId);
    }
  }

  Future<void> reactToMessage(String chatId, String messageId, String userId, String reaction) async {
    final msgs = _messageCache[chatId];
    if (msgs == null) return;
    final idx = msgs.indexWhere((m) => m.messageId == messageId);
    if (idx >= 0) {
      final existing = List<Map<String, dynamic>>.from(msgs[idx].reactions);
      existing.add({'userId': userId, 'reaction': reaction});
      msgs[idx] = MessageModel(
        messageId: msgs[idx].messageId,
        chatId: chatId,
        senderId: msgs[idx].senderId,
        senderName: msgs[idx].senderName,
        type: msgs[idx].type,
        content: msgs[idx].content,
        mediaURL: msgs[idx].mediaURL,
        thumbnailURL: msgs[idx].thumbnailURL,
        fileName: msgs[idx].fileName,
        fileSize: msgs[idx].fileSize,
        duration: msgs[idx].duration,
        latitude: msgs[idx].latitude,
        longitude: msgs[idx].longitude,
        contactName: msgs[idx].contactName,
        contactPhone: msgs[idx].contactPhone,
        replyTo: msgs[idx].replyTo,
        isForwarded: msgs[idx].isForwarded,
        forwardedFrom: msgs[idx].forwardedFrom,
        timestamp: msgs[idx].timestamp,
        edited: msgs[idx].edited,
        deliveredTo: msgs[idx].deliveredTo,
        readBy: msgs[idx].readBy,
        reactions: existing,
        deleted: msgs[idx].deleted,
        linkPreviewUrl: msgs[idx].linkPreviewUrl,
        linkPreviewImage: msgs[idx].linkPreviewImage,
        linkPreviewTitle: msgs[idx].linkPreviewTitle,
        linkPreviewDescription: msgs[idx].linkPreviewDescription,
        pollQuestion: msgs[idx].pollQuestion,
        pollOptions: msgs[idx].pollOptions,
        pollVotes: msgs[idx].pollVotes,
        waveform: msgs[idx].waveform,
        senderPhotoURL: msgs[idx].senderPhotoURL,
      );
      await _saveMessages(chatId);
    }
  }

  Future<void> starMessage(String chatId, String messageId, bool starred) async {
    final msgs = _messageCache[chatId];
    if (msgs == null) return;
    final idx = msgs.indexWhere((m) => m.messageId == messageId);
    if (idx >= 0) {
      msgs[idx] = MessageModel(
        messageId: msgs[idx].messageId, chatId: chatId,
        senderId: msgs[idx].senderId, senderName: msgs[idx].senderName,
        type: msgs[idx].type, content: msgs[idx].content,
        mediaURL: msgs[idx].mediaURL, thumbnailURL: msgs[idx].thumbnailURL,
        fileName: msgs[idx].fileName, fileSize: msgs[idx].fileSize,
        duration: msgs[idx].duration, latitude: msgs[idx].latitude,
        longitude: msgs[idx].longitude, contactName: msgs[idx].contactName,
        contactPhone: msgs[idx].contactPhone, replyTo: msgs[idx].replyTo,
        isForwarded: msgs[idx].isForwarded, forwardedFrom: msgs[idx].forwardedFrom,
        timestamp: msgs[idx].timestamp, edited: msgs[idx].edited,
        editedAt: msgs[idx].editedAt, deliveredTo: msgs[idx].deliveredTo,
        readBy: msgs[idx].readBy, reactions: msgs[idx].reactions,
        deleted: msgs[idx].deleted, isStarred: starred,
        linkPreviewUrl: msgs[idx].linkPreviewUrl, linkPreviewImage: msgs[idx].linkPreviewImage,
        linkPreviewTitle: msgs[idx].linkPreviewTitle, linkPreviewDescription: msgs[idx].linkPreviewDescription,
        pollQuestion: msgs[idx].pollQuestion, pollOptions: msgs[idx].pollOptions,
        pollVotes: msgs[idx].pollVotes, waveform: msgs[idx].waveform,
        senderPhotoURL: msgs[idx].senderPhotoURL, messageEffect: msgs[idx].messageEffect,
        pollId: msgs[idx].pollId, pollMultiple: msgs[idx].pollMultiple, pollExpiry: msgs[idx].pollExpiry,
      );
      await _saveMessages(chatId);
    }
  }

  Future<void> markAsRead(String chatId, String userId, String messageId) async {
    final msgs = _messageCache[chatId];
    if (msgs == null) return;
    for (int i = 0; i < msgs.length; i++) {
      if (!msgs[i].readBy.containsKey(userId)) {
        final readBy = Map<String, bool>.from(msgs[i].readBy)..[userId] = true;
        msgs[i] = MessageModel(
          messageId: msgs[i].messageId, chatId: chatId,
          senderId: msgs[i].senderId, senderName: msgs[i].senderName,
          type: msgs[i].type, content: msgs[i].content,
          mediaURL: msgs[i].mediaURL, thumbnailURL: msgs[i].thumbnailURL,
          fileName: msgs[i].fileName, fileSize: msgs[i].fileSize,
          duration: msgs[i].duration, latitude: msgs[i].latitude,
          longitude: msgs[i].longitude, contactName: msgs[i].contactName,
          contactPhone: msgs[i].contactPhone, replyTo: msgs[i].replyTo,
          isForwarded: msgs[i].isForwarded, forwardedFrom: msgs[i].forwardedFrom,
          timestamp: msgs[i].timestamp, edited: msgs[i].edited,
          deliveredTo: msgs[i].deliveredTo, readBy: readBy,
          reactions: msgs[i].reactions, deleted: msgs[i].deleted,
          linkPreviewUrl: msgs[i].linkPreviewUrl, linkPreviewImage: msgs[i].linkPreviewImage,
          linkPreviewTitle: msgs[i].linkPreviewTitle, linkPreviewDescription: msgs[i].linkPreviewDescription,
          pollQuestion: msgs[i].pollQuestion, pollOptions: msgs[i].pollOptions,
          pollVotes: msgs[i].pollVotes, waveform: msgs[i].waveform,
          senderPhotoURL: msgs[i].senderPhotoURL,
        );
      }
    }
    await _saveMessages(chatId);

    final chat = _chatCache[chatId];
    if (chat != null) {
      final updatedUnread = Map<String, int>.from(chat.unreadCount)..[userId] = 0;
      final updated = ChatModel(
        chatId: chat.chatId, type: chat.type, participants: chat.participants,
        groupName: chat.groupName, groupPhoto: chat.groupPhoto,
        groupDescription: chat.groupDescription, groupAdmin: chat.groupAdmin,
        lastMessage: chat.lastMessage, lastMessageSender: chat.lastMessageSender,
        lastMessageType: chat.lastMessageType, lastMessageTime: chat.lastMessageTime,
        createdAt: chat.createdAt, unreadCount: updatedUnread,
        mutedBy: chat.mutedBy, pinnedBy: chat.pinnedBy, archivedBy: chat.archivedBy,
        isBroadcast: chat.isBroadcast, broadcastName: chat.broadcastName,
      );
      final idx = _allChats.indexWhere((c) => c.chatId == chatId);
      if (idx >= 0) _allChats[idx] = updated;
      _chatCache[chatId] = updated;
      await _saveChats();
    }
  }
}
