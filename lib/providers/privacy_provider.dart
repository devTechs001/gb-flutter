import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyProvider extends ChangeNotifier {
  bool _hideOnlineStatus = false;
  bool _hideBlueTicks = false;
  bool _hideSecondTick = false;
  bool _hideTypingIndicator = false;
  bool _hideRecordingIndicator = false;
  bool _freezeLastSeen = false;
  bool _antiDeleteMessages = true;
  bool _antiDeleteStatus = true;
  String? _lastSeenFrozen;
  bool _appLockEnabled = false;
  String? _appLockPin;
  bool _fingerprintEnabled = false;
  String _lockoutTimeMinutes = '1';
  final List<String> _hiddenChats = [];
  final List<String> _archivedChats = [];
  String _profilePhotoVisibility = 'everyone';
  String _aboutVisibility = 'everyone';
  String _statusVisibility = 'everyone';
  String _lastSeenVisibility = 'everyone';
  bool _initialized = false;
  bool _dndEnabled = false;
  bool _ghostMode = false;
  bool _airplaneChatMode = false;
  bool _notificationHideContent = false;
  bool _onlineNotifier = false;
  bool _showMessageStatus = true;
  bool _showOnlineTimestamp = false;
  bool _chatLockEnabled = false;
  String? _chatLockPin;

  bool get hideOnlineStatus => _hideOnlineStatus;
  bool get hideBlueTicks => _hideBlueTicks;
  bool get hideSecondTick => _hideSecondTick;
  bool get hideTypingIndicator => _hideTypingIndicator;
  bool get hideRecordingIndicator => _hideRecordingIndicator;
  bool get freezeLastSeen => _freezeLastSeen;
  bool get antiDeleteMessages => _antiDeleteMessages;
  bool get antiDeleteStatus => _antiDeleteStatus;
  String? get lastSeenFrozen => _lastSeenFrozen;
  bool get appLockEnabled => _appLockEnabled;
  String? get appLockPin => _appLockPin;
  bool get fingerprintEnabled => _fingerprintEnabled;
  String get lockoutTimeMinutes => _lockoutTimeMinutes;
  List<String> get hiddenChats => List.unmodifiable(_hiddenChats);
  List<String> get archivedChats => List.unmodifiable(_archivedChats);
  String get profilePhotoVisibility => _profilePhotoVisibility;
  String get aboutVisibility => _aboutVisibility;
  String get statusVisibility => _statusVisibility;
  String get lastSeenVisibility => _lastSeenVisibility;
  bool get initialized => _initialized;
  bool get dndEnabled => _dndEnabled;
  bool get ghostMode => _ghostMode;
  bool get airplaneChatMode => _airplaneChatMode;
  bool get notificationHideContent => _notificationHideContent;
  bool get onlineNotifier => _onlineNotifier;
  bool get showMessageStatus => _showMessageStatus;
  bool get showOnlineTimestamp => _showOnlineTimestamp;
  bool get chatLockEnabled => _chatLockEnabled;
  String? get chatLockPin => _chatLockPin;

  set dndEnabled(bool value) { _dndEnabled = value; _saveBool('privacy_dnd', value); notifyListeners(); }
  set ghostMode(bool value) { _ghostMode = value; _saveBool('privacy_ghost_mode', value); notifyListeners(); }
  set airplaneChatMode(bool value) { _airplaneChatMode = value; _saveBool('privacy_airplane_chat', value); notifyListeners(); }
  set notificationHideContent(bool value) { _notificationHideContent = value; _saveBool('privacy_hide_notification_content', value); notifyListeners(); }
  set onlineNotifier(bool value) { _onlineNotifier = value; _saveBool('privacy_online_notifier', value); notifyListeners(); }
  set showMessageStatus(bool value) { _showMessageStatus = value; _saveBool('privacy_show_message_status', value); notifyListeners(); }
  set showOnlineTimestamp(bool value) { _showOnlineTimestamp = value; _saveBool('privacy_show_online_timestamp', value); notifyListeners(); }
  set chatLockEnabled(bool value) { _chatLockEnabled = value; _saveBool('privacy_chat_lock_enabled', value); notifyListeners(); }
  set chatLockPin(String? value) { _chatLockPin = value; _saveString('privacy_chat_lock_pin', value); notifyListeners(); }

  set hideOnlineStatus(bool value) {
    _hideOnlineStatus = value;
    _saveBool('privacy_hide_online_status', value);
    notifyListeners();
  }

  set hideBlueTicks(bool value) {
    _hideBlueTicks = value;
    _saveBool('privacy_hide_blue_ticks', value);
    notifyListeners();
  }

  set hideSecondTick(bool value) {
    _hideSecondTick = value;
    _saveBool('privacy_hide_second_tick', value);
    notifyListeners();
  }

  set hideTypingIndicator(bool value) {
    _hideTypingIndicator = value;
    _saveBool('privacy_hide_typing_indicator', value);
    notifyListeners();
  }

  set hideRecordingIndicator(bool value) {
    _hideRecordingIndicator = value;
    _saveBool('privacy_hide_recording_indicator', value);
    notifyListeners();
  }

  set freezeLastSeen(bool value) {
    _freezeLastSeen = value;
    _saveBool('privacy_freeze_last_seen', value);
    notifyListeners();
  }

  set antiDeleteMessages(bool value) {
    _antiDeleteMessages = value;
    _saveBool('privacy_anti_delete_messages', value);
    notifyListeners();
  }

  set antiDeleteStatus(bool value) {
    _antiDeleteStatus = value;
    _saveBool('privacy_anti_delete_status', value);
    notifyListeners();
  }

  set lastSeenFrozen(String? value) {
    _lastSeenFrozen = value;
    _saveString('privacy_last_seen_frozen', value);
    notifyListeners();
  }

  set appLockEnabled(bool value) {
    _appLockEnabled = value;
    _saveBool('privacy_app_lock_enabled', value);
    notifyListeners();
  }

  set appLockPin(String? value) {
    _appLockPin = value;
    _saveString('privacy_app_lock_pin', value);
    notifyListeners();
  }

  set fingerprintEnabled(bool value) {
    _fingerprintEnabled = value;
    _saveBool('privacy_fingerprint_enabled', value);
    notifyListeners();
  }

  set lockoutTimeMinutes(String value) {
    _lockoutTimeMinutes = value;
    _saveString('privacy_lockout_time_minutes', value);
    notifyListeners();
  }

  set profilePhotoVisibility(String value) {
    _profilePhotoVisibility = value;
    _saveString('privacy_profile_photo_visibility', value);
    notifyListeners();
  }

  set aboutVisibility(String value) {
    _aboutVisibility = value;
    _saveString('privacy_about_visibility', value);
    notifyListeners();
  }

  set statusVisibility(String value) {
    _statusVisibility = value;
    _saveString('privacy_status_visibility', value);
    notifyListeners();
  }

  set lastSeenVisibility(String value) {
    _lastSeenVisibility = value;
    _saveString('privacy_last_seen_visibility', value);
    notifyListeners();
  }

  Future<void> getAll() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _hideOnlineStatus = prefs.getBool('privacy_hide_online_status') ?? false;
    _hideBlueTicks = prefs.getBool('privacy_hide_blue_ticks') ?? false;
    _hideSecondTick = prefs.getBool('privacy_hide_second_tick') ?? false;
    _hideTypingIndicator = prefs.getBool('privacy_hide_typing_indicator') ?? false;
    _hideRecordingIndicator = prefs.getBool('privacy_hide_recording_indicator') ?? false;
    _freezeLastSeen = prefs.getBool('privacy_freeze_last_seen') ?? false;
    _antiDeleteMessages = prefs.getBool('privacy_anti_delete_messages') ?? true;
    _antiDeleteStatus = prefs.getBool('privacy_anti_delete_status') ?? true;
    _lastSeenFrozen = prefs.getString('privacy_last_seen_frozen');
    _appLockEnabled = prefs.getBool('privacy_app_lock_enabled') ?? false;
    _appLockPin = prefs.getString('privacy_app_lock_pin');
    _fingerprintEnabled = prefs.getBool('privacy_fingerprint_enabled') ?? false;
    _lockoutTimeMinutes = prefs.getString('privacy_lockout_time_minutes') ?? '1';
    _hiddenChats.clear();
    _hiddenChats.addAll(prefs.getStringList('privacy_hidden_chats') ?? []);
    _archivedChats.clear();
    _archivedChats.addAll(prefs.getStringList('privacy_archived_chats') ?? []);
    _profilePhotoVisibility = prefs.getString('privacy_profile_photo_visibility') ?? 'everyone';
    _aboutVisibility = prefs.getString('privacy_about_visibility') ?? 'everyone';
    _statusVisibility = prefs.getString('privacy_status_visibility') ?? 'everyone';
    _lastSeenVisibility = prefs.getString('privacy_last_seen_visibility') ?? 'everyone';
    _dndEnabled = prefs.getBool('privacy_dnd') ?? false;
    _ghostMode = prefs.getBool('privacy_ghost_mode') ?? false;
    _airplaneChatMode = prefs.getBool('privacy_airplane_chat') ?? false;
    _notificationHideContent = prefs.getBool('privacy_hide_notification_content') ?? false;
    _onlineNotifier = prefs.getBool('privacy_online_notifier') ?? false;
    _showMessageStatus = prefs.getBool('privacy_show_message_status') ?? true;
    _showOnlineTimestamp = prefs.getBool('privacy_show_online_timestamp') ?? false;
    _chatLockEnabled = prefs.getBool('privacy_chat_lock_enabled') ?? false;
    _chatLockPin = prefs.getString('privacy_chat_lock_pin');
    _initialized = true;
    notifyListeners();
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveString(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString(key, value);
    } else {
      await prefs.remove(key);
    }
  }

  void toggleHideOnline() => hideOnlineStatus = !_hideOnlineStatus;
  void toggleBlueTicks() => hideBlueTicks = !_hideBlueTicks;
  void toggleSecondTick() => hideSecondTick = !_hideSecondTick;
  void toggleTypingIndicator() => hideTypingIndicator = !_hideTypingIndicator;
  void toggleRecordingIndicator() => hideRecordingIndicator = !_hideRecordingIndicator;
  void toggleFreezeLastSeen() => freezeLastSeen = !_freezeLastSeen;
  void toggleAntiDeleteMessages() => antiDeleteMessages = !_antiDeleteMessages;
  void toggleAntiDeleteStatus() => antiDeleteStatus = !_antiDeleteStatus;
  void toggleAppLock() => appLockEnabled = !_appLockEnabled;
  void toggleFingerprint() => fingerprintEnabled = !_fingerprintEnabled;
  void toggleDnd() => dndEnabled = !_dndEnabled;
  void toggleGhostMode() => ghostMode = !_ghostMode;
  void toggleAirplaneChat() => airplaneChatMode = !_airplaneChatMode;
  void toggleNotificationHideContent() => notificationHideContent = !_notificationHideContent;
  void toggleOnlineNotifier() => onlineNotifier = !_onlineNotifier;
  void toggleMessageStatus() => showMessageStatus = !_showMessageStatus;
  void toggleOnlineTimestamp() => showOnlineTimestamp = !_showOnlineTimestamp;

  void setAppLockPin(String pin) {
    appLockPin = pin;
    appLockEnabled = true;
  }

  void removeAppLockPin() {
    appLockPin = null;
    appLockEnabled = false;
  }

  void enableFingerprint(bool value) {
    fingerprintEnabled = value;
  }

  Future<void> addHiddenChat(String chatId) async {
    if (!_hiddenChats.contains(chatId)) {
      _hiddenChats.add(chatId);
      await _saveStringList('privacy_hidden_chats', _hiddenChats);
      notifyListeners();
    }
  }

  Future<void> removeHiddenChat(String chatId) async {
    _hiddenChats.remove(chatId);
    await _saveStringList('privacy_hidden_chats', _hiddenChats);
    notifyListeners();
  }

  Future<void> addArchivedChat(String chatId) async {
    if (!_archivedChats.contains(chatId)) {
      _archivedChats.add(chatId);
      await _saveStringList('privacy_archived_chats', _archivedChats);
      notifyListeners();
    }
  }

  Future<void> removeArchivedChat(String chatId) async {
    _archivedChats.remove(chatId);
    await _saveStringList('privacy_archived_chats', _archivedChats);
    notifyListeners();
  }

  bool isChatHidden(String chatId) => _hiddenChats.contains(chatId);
  bool isChatArchived(String chatId) => _archivedChats.contains(chatId);

  Future<void> _saveStringList(String key, List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, list);
  }
}
