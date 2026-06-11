import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF075E54);
  static const Color primaryDark = Color(0xFF054D44);
  static const Color primaryLight = Color(0xFF128C7E);
  static const Color accent = Color(0xFF25D366);
  static const Color accentLight = Color(0xFF34B7F1);

  static const Color background = Color(0xFFECE5DD);
  static const Color surface = Colors.white;
  static const Color darkSurface = Color(0xFF111B21);
  static const Color darkAppBar = Color(0xFF1F2C34);
  static const Color darkBackground = Color(0xFF0B141A);

  static const Color textPrimary = Color(0xFF303030);
  static const Color textSecondary = Color(0xFF667781);
  static const Color textHint = Color(0xFF8696A0);
  static const Color textWhite = Colors.white;

  static const Color divider = Color(0xFFE9EDEF);
  static const Color dividerDark = Color(0xFF313D45);
  static const Color online = Color(0xFF4ADE80);
  static const Color offline = Color(0xFFB0B0B0);

  static const Color messageSent = Color(0xFFD9FDD3);
  static const Color messageReceived = Colors.white;
  static const Color statusBlue = Color(0xFF34B7F1);
  static const Color callGreen = Color(0xFF25D366);
  static const Color callRed = Color(0xFFFF3B30);
  static const Color notificationRed = Color(0xFFEF5350);

  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  static const LinearGradient statusGradient = LinearGradient(
    colors: [Color(0xFF25D366), Color(0xFF128C7E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
