import 'dart:io';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<String?> sendOTP(String phoneNumber) async {
    try {
      final res = await _api.post('/api/auth/send-otp', {
        'phoneNumber': phoneNumber,
      });
      if (res['success'] == true && res['verificationId'] != null) {
        return res['verificationId'] as String;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyOTP(String verificationId, String smsCode) async {
    try {
      final res = await _api.post('/api/auth/verify-otp', {
        'verificationId': verificationId,
        'smsCode': smsCode,
      });
      if (res['success'] == true && res['token'] != null) {
        await _api.setToken(res['token']);
        return {
          'token': res['token'],
          'uid': res['uid'] ?? '',
          'phone': res['phone'] ?? '',
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> registerUser({
    required String uid,
    required String displayName,
    required String phoneNumber,
    String? photoURL,
    String? status,
  }) async {
    try {
      final res = await _api.post('/api/auth/register', {
        'uid': uid,
        'displayName': displayName,
        'phoneNumber': phoneNumber,
        'photoURL': photoURL,
        'status': status,
      });
      return res['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> uploadPhoto(String filePath) async {
    try {
      final res = await _api.uploadFile(
        filePath,
        'profile_images/${DateTime.now().millisecondsSinceEpoch}',
        fieldName: 'file',
      );
      if (res['success'] == true && res['url'] != null) {
        return res['url'] as String;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final res = await _api.get('/api/auth/user/$uid');
      if (res['user'] != null) {
        return UserModel.fromMap(res['user'] as Map<String, dynamic>, uid);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      final res = await _api.put('/api/auth/user/$uid', data);
      return res['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final encoded = Uri.encodeQueryComponent(query);
      final res = await _api.get('/api/auth/users?q=$encoded');
      final list = res['users'] as List? ?? [];
      return list.map((u) => UserModel.fromMap(u as Map<String, dynamic>, u['uid'] ?? '')).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> signOut() async {
    try {
      await _api.post('/api/auth/signout', {});
    } catch (_) {}
  }
}
