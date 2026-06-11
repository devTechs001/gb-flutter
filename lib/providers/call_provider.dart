import 'package:flutter/material.dart';
import '../models/call_model.dart';
import '../services/call_service.dart';

class CallProvider extends ChangeNotifier {
  final CallService _callService = CallService();
  List<CallModel> _calls = [];
  bool _isLoading = false;

  List<CallModel> get calls => _calls;
  bool get isLoading => _isLoading;
  CallService get callService => _callService;

  void loadCalls(String uid) {
    _fetchCalls(uid);
  }

  Future<void> _fetchCalls(String uid) async {
    try {
      _calls = await _callService.getCalls(uid);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> logCall({
    required String callerId,
    required String callerName,
    String? callerPhoto,
    required String receiverId,
    required String receiverName,
    String? receiverPhoto,
    required String type,
    required String status,
    required String direction,
  }) async {
    await _callService.logCall(
      callerId: callerId,
      callerName: callerName,
      callerPhoto: callerPhoto,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverPhoto: receiverPhoto,
      type: type,
      status: status,
      direction: direction,
    );
    await _fetchCalls(callerId);
  }

  Future<void> updateCallDuration(String callId, int duration) async {
    await _callService.updateCallDuration(callId, duration);
  }
}
