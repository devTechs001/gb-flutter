import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_config.dart';

class SocketService {
  IO.Socket? _socket;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _callController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _typingController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _statusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _chatUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get callStream => _callController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;
  Stream<Map<String, dynamic>> get chatUpdateStream => _chatUpdateController.stream;

  IO.Socket? get socket => _socket;

  void connect(String userId, String token) {
    _socket = IO.io(AppConfig.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'auth': {'token': token, 'userId': userId},
    });

    _socket!.onConnect((_) {
      _socket!.emit('user_online', {'userId': userId});
    });

    _socket!.on('new_message', (data) {
      _messageController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('chat_updated', (data) {
      _chatUpdateController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('typing', (data) {
      _typingController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('call', (data) {
      _callController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('incoming_call', (data) {
      _callController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('status_update', (data) {
      _statusController.add(Map<String, dynamic>.from(data));
    });

    _socket!.onDisconnect((_) {});
  }

  void joinChat(String chatId) {
    _socket?.emit('join_chat', {'chatId': chatId});
  }

  void leaveChat(String chatId) {
    _socket?.emit('leave_chat', {'chatId': chatId});
  }

  void sendMessage(Map<String, dynamic> data) {
    _socket?.emit('send_message', data);
  }

  void emitTyping(String chatId, String userId, String userName) {
    _socket?.emit('typing', {
      'chatId': chatId,
      'userId': userId,
      'userName': userName,
    });
  }

  void emitOnline(String userId) {
    _socket?.emit('user_online', {'userId': userId});
  }

  void emitOffline(String userId) {
    _socket?.emit('user_offline', {'userId': userId});
  }

  void initiateCall(Map<String, dynamic> callData) {
    _socket?.emit('initiate_call', callData);
  }

  void acceptCall(String callId) {
    _socket?.emit('accept_call', {'callId': callId});
  }

  void rejectCall(String callId) {
    _socket?.emit('reject_call', {'callId': callId});
  }

  void endCall(String callId) {
    _socket?.emit('end_call', {'callId': callId});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _callController.close();
    _typingController.close();
    _statusController.close();
    _chatUpdateController.close();
  }
}
