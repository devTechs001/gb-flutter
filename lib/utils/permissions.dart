import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future<bool> requestCameraAndMic() async {
    final camera = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    return camera.isGranted && mic.isGranted;
  }

  static Future<bool> requestStorage() async {
    final storage = await Permission.storage.request();
    return storage.isGranted;
  }

  static Future<bool> requestContacts() async {
    final contacts = await Permission.contacts.request();
    return contacts.isGranted;
  }

  static Future<bool> requestLocation() async {
    final location = await Permission.location.request();
    return location.isGranted;
  }

  static Future<bool> requestNotification() async {
    final notification = await Permission.notification.request();
    return notification.isGranted;
  }

  static Future<bool> requestPhone() async {
    final phone = await Permission.phone.request();
    return phone.isGranted;
  }

  static Future<void> showPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: Text('Settings'),
          ),
        ],
      ),
    );
  }
}
