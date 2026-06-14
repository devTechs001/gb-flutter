import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/call_provider.dart';
import '../providers/status_provider.dart';

class SocketListener extends StatefulWidget {
  final Widget child;
  const SocketListener({super.key, required this.child});

  @override
  State<SocketListener> createState() => _SocketListenerState();
}

class _SocketListenerState extends State<SocketListener> {
  StreamSubscription? _messageSub;
  StreamSubscription? _chatUpdateSub;
  StreamSubscription? _callSub;
  StreamSubscription? _statusSub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messageSub != null) return;
    final auth = context.read<AuthProvider>();
    final socket = auth.socketService;
    final chat = context.read<ChatProvider>();
    final call = context.read<CallProvider>();
    final status = context.read<StatusProvider>();

    _messageSub = socket.messageStream.listen((data) => chat.addIncomingMessage(data));
    _chatUpdateSub = socket.chatUpdateStream.listen((data) => chat.handleChatUpdate(data));
    _callSub = socket.callStream.listen((data) => call.handleIncomingCall(data));
    _statusSub = socket.statusStream.listen((data) => status.handleStatusUpdate(data));
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _chatUpdateSub?.cancel();
    _callSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
