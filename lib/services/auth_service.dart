import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<String?> sendOTP(String phoneNumber) async {
    final res = await _api.post('/api/auth/send-otp', {
      'phoneNumber': phoneNumber,
    });
    if (res['success'] == true) {
      return res['verificationId'];
    }
    return null;
  }

  Future<bool> verifyOTP(String verificationId, String smsCode) async {
    final res = await _api.post('/api/auth/verify-otp', {
      'verificationId': verificationId,
      'smsCode': smsCode,
    });
    if (res['success'] == true && res['token'] != null) {
      await _api.setToken(res['token']);
      return true;
    }
    return false;
  }

  Future<bool> registerUser({
    required String uid,
    required String displayName,
    required String phoneNumber,
    String? photoURL,
    String? status,
  }) async {
    final res = await _api.post('/api/auth/register', {
      'uid': uid,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'status': status,
    });
    return res['success'] == true;
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final res = await _api.get('/api/auth/user/$uid');
      if (res['user'] != null) {
        return UserModel.fromMap(res['user'], uid);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> updateUserData(String uid, Map<String, dynamic> data) async {
    final res = await _api.put('/api/auth/user/$uid', data);
    return res['success'] == true;
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final res = await _api.get('/api/auth/users?q=$query');
    final list = res['users'] as List? ?? [];
    return list.map((u) => UserModel.fromMap(u, u['uid'] ?? '')).toList();
  }

  Future<void> signOut() async {
    // Clear local session
  }
}
