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
  String? get verificationId => _verificationId;

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
      final result = await _authService.sendOTP(phoneNumber);
      if (result != null) {
        _verificationId = result;
      }
      _isLoading = false;
      notifyListeners();
      return result != null;
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
      final result = await _authService.verifyOTP(verificationId, smsCode);
      if (result != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', result['uid'] ?? '');
        await prefs.setString('phone', result['phone'] ?? '');
        await ApiService().setToken(result['token'] ?? '');
        _isLoggedIn = true;
      }
      _isLoading = false;
      notifyListeners();
      return result != null;
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

      final success = await _authService.registerUser(
        uid: uid,
        displayName: displayName,
        phoneNumber: phone,
        photoURL: photoURL,
        status: status,
      );

      if (success) {
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

  Future<String?> uploadAndSetupProfile({
    required String displayName,
    String? status,
    String? imagePath,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('user_id') ?? const Uuid().v4();
      final phone = prefs.getString('phone') ?? '+1234567890';

      String? photoURL;
      if (imagePath != null) {
        photoURL = await _authService.uploadPhoto(imagePath);
      }

      final success = await _authService.registerUser(
        uid: uid,
        displayName: displayName,
        phoneNumber: phone,
        photoURL: photoURL,
        status: status,
      );

      if (success) {
        await prefs.setString('user_id', uid);
        await prefs.setString('user_name', displayName);

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
      }

      _isLoading = false;
      notifyListeners();
      return photoURL;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> setupDevUser({
    required String displayName,
    String? status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = 'dev_${const Uuid().v4()}';
    await prefs.setString('user_id', uid);
    await prefs.setString('user_name', displayName);
    await prefs.setString('phone', '+0 000 000 0000');
    _userModel = UserModel(
      uid: uid,
      phoneNumber: '+0 000 000 0000',
      displayName: displayName,
      status: status ?? 'Hey there! I am using ChatWave',
    );
    _isLoggedIn = true;
    notifyListeners();
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
    _verificationId = null;
    _error = null;
    notifyListeners();
    return true;
  }
}
