import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
  
  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }
  
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
  
  static Future<String> getString(String key, {String defaultValue = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultValue;
  }
  
  static Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }
  
  static Future<int> getInt(String key, {int defaultValue = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? defaultValue;
  }

  // Privacy preferences
  static Future<void> setHideOnlineStatus(bool v) => saveBool('privacy_hide_online', v);
  static Future<bool> getHideOnlineStatus() => getBool('privacy_hide_online');
  static Future<void> setHideBlueTicks(bool v) => saveBool('privacy_hide_blue_ticks', v);
  static Future<bool> getHideBlueTicks() => getBool('privacy_hide_blue_ticks');
  static Future<void> setHideSecondTick(bool v) => saveBool('privacy_hide_second_tick', v);
  static Future<bool> getHideSecondTick() => getBool('privacy_hide_second_tick');
  static Future<void> setHideTyping(bool v) => saveBool('privacy_hide_typing', v);
  static Future<bool> getHideTyping() => getBool('privacy_hide_typing');
  static Future<void> setFreezeLastSeen(bool v) => saveBool('privacy_freeze_last_seen', v);
  static Future<bool> getFreezeLastSeen() => getBool('privacy_freeze_last_seen');
  static Future<void> setAntiDeleteMessages(bool v) => saveBool('privacy_anti_delete', v);
  static Future<bool> getAntiDeleteMessages() => getBool('privacy_anti_delete', defaultValue: true);
  static Future<void> setAppLockEnabled(bool v) => saveBool('privacy_app_lock', v);
  static Future<bool> getAppLockEnabled() => getBool('privacy_app_lock');
  static Future<void> setAppLockPin(String pin) => saveString('privacy_lock_pin', pin);
  static Future<String> getAppLockPin() => getString('privacy_lock_pin');

  // Schedule messages
  static Future<void> saveScheduledMessage(String json) async {
    final prefs = await SharedPreferences.getInstance();
    final msgs = prefs.getStringList('scheduled_messages') ?? [];
    msgs.add(json);
    await prefs.setStringList('scheduled_messages', msgs);
  }
  
  static Future<List<String>> getScheduledMessages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('scheduled_messages') ?? [];
  }

  // Auto-reply
  static Future<void> saveAutoReply(String trigger, String reply) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auto_reply_$trigger', reply);
  }
  
  static Future<String?> getAutoReply(String trigger) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auto_reply_$trigger');
  }
}
