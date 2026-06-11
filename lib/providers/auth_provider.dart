import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SocketService _socketService = SocketService();

  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;
  String? _verificationId;
  bool _isLoggedIn = false;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  String get userId => _userModel?.uid ?? '';
  SocketService get socketService => _socketService;

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('user_id');
    final token = await ApiService().getToken();
    if (uid != null && token != null) {
      _isLoggedIn = true;
      final user = await _authService.getUserData(uid);
      if (user != null) {
        _userModel = user;
        _socketService.connect(uid, token);
      }
      notifyListeners();
    }
  }

  Future<bool> sendOTP(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final vid = await _authService.sendOTP(phoneNumber);
      if (vid != null) _verificationId = vid;
      _isLoading = false;
      notifyListeners();
      return vid != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOTP(String verificationId, String smsCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.verifyOTP(verificationId, smsCode);
      if (success) {
        final uid = const Uuid().v4();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', uid);
        await prefs.setString('phone', '+1234567890');
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> setupProfile({
    required String displayName,
    String? photoURL,
    String? status,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('user_id') ?? const Uuid().v4();
      final phone = prefs.getString('phone') ?? '+1234567890';

      await prefs.setString('user_id', uid);
      await prefs.setString('user_name', displayName);

      await _authService.registerUser(
        uid: uid,
        displayName: displayName,
        phoneNumber: phone,
        photoURL: photoURL,
        status: status,
      );

      _userModel = UserModel(
        uid: uid,
        phoneNumber: phone,
        displayName: displayName,
        photoURL: photoURL,
        status: status,
      );
      _isLoggedIn = true;

      final token = await ApiService().getToken();
      if (token != null) _socketService.connect(uid, token);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (displayName != null) data['displayName'] = displayName;
      if (photoURL != null) data['photoURL'] = photoURL;
      if (status != null) data['status'] = status;
      await _authService.updateUserData(_userModel?.uid ?? '', data);
      if (_userModel != null) {
        _userModel = _userModel!.copyWith(
          displayName: displayName,
          photoURL: photoURL,
          status: status,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signOut() async {
    _socketService.disconnect();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _userModel = null;
    _isLoggedIn = false;
    notifyListeners();
    return true;
  }
}
