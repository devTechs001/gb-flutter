import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class OnlineStatusService extends ChangeNotifier {
  static final OnlineStatusService _instance = OnlineStatusService._();
  factory OnlineStatusService() => _instance;
  OnlineStatusService._();

  final Map<String, UserModel> _users = {};
  final Map<String, bool> _onlineStatus = {};
  Timer? _simulationTimer;
  bool _notificationsEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;
  set notificationsEnabled(bool v) {
    _notificationsEnabled = v;
    notifyListeners();
  }

  bool isOnline(String userId) => _onlineStatus[userId] ?? false;

  void registerUser(UserModel user) {
    _users[user.uid] = user;
    _onlineStatus[user.uid] = user.isOnline;
  }

  void setOnline(String userId, bool online) {
    final was = _onlineStatus[userId] ?? false;
    _onlineStatus[userId] = online;
    if (online && !was && _notificationsEnabled) {
      notifyListeners();
    }
  }

  void startSimulation({bool enabled = true}) {
    _simulationTimer?.cancel();
    if (!enabled) return;
    _simulationTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      for (final uid in _users.keys) {
        if (uid.startsWith('user_')) {
          final was = _onlineStatus[uid] ?? false;
          final now = DateTime.now().second % 3 == 0;
          _onlineStatus[uid] = now;
          if (now && !was && _notificationsEnabled) {
            final name = _users[uid]?.displayName ?? uid;
            debugPrint('🔵 $name is now online');
          }
        }
      }
      notifyListeners();
    });
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  @override
  void dispose() {
    stopSimulation();
    super.dispose();
  }
}
