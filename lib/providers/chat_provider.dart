import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/media_service.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final MediaService _mediaService = MediaService();
  List<ChatModel> _chats = [];
  List<MessageModel> _messages = [];
  ChatModel? _currentChat;
  bool _isLoading = false;

  List<ChatModel> get chats => _chats;
  List<MessageModel> get messages => _messages;
  ChatModel? get currentChat => _currentChat;
  bool get isLoading => _isLoading;
  MediaService get mediaService => _mediaService;
  ChatService get chatService => _chatService;

  void loadChats(String uid) {
    _fetchChats(uid);
    Timer.periodic(const Duration(seconds: 5), (_) => _fetchChats(uid));
  }

  Future<void> _fetchChats(String uid) async {
    try {
      _chats = await _chatService.getChats(uid);
      notifyListeners();
    } catch (_) {}
  }

  void loadMessages(String chatId) {
    _isLoading = true;
    notifyListeners();
    _fetchMessages(chatId);
    Timer.periodic(const Duration(seconds: 3), (_) => _fetchMessages(chatId));
  }

  Future<void> _fetchMessages(String chatId) async {
    try {
      _messages = await _chatService.getMessages(chatId);
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

    return await _chatService.createChat(
      currentUid: currentUid,
      otherUid: otherUid,
    );
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
    await _chatService.sendMessage(
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
    );
  }

  void setCurrentChat(ChatModel? chat) {
    _currentChat = chat;
    notifyListeners();
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    await _chatService.deleteMessage(chatId, messageId);
  }

  Future<void> editMessage(String chatId, String messageId, String newContent) async {
    await _chatService.editMessage(chatId, messageId, newContent);
  }

  Future<void> reactToMessage(String chatId, String messageId, String userId, String reaction) async {
    await _chatService.reactToMessage(chatId, messageId, userId, reaction);
  }

  Future<void> markAsRead(String chatId, String userId, String messageId) async {
    await _chatService.markAsRead(chatId, userId, messageId);
  }

  Future<void> toggleMute(String chatId, String userId) async {
    await _chatService.toggleMute(chatId, userId);
  }

  Future<void> togglePin(String chatId, String userId) async {
    await _chatService.togglePin(chatId, userId);
  }

  Future<void> toggleArchive(String chatId, String userId) async {
    // Archive is handled client-side
    notifyListeners();
  }
}
