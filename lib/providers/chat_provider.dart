import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/media_service.dart';
import '../services/local_storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final MediaService _mediaService = MediaService();
  final LocalStorageService _local = LocalStorageService();
  List<ChatModel> _chats = [];
  List<MessageModel> _messages = [];
  ChatModel? _currentChat;
  bool _isLoading = false;
  final Map<String, List<MessageModel>> _sampleMessages = {};

  List<ChatModel> get chats => _chats;
  List<MessageModel> get messages => _messages;
  ChatModel? get currentChat => _currentChat;
  bool get isLoading => _isLoading;
  MediaService get mediaService => _mediaService;
  ChatService get chatService => _chatService;

  void setSampleData(List<ChatModel> chats, Map<String, List<MessageModel>> messages) {
    _chats = chats;
    _sampleMessages.clear();
    _sampleMessages.addAll(messages);
    notifyListeners();
  }

  void loadChats(String uid) {
    final local = _local.getChats();
    if (local.isNotEmpty) {
      _chats = local;
      notifyListeners();
    }
    _fetchChats(uid);
    Timer.periodic(const Duration(seconds: 5), (_) => _fetchChats(uid));
  }

  Future<void> _fetchChats(String uid) async {
    try {
      final chats = await _chatService.getChats(uid);
      if (chats.isNotEmpty) {
        _chats = chats;
      }
      notifyListeners();
    } catch (_) {}
  }

  void loadMessages(String chatId) {
    _isLoading = true;
    notifyListeners();

    final local = _local.getMessages(chatId);
    if (local.isNotEmpty) {
      _messages = local;
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (_sampleMessages.containsKey(chatId)) {
      _messages = _sampleMessages[chatId]!;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _fetchMessages(chatId);
    Timer.periodic(const Duration(seconds: 3), (_) => _fetchMessages(chatId));
  }

  Future<void> _fetchMessages(String chatId) async {
    try {
      final msgs = await _chatService.getMessages(chatId);
      if (msgs.isNotEmpty) {
        _messages = msgs;
      }
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> createOrGetChat(String currentUid, String otherUid) async {
    final chatId = '${[currentUid, otherUid]..sort()}';
    final existing = await _chatService.getChat(chatId);
    if (existing != null) return chatId;
    final id = await _chatService.createChat(currentUid: currentUid, otherUid: otherUid);
    _local.addChat(ChatModel(chatId: id, type: 'individual', participants: [currentUid, otherUid]));
    return id;
  }

  Future<String> createGroup({
    required String currentUid,
    required String groupName,
    String? groupPhoto,
    String? description,
    required List<String> participants,
  }) async {
    return await _chatService.createChat(
      currentUid: currentUid,
      otherUid: participants.first,
      type: 'group',
      groupName: groupName,
      groupPhoto: groupPhoto,
      groupDescription: description,
      groupParticipants: participants,
    );
  }

  Future<void> sendMessage({
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
    final msg = await _local.sendMessage(
      chatId: chatId, senderId: senderId, senderName: senderName,
      type: type, content: content, mediaURL: mediaURL,
      thumbnailURL: thumbnailURL, fileName: fileName, fileSize: fileSize,
      duration: duration, latitude: latitude, longitude: longitude,
      contactName: contactName, contactPhone: contactPhone,
      replyTo: replyTo, isForwarded: isForwarded, forwardedFrom: forwardedFrom,
    );
    _messages.insert(0, msg);
    notifyListeners();

    try {
      await _chatService.sendMessage(
        chatId: chatId, senderId: senderId, senderName: senderName,
        type: type, content: content, mediaURL: mediaURL,
        thumbnailURL: thumbnailURL, fileName: fileName, fileSize: fileSize,
        duration: duration, latitude: latitude, longitude: longitude,
        contactName: contactName, contactPhone: contactPhone,
        replyTo: replyTo, isForwarded: isForwarded, forwardedFrom: forwardedFrom,
      );
    } catch (_) {}
  }

  void setCurrentChat(ChatModel? chat) {
    _currentChat = chat;
    notifyListeners();
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    await _local.deleteMessage(chatId, messageId);
    _messages.removeWhere((m) => m.messageId == messageId);
    notifyListeners();
    try { await _chatService.deleteMessage(chatId, messageId); } catch (_) {}
  }

  Future<void> editMessage(String chatId, String messageId, String newContent) async {
    await _local.editMessage(chatId, messageId, newContent);
    loadMessages(chatId);
    notifyListeners();
    try { await _chatService.editMessage(chatId, messageId, newContent); } catch (_) {}
  }

  Future<void> reactToMessage(String chatId, String messageId, String userId, String reaction) async {
    await _local.reactToMessage(chatId, messageId, userId, reaction);
    loadMessages(chatId);
    notifyListeners();
    try { await _chatService.reactToMessage(chatId, messageId, userId, reaction); } catch (_) {}
  }

  Future<void> markAsRead(String chatId, String userId, String messageId) async {
    await _local.markAsRead(chatId, userId, messageId);
    notifyListeners();
    try { await _chatService.markAsRead(chatId, userId, messageId); } catch (_) {}
  }

  Future<void> toggleMute(String chatId, String userId) async {
    try { await _chatService.toggleMute(chatId, userId); } catch (_) {}
  }

  Future<void> togglePin(String chatId, String userId) async {
    try { await _chatService.togglePin(chatId, userId); } catch (_) {}
  }

  void addIncomingMessage(Map<String, dynamic> data) {
    final msg = MessageModel.fromMap(data, data['messageId'] ?? '');
    final existing = _messages.indexWhere((m) => m.messageId == msg.messageId);
    if (existing >= 0) {
      _messages[existing] = msg;
    } else {
      _messages.insert(0, msg);
    }
    final chatIdx = _chats.indexWhere((c) => c.chatId == msg.chatId);
    if (chatIdx >= 0) {
      final c = _chats[chatIdx];
      _chats[chatIdx] = ChatModel(
        chatId: c.chatId, type: c.type, participants: c.participants,
        groupName: c.groupName, groupPhoto: c.groupPhoto,
        groupDescription: c.groupDescription, groupAdmin: c.groupAdmin,
        lastMessage: msg.content, lastMessageSender: msg.senderName,
        lastMessageType: msg.type, lastMessageTime: msg.timestamp,
        createdAt: c.createdAt, unreadCount: c.unreadCount,
        mutedBy: c.mutedBy, pinnedBy: c.pinnedBy, archivedBy: c.archivedBy,
        isBroadcast: c.isBroadcast, broadcastName: c.broadcastName,
      );
    }
    notifyListeners();
  }

  void handleChatUpdate(Map<String, dynamic> data) {
    final chatId = data['chatId'] as String?;
    if (chatId == null) return;
    final idx = _chats.indexWhere((c) => c.chatId == chatId);
    if (data['type'] == 'group_created' && data['chat'] != null) {
      final chat = ChatModel.fromMap(data['chat'], chatId);
      if (idx < 0) {
        _chats.insert(0, chat);
      }
    } else if (idx >= 0) {
      final c = _chats[idx];
      _chats[idx] = ChatModel(
        chatId: c.chatId, type: c.type, participants: c.participants,
        groupName: data['chat']?['groupName'] ?? c.groupName,
        groupPhoto: data['chat']?['groupPhoto'] ?? c.groupPhoto,
        groupDescription: data['chat']?['groupDescription'] ?? c.groupDescription,
        groupAdmin: data['chat']?['groupAdmin'] ?? c.groupAdmin,
        lastMessage: data['lastMessage'] ?? c.lastMessage,
        lastMessageSender: data['lastMessageSender'] ?? c.lastMessageSender,
        lastMessageType: data['lastMessageType'] ?? c.lastMessageType,
        lastMessageTime: data['lastMessageTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(data['lastMessageTime'])
            : c.lastMessageTime,
        createdAt: c.createdAt, unreadCount: c.unreadCount,
        mutedBy: c.mutedBy, pinnedBy: c.pinnedBy, archivedBy: c.archivedBy,
        isBroadcast: c.isBroadcast, broadcastName: c.broadcastName,
      );
    }
    notifyListeners();
  }

  Future<void> starMessage(String chatId, String messageId, bool starred) async {
    await _local.starMessage(chatId, messageId, starred);
    loadMessages(chatId);
    notifyListeners();
  }

  Future<void> toggleArchive(String chatId, String userId) async {
    final chat = _chats.where((c) => c.chatId == chatId).firstOrNull;
    if (chat == null) return;
    final isArchived = chat.archivedBy[userId] ?? false;
    final updatedChats = _chats.map((c) {
      if (c.chatId == chatId) {
        final updatedArchivedBy = Map<String, bool>.from(c.archivedBy);
        if (isArchived) {
          updatedArchivedBy.remove(userId);
        } else {
          updatedArchivedBy[userId] = true;
        }
        return ChatModel(
          chatId: c.chatId, type: c.type, participants: c.participants,
          groupName: c.groupName, groupPhoto: c.groupPhoto,
          groupDescription: c.groupDescription, groupAdmin: c.groupAdmin,
          lastMessage: c.lastMessage, lastMessageSender: c.lastMessageSender,
          lastMessageType: c.lastMessageType, lastMessageTime: c.lastMessageTime,
          createdAt: c.createdAt, unreadCount: c.unreadCount,
          mutedBy: c.mutedBy, pinnedBy: c.pinnedBy,
          archivedBy: updatedArchivedBy,
          isBroadcast: c.isBroadcast, broadcastName: c.broadcastName,
        );
      }
      return c;
    }).toList();
    _chats = updatedChats;
    notifyListeners();
  }

  Future<bool> addAutoReply(String chatId, String message) async {
    final chat = _chats.where((c) => c.chatId == chatId).firstOrNull;
    if (chat == null) return false;
    final otherParticipant = chat.participants.where((p) => p != _messages.firstOrNull?.senderId).firstOrNull ?? 'user_0';
    final autoMsg = await _local.sendMessage(
      chatId: chatId, senderId: otherParticipant,
      senderName: chat.displayName.isNotEmpty ? chat.displayName : 'Bot',
      type: 'text', content: message,
    );
    _messages.insert(0, autoMsg);
    notifyListeners();
    return true;
  }
}
