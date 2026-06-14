import '../models/message_model.dart';

mixin AntiDeleteMixin {
  static final Map<String, MessageModel> _messageCache = {};
  static final Map<String, List<MessageModel>> _batchCache = {};

  void cacheMessageLocally(MessageModel message) {
    _messageCache[message.messageId] = message;
  }

  MessageModel? getCachedMessage(String messageId) {
    return _messageCache[messageId];
  }

  static void cacheMessage(MessageModel message) {
    _messageCache[message.messageId] = message;
  }

  static MessageModel? retrieveMessage(String messageId) {
    return _messageCache[messageId];
  }

  static void cacheBatch(List<MessageModel> messages) {
    for (final msg in messages) {
      _messageCache[msg.messageId] = msg;
    }
  }

  static void cacheBatchByKey(String key, List<MessageModel> messages) {
    _batchCache[key] = messages;
  }

  static List<MessageModel>? retrieveBatch(String key) {
    return _batchCache[key];
  }

  static bool hasMessage(String messageId) {
    return _messageCache.containsKey(messageId);
  }

  static int get cachedCount => _messageCache.length;

  static void clearCache() {
    _messageCache.clear();
    _batchCache.clear();
  }

  static void removeMessage(String messageId) {
    _messageCache.remove(messageId);
  }

  List<MessageModel> getCachedBatch(String key) {
    return _batchCache[key] ?? [];
  }

  void cacheBatchMessages(String key, List<MessageModel> messages) {
    _batchCache[key] = messages;
  }
}
