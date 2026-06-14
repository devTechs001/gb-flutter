import 'package:flutter/material.dart';

class ZenoThemes {
  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color accent,
    required Color scaffoldBg,
    required Color appBarBg,
    required Color cardBg,
    Color? surface,
    Color? error,
    Color? hint,
    Color? divider,
    Color? focus,
    Color? highlight,
    Color? splash,
    bool useMaterial3 = true,
  }) {
    final isDark = brightness == Brightness.dark;
    final s = surface ?? (isDark ? const Color(0xFF1E1E2E) : Colors.white);
    final e = error ?? Colors.redAccent;

    return ThemeData(
      useMaterial3: useMaterial3,
      brightness: brightness,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primary,
              secondary: accent,
              surface: s,
              error: e,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF2D3436),
              onError: Colors.white,
            )
          : ColorScheme.light(
              primary: primary,
              secondary: accent,
              surface: s,
              error: e,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: const Color(0xFF2D3436),
              onError: Colors.white,
            ),
      primaryColor: primary,
      scaffoldBackgroundColor: scaffoldBg,
      cardColor: cardBg,
      hintColor: hint ?? (isDark ? const Color(0xFFB2BEC3) : const Color(0xFFB2BEC3)),
      dividerColor: divider ?? (isDark ? const Color(0xFF3D3D5C) : const Color(0xFFE0E0E0)),
      focusColor: focus ?? accent.withOpacity(0.12),
      highlightColor: highlight ?? (isDark ? accent.withOpacity(0.08) : primary.withOpacity(0.08)),
      splashColor: splash ?? (isDark ? accent.withOpacity(0.16) : primary.withOpacity(0.16)),
      canvasColor: s,
      disabledColor: isDark ? const Color(0xFF636E72) : const Color(0xFFB2BEC3),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: appBarBg,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2D2D44) : const Color(0xFFF0F0F5),
        hintStyle: TextStyle(color: isDark ? const Color(0xFF636E72) : const Color(0xFFB2BEC3)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF3D3D5C) : const Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: e, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: e, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primary.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 1,
        color: cardBg,
        shadowColor: isDark ? Colors.black26 : Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: s,
        elevation: 8,
        modalBackgroundColor: s,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        modalElevation: 8,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: s,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF2D3436),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: isDark ? const Color(0xFFB2BEC3) : const Color(0xFF636E72),
          fontSize: 16,
        ),
      ),

      iconTheme: IconThemeData(
        color: isDark ? const Color(0xFFB2BEC3) : const Color(0xFF636E72),
        size: 24,
      ),

      dividerTheme: DividerThemeData(
        color: divider ?? (isDark ? const Color(0xFF3D3D5C) : const Color(0xFFE0E0E0)),
        thickness: 0.5,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF2D2D44) : const Color(0xFFF0F0F5),
        labelStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF2D3436),
          fontSize: 13,
        ),
        secondaryLabelStyle: TextStyle(
          color: isDark ? const Color(0xFFB2BEC3) : const Color(0xFF636E72),
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        selectedColor: primary.withOpacity(0.2),
        selectedShadowColor: primary.withOpacity(0.3),
        brightness: brightness,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: s,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF2D3436),
          fontSize: 14,
        ),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: primary.withOpacity(0.3),
        selectionHandleColor: primary,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF2D2D44) : const Color(0xFF2D3436),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return isDark ? const Color(0xFF636E72) : const Color(0xFFB2BEC3);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary.withOpacity(0.5);
          return isDark ? const Color(0xFF3D3D5C) : const Color(0xFFE0E0E0);
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return isDark ? const Color(0xFF636E72) : const Color(0xFFB2BEC3);
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return isDark ? const Color(0xFF636E72) : const Color(0xFFB2BEC3);
        }),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: primary.withOpacity(0.24),
        thumbColor: primary,
        overlayColor: primary.withOpacity(0.12),
        valueIndicatorColor: primary,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primary.withOpacity(0.24),
        circularTrackColor: primary.withOpacity(0.24),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: s,
        selectedItemColor: primary,
        unselectedItemColor: isDark ? const Color(0xFF636E72) : const Color(0xFFB2BEC3),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: s,
        indicatorColor: primary.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white);
          }
          return TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF636E72) : const Color(0xFFB2BEC3),
          );
        }),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: s,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
        ),
      ),

      timePickerTheme: TimePickerThemeData(
        backgroundColor: s,
        hourMinuteTextColor: isDark ? Colors.white : const Color(0xFF2D3436),
        dialHandColor: primary,
        dialBackgroundColor: isDark ? const Color(0xFF2D2D44) : const Color(0xFFF0F0F5),
        entryModeIconColor: primary,
      ),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: s,
        headerBackgroundColor: primary,
        headerForegroundColor: Colors.white,
        todayForegroundColor: WidgetStateProperty.all(primary),
        todayBackgroundColor: WidgetStateProperty.all(primary.withOpacity(0.12)),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return isDark ? Colors.white : const Color(0xFF2D3436);
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
      ),

      

      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isDark ? const Color(0xFF2D2D44) : const Color(0xFFF0F0F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      expansionTileTheme: ExpansionTileThemeData(
        iconColor: isDark ? const Color(0xFFB2BEC3) : const Color(0xFF636E72),
        collapsedIconColor: isDark ? const Color(0xFFB2BEC3) : const Color(0xFF636E72),
        textColor: isDark ? Colors.white : const Color(0xFF2D3436),
        collapsedTextColor: isDark ? Colors.white : const Color(0xFF2D3436),
        shape: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF3D3D5C) : const Color(0xFFE0E0E0),
          ),
        ),
        collapsedShape: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF3D3D5C) : const Color(0xFFE0E0E0),
          ),
        ),
      ),

      badgeTheme: BadgeThemeData(
        backgroundColor: e,
        textColor: Colors.white,
        smallSize: 8,
        largeSize: 20,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D44) : const Color(0xFF2D3436),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),

      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  // ─── 24 Themes ─────────────────────────────────────────────────────────────

  static final ThemeData defaultTheme = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFF6C5CE7),
    accent: const Color(0xFF00CEC9),
    scaffoldBg: const Color(0xFFF8F9FA),
    appBarBg: const Color(0xFF6C5CE7),
    cardBg: Colors.white,
    surface: Colors.white,
  );

  static final ThemeData midnight = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF2C3E50),
    accent: const Color(0xFF3498DB),
    scaffoldBg: const Color(0xFF1A252F),
    appBarBg: const Color(0xFF2C3E50),
    cardBg: const Color(0xFF233140),
    surface: const Color(0xFF233140),
    hint: const Color(0xFF8EA4B8),
    divider: const Color(0xFF34495E),
    focus: const Color(0xFF3498DB),
    highlight: const Color(0xFF2980B9),
    splash: const Color(0xFF2980B9),
  );

  static final ThemeData ocean = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFF0984E3),
    accent: const Color(0xFF00CEC9),
    scaffoldBg: const Color(0xFFF0F8FF),
    appBarBg: const Color(0xFF0984E3),
    cardBg: Colors.white,
    surface: Colors.white,
    hint: const Color(0xFF74B9FF),
    divider: const Color(0xFFDFE6E9),
    focus: const Color(0xFF0984E3),
    highlight: const Color(0xFF74B9FF),
    splash: const Color(0xFF0984E3),
  );

  static final ThemeData forest = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFF00B894),
    accent: const Color(0xFF55EFC4),
    scaffoldBg: const Color(0xFFF0FFF4),
    appBarBg: const Color(0xFF00B894),
    cardBg: Colors.white,
    surface: Colors.white,
    hint: const Color(0xFF81ECB2),
    divider: const Color(0xFFDFE6E9),
  );

  static final ThemeData sunset = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFFE17055),
    accent: const Color(0xFFFDCB6E),
    scaffoldBg: const Color(0xFFFFF8F0),
    appBarBg: const Color(0xFFE17055),
    cardBg: Colors.white,
    surface: Colors.white,
    hint: const Color(0xFFFAB1A0),
    divider: const Color(0xFFF0E0D0),
    error: const Color(0xFFD63031),
  );

  static final ThemeData lavender = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFFA29BFE),
    accent: const Color(0xFF6C5CE7),
    scaffoldBg: const Color(0xFFF8F7FF),
    appBarBg: const Color(0xFFA29BFE),
    cardBg: Colors.white,
    surface: Colors.white,
    hint: const Color(0xFFC8C3FF),
    divider: const Color(0xFFE8E6FF),
  );

  static final ThemeData neon = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF00FF88),
    accent: const Color(0xFF00CCCC),
    scaffoldBg: const Color(0xFF0A0A14),
    appBarBg: const Color(0xFF0F0F1A),
    cardBg: const Color(0xFF14142A),
    surface: const Color(0xFF14142A),
    hint: const Color(0xFF636E72),
    divider: const Color(0xFF1E1E3A),
    error: const Color(0xFFFF3366),
  );

  static final ThemeData crimson = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFFD63031),
    accent: const Color(0xFFFF7675),
    scaffoldBg: const Color(0xFFFFF5F5),
    appBarBg: const Color(0xFFD63031),
    cardBg: Colors.white,
    surface: Colors.white,
    hint: const Color(0xFFFFB3B3),
    divider: const Color(0xFFF0D0D0),
    error: const Color(0xFFC0392B),
  );

  static final ThemeData nordic = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF2D3436),
    accent: const Color(0xFF74B9FF),
    scaffoldBg: const Color(0xFF1E2325),
    appBarBg: const Color(0xFF2D3436),
    cardBg: const Color(0xFF2A3032),
    surface: const Color(0xFF2A3032),
    hint: const Color(0xFF636E72),
    divider: const Color(0xFF3D4446),
    focus: const Color(0xFF74B9FF),
  );

  static final ThemeData amber = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFFFDCB6E),
    accent: const Color(0xFFE17055),
    scaffoldBg: const Color(0xFFFFFBF0),
    appBarBg: const Color(0xFFFDCB6E),
    cardBg: Colors.white,
    surface: Colors.white,
    hint: const Color(0xFFFFEAA7),
    divider: const Color(0xFFF0E8D0),
    error: const Color(0xFFD63031),
  );

  static final ThemeData mint = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFF55EFC4),
    accent: const Color(0xFF00B894),
    scaffoldBg: const Color(0xFFF0FFF8),
    appBarBg: const Color(0xFF55EFC4),
    cardBg: Colors.white,
    surface: Colors.white,
    hint: const Color(0xFFA0E8D0),
    divider: const Color(0xFFD0F0E8),
  );

  static final ThemeData rose = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFFFD79A8),
    accent: const Color(0xFF6C5CE7),
    scaffoldBg: const Color(0xFFFFF5F8),
    appBarBg: const Color(0xFFFD79A8),
    cardBg: Colors.white,
    surface: Colors.white,
    hint: const Color(0xFFFCB8D0),
    divider: const Color(0xFFF0DEE6),
  );

  static final ThemeData slate = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF636E72),
    accent: const Color(0xFF74B9FF),
    scaffoldBg: const Color(0xFF1E2124),
    appBarBg: const Color(0xFF2D3436),
    cardBg: const Color(0xFF2A3032),
    surface: const Color(0xFF2A3032),
    hint: const Color(0xFF7F8C8D),
    divider: const Color(0xFF3D4446),
    focus: const Color(0xFF74B9FF),
  );

  static final ThemeData peach = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFFFF9FF3),
    accent: const Color(0xFFF368E0),
    scaffoldBg: const Color(0xFFFFF8FC),
    appBarBg: const Color(0xFFFF9FF3),
    cardBg: Colors.white,
    surface: Colors.white,
    hint: const Color(0xFFFDCCCC),
    divider: const Color(0xFFF5E0EE),
    error: const Color(0xFFFF3366),
  );

  static final ThemeData violet = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF6D214F),
    accent: const Color(0xFFB33771),
    scaffoldBg: const Color(0xFF1A0D14),
    appBarBg: const Color(0xFF6D214F),
    cardBg: const Color(0xFF2A1425),
    surface: const Color(0xFF2A1425),
    hint: const Color(0xFF8E4770),
    divider: const Color(0xFF3D1F32),
    focus: const Color(0xFFB33771),
  );

  static final ThemeData coral = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFFFF6B6B),
    accent: const Color(0xFFEE5A24),
    scaffoldBg: const Color(0xFFFFF5F3),
    appBarBg: const Color(0xFFFF6B6B),
    cardBg: Colors.white,
    surface: Colors.white,
    hint: const Color(0xFFFFB0A0),
    divider: const Color(0xFFF0D8D4),
    error: const Color(0xFFC0392B),
  );

  static final ThemeData teal = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF00B894),
    accent: const Color(0xFF00CEC9),
    scaffoldBg: const Color(0xFF0D1A18),
    appBarBg: const Color(0xFF00B894),
    cardBg: const Color(0xFF142A25),
    surface: const Color(0xFF142A25),
    hint: const Color(0xFF4A8E7A),
    divider: const Color(0xFF1F3D35),
  );

  static final ThemeData plum = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF2D3436),
    accent: const Color(0xFFA29BFE),
    scaffoldBg: const Color(0xFF1A1C1E),
    appBarBg: const Color(0xFF2D3436),
    cardBg: const Color(0xFF262A2E),
    surface: const Color(0xFF262A2E),
    hint: const Color(0xFF6C6E72),
    divider: const Color(0xFF383C40),
    focus: const Color(0xFFA29BFE),
  );

  static final ThemeData amoled = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF000000),
    accent: const Color(0xFF00FF88),
    scaffoldBg: Colors.black,
    appBarBg: const Color(0xFF050505),
    cardBg: const Color(0xFF0A0A0A),
    surface: const Color(0xFF0A0A0A),
    hint: const Color(0xFF333333),
    divider: const Color(0xFF1A1A1A),
    focus: const Color(0xFF00FF88),
    highlight: const Color(0xFF00FF88),
    splash: const Color(0xFF00FF88),
  );

  static final ThemeData matrix = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF00FF00),
    accent: const Color(0xFF00CC00),
    scaffoldBg: const Color(0xFF000800),
    appBarBg: const Color(0xFF001100),
    cardBg: const Color(0xFF001A00),
    surface: const Color(0xFF001A00),
    hint: const Color(0xFF004400),
    divider: const Color(0xFF002200),
    error: const Color(0xFFFF0033),
  );

  static final ThemeData aurora = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF1A1A2E),
    accent: const Color(0xFFE94560),
    scaffoldBg: const Color(0xFF0F0F1A),
    appBarBg: const Color(0xFF1A1A2E),
    cardBg: const Color(0xFF16213E),
    surface: const Color(0xFF16213E),
    hint: const Color(0xFF4A4A6A),
    divider: const Color(0xFF2A2A44),
    error: const Color(0xFFE94560),
    focus: const Color(0xFFE94560),
  );

  static final ThemeData blossom = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFFFF69B4),
    accent: const Color(0xFFFFB6C1),
    scaffoldBg: const Color(0xFFFFF0F5),
    appBarBg: const Color(0xFFFF69B4),
    cardBg: Colors.white,
    surface: Colors.white,
    hint: const Color(0xFFFFB6D9),
    divider: const Color(0xFFFFE0EC),
    error: const Color(0xFFFF3366),
  );

  static final ThemeData monochrome = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF2D3436),
    accent: const Color(0xFF636E72),
    scaffoldBg: const Color(0xFF121314),
    appBarBg: const Color(0xFF1A1B1C),
    cardBg: const Color(0xFF1E1F20),
    surface: const Color(0xFF1E1F20),
    hint: const Color(0xFF555555),
    divider: const Color(0xFF2A2B2C),
    focus: const Color(0xFF636E72),
  );

  static final ThemeData sakura = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFFFF6B9D),
    accent: const Color(0xFFFFB3C6),
    scaffoldBg: const Color(0xFFFFF5F7),
    appBarBg: const Color(0xFFFF6B9D),
    cardBg: Colors.white,
    surface: Colors.white,
    hint: const Color(0xFFFFC0D0),
    divider: const Color(0xFFFFE0E8),
    error: const Color(0xFFE8305A),
  );

  static final ThemeData cyberpunk = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF00F5FF),
    accent: const Color(0xFFFF00C8),
    scaffoldBg: const Color(0xFF0B0A1A),
    appBarBg: const Color(0xFF12102A),
    cardBg: const Color(0xFF1A1840),
    surface: const Color(0xFF1A1840),
    hint: const Color(0xFF5A58A0),
    divider: const Color(0xFF2A2850),
    error: const Color(0xFFFF0055),
    focus: const Color(0xFFFF00C8),
  );

  static final ThemeData candy = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFFFF6B9D),
    accent: const Color(0xFFC44DFF),
    scaffoldBg: const Color(0xFFFFF5FA),
    appBarBg: const Color(0xFFFF6B9D),
    cardBg: Colors.white,
    surface: Colors.white,
    hint: const Color(0xFFFFB0D0),
    divider: const Color(0xFFFFE0EE),
    error: const Color(0xFFFF0044),
    focus: const Color(0xFFC44DFF),
  );

  static final ThemeData desert = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFFD4A373),
    accent: const Color(0xFFCC8B3A),
    scaffoldBg: const Color(0xFFFEF5E7),
    appBarBg: const Color(0xFFD4A373),
    cardBg: Colors.white,
    surface: Colors.white,
    hint: const Color(0xFFE8C9A0),
    divider: const Color(0xFFF0E0D0),
    error: const Color(0xFFC0392B),
    focus: const Color(0xFFCC8B3A),
  );

  static final ThemeData galaxy = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF7C3AED),
    accent: const Color(0xFFF59E0B),
    scaffoldBg: const Color(0xFF050510),
    appBarBg: const Color(0xFF0A0A20),
    cardBg: const Color(0xFF101030),
    surface: const Color(0xFF101030),
    hint: const Color(0xFF4A4A7A),
    divider: const Color(0xFF202050),
    error: const Color(0xFFEF4444),
    focus: const Color(0xFFF59E0B),
  );

  static final ThemeData lavenderDream = _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFFC084FC),
    accent: const Color(0xFFF472B6),
    scaffoldBg: const Color(0xFF0E0A1A),
    appBarBg: const Color(0xFF1A1230),
    cardBg: const Color(0xFF221840),
    surface: const Color(0xFF221840),
    hint: const Color(0xFF6A5A9A),
    divider: const Color(0xFF302050),
    error: const Color(0xFFE11D48),
    focus: const Color(0xFFF472B6),
  );

  static final ThemeData sunsetBeach = _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFFFF7F50),
    accent: const Color(0xFFFFD700),
    scaffoldBg: const Color(0xFFFFF8F0),
    appBarBg: const Color(0xFFFF7F50),
    cardBg: Colors.white,
    surface: Colors.white,
    hint: const Color(0xFFFFB090),
    divider: const Color(0xFFF0E0D0),
    error: const Color(0xFFFF4500),
    focus: const Color(0xFFFFD700),
  );

  // ─── Getters ───────────────────────────────────────────────────────────────

  static Map<String, ThemeData> getAll() => {
    'Default': defaultTheme,
    'Midnight': midnight,
    'Ocean': ocean,
    'Forest': forest,
    'Sunset': sunset,
    'Lavender': lavender,
    'Neon': neon,
    'Crimson': crimson,
    'Nordic': nordic,
    'Amber': amber,
    'Mint': mint,
    'Rose': rose,
    'Slate': slate,
    'Peach': peach,
    'Violet': violet,
    'Coral': coral,
    'Teal': teal,
    'Plum': plum,
    'AMOLED': amoled,
    'Matrix': matrix,
    'Aurora': aurora,
    'Blossom': blossom,
    'Monochrome': monochrome,
    'Sakura': sakura,
    'Cyberpunk': cyberpunk,
    'Candy': candy,
    'Desert': desert,
    'Galaxy': galaxy,
    'Lavender Dream': lavenderDream,
    'Sunset Beach': sunsetBeach,
  };

  static List<Map<String, dynamic>> getThemePreviews() => [
    {'name': 'Default', 'primary': const Color(0xFF6C5CE7), 'accent': const Color(0xFF00CEC9), 'isDark': false},
    {'name': 'Midnight', 'primary': const Color(0xFF2C3E50), 'accent': const Color(0xFF3498DB), 'isDark': true},
    {'name': 'Ocean', 'primary': const Color(0xFF0984E3), 'accent': const Color(0xFF00CEC9), 'isDark': false},
    {'name': 'Forest', 'primary': const Color(0xFF00B894), 'accent': const Color(0xFF55EFC4), 'isDark': false},
    {'name': 'Sunset', 'primary': const Color(0xFFE17055), 'accent': const Color(0xFFFDCB6E), 'isDark': false},
    {'name': 'Lavender', 'primary': const Color(0xFFA29BFE), 'accent': const Color(0xFF6C5CE7), 'isDark': false},
    {'name': 'Neon', 'primary': const Color(0xFF00FF88), 'accent': const Color(0xFF00CCCC), 'isDark': true},
    {'name': 'Crimson', 'primary': const Color(0xFFD63031), 'accent': const Color(0xFFFF7675), 'isDark': false},
    {'name': 'Nordic', 'primary': const Color(0xFF2D3436), 'accent': const Color(0xFF74B9FF), 'isDark': true},
    {'name': 'Amber', 'primary': const Color(0xFFFDCB6E), 'accent': const Color(0xFFE17055), 'isDark': false},
    {'name': 'Mint', 'primary': const Color(0xFF55EFC4), 'accent': const Color(0xFF00B894), 'isDark': false},
    {'name': 'Rose', 'primary': const Color(0xFFFD79A8), 'accent': const Color(0xFF6C5CE7), 'isDark': false},
    {'name': 'Slate', 'primary': const Color(0xFF636E72), 'accent': const Color(0xFF74B9FF), 'isDark': true},
    {'name': 'Peach', 'primary': const Color(0xFFFF9FF3), 'accent': const Color(0xFFF368E0), 'isDark': false},
    {'name': 'Violet', 'primary': const Color(0xFF6D214F), 'accent': const Color(0xFFB33771), 'isDark': true},
    {'name': 'Coral', 'primary': const Color(0xFFFF6B6B), 'accent': const Color(0xFFEE5A24), 'isDark': false},
    {'name': 'Teal', 'primary': const Color(0xFF00B894), 'accent': const Color(0xFF00CEC9), 'isDark': true},
    {'name': 'Plum', 'primary': const Color(0xFF2D3436), 'accent': const Color(0xFFA29BFE), 'isDark': true},
    {'name': 'AMOLED', 'primary': const Color(0xFF000000), 'accent': const Color(0xFF00FF88), 'isDark': true},
    {'name': 'Matrix', 'primary': const Color(0xFF00FF00), 'accent': const Color(0xFF00CC00), 'isDark': true},
    {'name': 'Aurora', 'primary': const Color(0xFF1A1A2E), 'accent': const Color(0xFFE94560), 'isDark': true},
    {'name': 'Blossom', 'primary': const Color(0xFFFF69B4), 'accent': const Color(0xFFFFB6C1), 'isDark': false},
    {'name': 'Monochrome', 'primary': const Color(0xFF2D3436), 'accent': const Color(0xFF636E72), 'isDark': true},
    {'name': 'Sakura', 'primary': const Color(0xFFFF6B9D), 'accent': const Color(0xFFFFB3C6), 'isDark': false},
    {'name': 'Cyberpunk', 'primary': const Color(0xFF00F5FF), 'accent': const Color(0xFFFF00C8), 'isDark': true},
    {'name': 'Candy', 'primary': const Color(0xFFFF6B9D), 'accent': const Color(0xFFC44DFF), 'isDark': false},
    {'name': 'Desert', 'primary': const Color(0xFFD4A373), 'accent': const Color(0xFFCC8B3A), 'isDark': false},
    {'name': 'Galaxy', 'primary': const Color(0xFF7C3AED), 'accent': const Color(0xFFF59E0B), 'isDark': true},
    {'name': 'Lavender Dream', 'primary': const Color(0xFFC084FC), 'accent': const Color(0xFFF472B6), 'isDark': true},
    {'name': 'Sunset Beach', 'primary': const Color(0xFFFF7F50), 'accent': const Color(0xFFFFD700), 'isDark': false},
  ];
}
