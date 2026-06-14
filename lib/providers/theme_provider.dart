import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/zeno_colors.dart';
import '../theme/zeno_themes.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = ZenoThemes.defaultTheme;
  String _currentThemeName = 'Default';
  Color _accentColor = ZenoColors.accent;
  Color _bubbleColor = ZenoColors.primary;
  String _bubbleStyle = 'rounded';
  String _chatWallpaper = 'default';
  bool _isDarkMode = false;
  bool _isAmoledMode = false;
  double _fontSize = 16.0;
  Color _statusBarColor = ZenoColors.primary;
  Color _navBarColor = ZenoColors.primary;

  ThemeData get currentTheme => _currentTheme;
  String get currentThemeName => _currentThemeName;
  Color get accentColor => _accentColor;
  Color get bubbleColor => _bubbleColor;
  String get bubbleStyle => _bubbleStyle;
  String get chatWallpaper => _chatWallpaper;
  bool get isDarkMode => _isDarkMode;
  bool get isAmoledMode => _isAmoledMode;
  double get fontSize => _fontSize;
  Color get statusBarColor => _statusBarColor;
  Color get navBarColor => _navBarColor;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _currentThemeName = prefs.getString('theme_name') ?? 'Default';
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    _isAmoledMode = prefs.getBool('amoled_mode') ?? false;
    _bubbleStyle = prefs.getString('bubble_style') ?? 'rounded';
    _chatWallpaper = prefs.getString('chat_wallpaper') ?? 'default';
    _fontSize = prefs.getDouble('font_size') ?? 16.0;

    final accentInt = prefs.getInt('accent_color');
    if (accentInt != null) _accentColor = Color(accentInt);
    final bubbleInt = prefs.getInt('bubble_color');
    if (bubbleInt != null) _bubbleColor = Color(bubbleInt);
    final statusInt = prefs.getInt('status_bar_color');
    if (statusInt != null) _statusBarColor = Color(statusInt);
    final navInt = prefs.getInt('nav_bar_color');
    if (navInt != null) _navBarColor = Color(navInt);

    _applyTheme();
    notifyListeners();
  }

  void _applyTheme() {
    String themeName = _currentThemeName;
    if (_isAmoledMode) {
      themeName = 'AMOLED';
    } else if (_isDarkMode) {
      final darkThemes = ['Midnight', 'Nordic', 'Neon', 'Slate', 'Violet', 'Teal', 'Plum', 'Matrix', 'Aurora', 'Monochrome', 'Cyberpunk', 'Galaxy', 'Lavender Dream'];
      if (!darkThemes.contains(themeName)) {
        themeName = 'Midnight';
      }
    }
    final allThemes = ZenoThemes.getAll();
    if (allThemes.containsKey(themeName)) {
      _currentTheme = allThemes[themeName]!;
    } else {
      _currentTheme = ZenoThemes.defaultTheme;
    }
  }

  Future<void> setTheme(String name) async {
    final allThemes = ZenoThemes.getAll();
    if (!allThemes.containsKey(name)) return;
    _currentThemeName = name;
    _currentTheme = allThemes[name]!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_name', name);
    notifyListeners();
  }

  Future<void> setCustomTheme(Map<String, dynamic> config) async {
    if (config.containsKey('accentColor')) {
      _accentColor = config['accentColor'] as Color;
    }
    if (config.containsKey('bubbleColor')) {
      _bubbleColor = config['bubbleColor'] as Color;
    }
    if (config.containsKey('bubbleStyle')) {
      _bubbleStyle = config['bubbleStyle'] as String;
    }
    if (config.containsKey('chatWallpaper')) {
      _chatWallpaper = config['chatWallpaper'] as String;
    }
    if (config.containsKey('isDarkMode')) {
      _isDarkMode = config['isDarkMode'] as bool;
    }
    if (config.containsKey('isAmoledMode')) {
      _isAmoledMode = config['isAmoledMode'] as bool;
    }
    if (config.containsKey('fontSize')) {
      _fontSize = (config['fontSize'] as num).toDouble();
    }
    if (config.containsKey('statusBarColor')) {
      _statusBarColor = config['statusBarColor'] as Color;
    }
    if (config.containsKey('navBarColor')) {
      _navBarColor = config['navBarColor'] as Color;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_theme_config', config.toString());
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent_color', color.toARGB32());
    notifyListeners();
  }

  Future<void> setBubbleStyle(String style) async {
    _bubbleStyle = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bubble_style', style);
    notifyListeners();
  }

  Future<void> setBubbleColor(Color color) async {
    _bubbleColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bubble_color', color.toARGB32());
    notifyListeners();
  }

  static const Map<String, List<Color>> wallpaperPalettes = {
    'default': [Color(0xFFEBE5DD), Color(0xFF0D0D1A)],
    'dark': [Color(0xFF0D0D1A), Color(0xFF0D0D1A)],
    'ocean': [Color(0xFF0A1628), Color(0xFF0D2137)],
    'forest': [Color(0xFF0A1A0A), Color(0xFF0F2A0F)],
    'warm': [Color(0xFF1A0A0A), Color(0xFF2A100A)],
    'purple': [Color(0xFF1A0A28), Color(0xFF2A0F3A)],
    'gradient1': [Color(0xFF0A1628), Color(0xFF1A0A28)],
    'gradient2': [Color(0xFF1A0A0A), Color(0xFF2A1A0A)],
    'gradient3': [Color(0xFF0A1A0A), Color(0xFF0A1A1A)],
    'pattern1': [Color(0xFF1A1A2E), Color(0xFF2A2A3E)],
    'pattern2': [Color(0xFF2A2A1E), Color(0xFF3A3A2E)],
    'pattern3': [Color(0xFF1E1E2E), Color(0xFF2E2E3E)],
    'midnight': [Color(0xFF0A0A1A), Color(0xFF1A1A2A)],
    'sunset': [Color(0xFF2A1005), Color(0xFF1A0A15)],
    'neon': [Color(0xFF0A001A), Color(0xFF001A0A)],
    'pastel': [Color(0xFF2A2025), Color(0xFF3A2A30)],
    'wood': [Color(0xFF1A150A), Color(0xFF2A1A0A)],
    'sky': [Color(0xFF0A1520), Color(0xFF0A2025)],
    'lava': [Color(0xFF1A0A00), Color(0xFF2A0A00)],
    'artic': [Color(0xFF0A1A2A), Color(0xFF0A2A3A)],
    'candy': [Color(0xFF2A0A1A), Color(0xFF1A0A2A)],
  };

  Future<void> setWallpaper(String wallpaper) async {
    _chatWallpaper = wallpaper;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_wallpaper', wallpaper);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    if (_isDarkMode) _isAmoledMode = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    await prefs.setBool('amoled_mode', _isAmoledMode);
    _applyTheme();
    notifyListeners();
  }

  Future<void> toggleAmoled() async {
    _isAmoledMode = !_isAmoledMode;
    if (_isAmoledMode) _isDarkMode = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('amoled_mode', _isAmoledMode);
    await prefs.setBool('dark_mode', _isDarkMode);
    _applyTheme();
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', size);
    notifyListeners();
  }

  Future<void> setStatusBarColor(Color color) async {
    _statusBarColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('status_bar_color', color.toARGB32());
    notifyListeners();
  }

  Future<void> setNavBarColor(Color color) async {
    _navBarColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('nav_bar_color', color.toARGB32());
    notifyListeners();
  }
}
