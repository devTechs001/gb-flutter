import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Helpers {
  static String formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    DateTime date;
    if (timestamp is int) {
      date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else if (timestamp is String) {
      date = DateTime.parse(timestamp);
    } else {
      return '';
    }
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return DateFormat('HH:mm').format(date);
    if (diff.inDays < 7) return DateFormat('EEE').format(date);
    return DateFormat('dd/MM/yy').format(date);
  }

  static String formatLastSeen(dynamic timestamp) {
    if (timestamp == null) return 'offline';
    DateTime date;
    if (timestamp is int) {
      date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      date = timestamp.toDate();
    }
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'online';
    if (diff.inHours < 1) return 'last seen ${diff.inMinutes}m ago';
    if (diff.inDays < 1) return 'last seen today at ${DateFormat('HH:mm').format(date)}';
    if (diff.inDays == 1) return 'last seen yesterday at ${DateFormat('HH:mm').format(date)}';
    return 'last seen ${DateFormat('dd/MM/yy').format(date)}';
  }

  static String formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  static Color generateAvatarColor(String name) {
    final colors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.amber, Colors.orange, Colors.deepOrange, Colors.brown,
    ];
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static String generateChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}
