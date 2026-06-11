import '../models/call_model.dart';
import 'api_service.dart';

class CallService {
  final ApiService _api = ApiService();

  Future<List<CallModel>> getCalls(String userId) async {
    final res = await _api.get('/api/calls/$userId');
    final list = res['calls'] as List? ?? [];
    return list.map((c) => CallModel.fromMap(c, c['callId'] ?? '')).toList();
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
    await _api.post('/api/calls/log', {
      'callId': '',
      'callerId': callerId,
      'callerName': callerName,
      'callerPhoto': callerPhoto,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPhoto': receiverPhoto,
      'type': type,
      'status': status,
      'direction': direction,
    });
  }

  Future<void> updateCallDuration(String callId, int duration) async {
    await _api.patch('/api/calls/$callId', {
      'duration': duration,
    });
  }

  Future<CallModel?> getCall(String callId) async {
    try {
      final res = await _api.get('/api/calls/$callId');
      if (res['call'] != null) {
        return CallModel.fromMap(res['call'], callId);
      }
    } catch (_) {}
    return null;
  }
}
