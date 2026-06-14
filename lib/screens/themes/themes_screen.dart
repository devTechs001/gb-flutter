import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/zeno_colors.dart';
import '../../theme/zeno_themes.dart';

class ThemesScreen extends StatefulWidget {
  const ThemesScreen({super.key});

  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
  final List<Color> _accentOptions = const [
    Color(0xFF00CEC9), Color(0xFF6C5CE7), Color(0xFFFD79A8),
    Color(0xFFFDCB6E), Color(0xFF74B9FF), Color(0xFF55EFC4),
    Color(0xFFFF7675), Color(0xFFA29BFE), Color(0xFF00B894),
    Color(0xFFE17055), Color(0xFF0984E3), Color(0xFFB33771),
    Color(0xFFFF6B6B), Color(0xFFFF69B4), Color(0xFF00FF88),
    Color(0xFFEE5A24), Color(0xFFF368E0), Color(0xFF636E72),
  ];

  final List<Map<String, dynamic>> _wallpaperOptions = [
    {'key': 'default', 'name': 'Default', 'color': const Color(0xFFEBE5DD), 'isDefault': true},
    {'key': 'dark', 'name': 'Dark', 'color': const Color(0xFF0D0D1A)},
    {'key': 'ocean', 'name': 'Ocean', 'color': const Color(0xFF0A1628)},
    {'key': 'forest', 'name': 'Forest', 'color': const Color(0xFF0A1A0A)},
    {'key': 'warm', 'name': 'Warm', 'color': const Color(0xFF1A0A0A)},
    {'key': 'purple', 'name': 'Purple', 'color': const Color(0xFF1A0A28)},
    {'key': 'gradient1', 'name': 'Blue-Purple', 'colors': [const Color(0xFF0A1628), const Color(0xFF1A0A28)]},
    {'key': 'gradient2', 'name': 'Sunset', 'colors': [const Color(0xFF1A0A0A), const Color(0xFF2A1A0A)]},
    {'key': 'gradient3', 'name': 'Teal-Green', 'colors': [const Color(0xFF0A1A0A), const Color(0xFF0A1A1A)]},
    {'key': 'midnight', 'name': 'Midnight', 'color': const Color(0xFF0A0A1A)},
    {'key': 'sunset', 'name': 'Sunset', 'colors': [const Color(0xFF2A1005), const Color(0xFF1A0A15)]},
    {'key': 'neon', 'name': 'Neon', 'colors': [const Color(0xFF0A001A), const Color(0xFF001A0A)]},
    {'key': 'pastel', 'name': 'Pastel', 'color': const Color(0xFF2A2025)},
    {'key': 'wood', 'name': 'Wood', 'color': const Color(0xFF1A150A)},
    {'key': 'sky', 'name': 'Sky', 'color': const Color(0xFF0A1520)},
    {'key': 'lava', 'name': 'Lava', 'color': const Color(0xFF1A0A00)},
    {'key': 'artic', 'name': 'Arctic', 'color': const Color(0xFF0A1A2A)},
    {'key': 'candy', 'name': 'Candy', 'color': const Color(0xFF2A0A1A)},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, tp, _) {
        final isDark = tp.isDarkMode;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Themes & Style'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildThemeModeSection(tp),
              const SizedBox(height: 24),
              _buildColorThemesSection(tp),
              const SizedBox(height: 24),
              _buildAccentColorSection(tp),
              const SizedBox(height: 24),
              _buildBubbleStyleSection(tp),
              const SizedBox(height: 24),
              _buildWallpaperSection(tp),
              const SizedBox(height: 24),
              _buildFontSizeSection(tp),
              const SizedBox(height: 24),
              _buildAdvancedSection(tp),
              const SizedBox(height: 32),
              _buildApplyButton(tp),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildThemeModeSection(ThemeProvider tp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Theme Mode'),
        Row(
          children: [
            _buildModeChip(tp, 'Light', false, false, Icons.light_mode, () => _setMode(tp, false, false)),
            const SizedBox(width: 8),
            _buildModeChip(tp, 'Dark', true, false, Icons.dark_mode, () => _setMode(tp, true, false)),
            const SizedBox(width: 8),
            _buildModeChip(tp, 'AMOLED', true, true, Icons.contrast, () => _setMode(tp, true, true)),
          ],
        ),
      ],
    );
  }

  Widget _buildModeChip(ThemeProvider tp, String label, bool dark, bool amoled, IconData icon, VoidCallback onTap) {
    final selected = tp.isDarkMode == dark && tp.isAmoledMode == amoled;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? (amoled ? ZenoColors.amoledBackground : ZenoColors.primary)
                : (tp.isDarkMode ? ZenoColors.darkSurface : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? ZenoColors.primary : (tp.isDarkMode ? const Color(0xFF3D3D5C) : const Color(0xFFE0E0E0)),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? Colors.white : (tp.isDarkMode ? Colors.white70 : ZenoColors.textSecondary), size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(
                color: selected ? Colors.white : (tp.isDarkMode ? Colors.white70 : ZenoColors.textPrimary),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _setMode(ThemeProvider tp, bool dark, bool amoled) {
    if (amoled && !tp.isAmoledMode) {
      tp.toggleAmoled();
    } else if (dark && !amoled && !tp.isDarkMode) {
      tp.toggleDarkMode();
    } else if (!dark && (tp.isDarkMode || tp.isAmoledMode)) {
      if (tp.isAmoledMode) tp.toggleAmoled();
      if (tp.isDarkMode) tp.toggleDarkMode();
    }
  }

  Widget _buildColorThemesSection(ThemeProvider tp) {
    final previews = ZenoThemes.getThemePreviews();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Color Themes'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemCount: previews.length,
          itemBuilder: (context, index) {
            final theme = previews[index];
            final name = theme['name'] as String;
            final primary = theme['primary'] as Color;
            final isDark = theme['isDark'] as bool;
            final selected = tp.currentThemeName == name;
            return GestureDetector(
              onTap: () => tp.setTheme(name),
              child: Container(
                decoration: BoxDecoration(
                  color: tp.isDarkMode ? ZenoColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? ZenoColors.primary : (tp.isDarkMode ? const Color(0xFF3D3D5C) : const Color(0xFFE0E0E0)),
                    width: selected ? 2.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: primary,
                          child: isDark
                              ? const Icon(Icons.nightlight_round, color: Colors.white, size: 18)
                              : const Icon(Icons.wb_sunny, color: Colors.white, size: 18),
                        ),
                        if (selected)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: ZenoColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(name, style: TextStyle(
                        fontSize: 11,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        color: tp.isDarkMode ? Colors.white : ZenoColors.textPrimary,
                      ), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAccentColorSection(ThemeProvider tp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Accent Color'),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _accentOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final color = _accentOptions[index];
              final selected = tp.accentColor.value == color.value;
              return GestureDetector(
                onTap: () => tp.setAccentColor(color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: selected
                        ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8, spreadRadius: 1)]
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBubbleStyleSection(ThemeProvider tp) {
    final styles = [
      {'name': 'Rounded', 'key': 'rounded', 'icon': Icons.chat_bubble_outline},
      {'name': 'Square', 'key': 'square', 'icon': Icons.chat_bubble_outline},
      {'name': 'Gradient', 'key': 'gradient', 'icon': Icons.gradient},
      {'name': 'Shadow', 'key': 'shadow', 'icon': Icons.blur_on},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Chat Bubbles'),
        Row(
          children: styles.map((style) {
            final key = style['key'] as String;
            final selected = tp.bubbleStyle == key;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => tp.setBubbleStyle(key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: tp.isDarkMode ? ZenoColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? ZenoColors.primary : (tp.isDarkMode ? const Color(0xFF3D3D5C) : const Color(0xFFE0E0E0)),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(style['icon'] as IconData,
                          color: selected ? ZenoColors.primary : (tp.isDarkMode ? Colors.white70 : ZenoColors.textSecondary),
                          size: 24),
                        const SizedBox(height: 4),
                        Text(style['name'] as String, style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? ZenoColors.primary : (tp.isDarkMode ? Colors.white70 : ZenoColors.textPrimary),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tp.isDarkMode ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: _bubbleDecoration(tp, false),
                child: Text('Hey! How are you?', style: TextStyle(
                  color: tp.bubbleColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
                  fontSize: 14,
                )),
              ),
              const Spacer(),
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: _bubbleDecoration(tp, true),
                child: Text('I\'m great, thanks!', style: TextStyle(
                  color: tp.bubbleColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
                  fontSize: 14,
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _bubbleDecoration(ThemeProvider tp, bool isSent) {
    final color = isSent ? tp.bubbleColor : (tp.isDarkMode ? const Color(0xFF2D2D44) : Colors.white);
    final otherColor = isSent ? Colors.white : tp.bubbleColor;

    switch (tp.bubbleStyle) {
      case 'square':
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        );
      case 'gradient':
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [color, otherColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        );
      case 'shadow':
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: tp.bubbleColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );
      default:
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        );
    }
  }

  Widget _buildWallpaperSection(ThemeProvider tp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Wallpaper'),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _wallpaperOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final option = _wallpaperOptions[index];
              return _buildWallpaperTile(tp, option);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWallpaperTile(ThemeProvider tp, Map<String, dynamic> option) {
    final key = option['key'] as String;
    final selected = tp.chatWallpaper == key;
    final name = option['name'] as String;
    final isDefault = option['isDefault'] == true;
    final color = option['color'] as Color?;
    final colors = option['colors'] as List<Color>?;

    return GestureDetector(
      onTap: () => tp.setWallpaper(key),
      child: Container(
        width: 60,
        child: Column(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color,
                gradient: colors != null ? LinearGradient(colors: colors) : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? ZenoColors.primary : (tp.isDarkMode ? const Color(0xFF3D3D5C) : const Color(0xFFE0E0E0)),
                  width: selected ? 2.5 : 1,
                ),
              ),
              child: Center(
                child: selected
                    ? Icon(Icons.check, color: color != null && color.computeLuminance() > 0.5 ? ZenoColors.primary : Colors.white, size: 18)
                    : Icon(Icons.wallpaper, color: Colors.white54, size: 18),
              ),
            ),
            const SizedBox(height: 4),
            Text(name, style: TextStyle(fontSize: 9, color: tp.isDarkMode ? Colors.white60 : Colors.grey[600]), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSection(ThemeProvider tp) {
    final sizes = [
      {'label': 'A', 'value': 14.0},
      {'label': 'A', 'value': 16.0},
      {'label': 'A', 'value': 18.0},
      {'label': 'A', 'value': 20.0},
    ];
    final labels = ['Small', 'Medium', 'Large', 'X-Large'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Font Size', trailing: Text('${tp.fontSize.toInt()}px', style: TextStyle(
          color: ZenoColors.primary,
          fontWeight: FontWeight.w600,
        ))),
        Row(
          children: List.generate(sizes.length, (i) {
            final isSelected = tp.fontSize == sizes[i]['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () => tp.setFontSize(sizes[i]['value'] as double),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: i < sizes.length - 1 ? 4 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? ZenoColors.primary : (tp.isDarkMode ? ZenoColors.darkSurface : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? ZenoColors.primary : (tp.isDarkMode ? const Color(0xFF3D3D5C) : const Color(0xFFE0E0E0)),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(sizes[i]['label'] as String, style: TextStyle(
                        fontSize: sizes[i]['value'] as double,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : (tp.isDarkMode ? Colors.white70 : ZenoColors.textPrimary),
                      )),
                      const SizedBox(height: 2),
                      Text(labels[i], style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? Colors.white70 : (tp.isDarkMode ? Colors.white38 : ZenoColors.textSecondary),
                      )),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: ZenoColors.primary,
            inactiveTrackColor: ZenoColors.primary.withOpacity(0.24),
            thumbColor: ZenoColors.primary,
            overlayColor: ZenoColors.primary.withOpacity(0.12),
            valueIndicatorColor: ZenoColors.primary,
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
          ),
          child: Slider(
            value: tp.fontSize,
            min: 12,
            max: 24,
            divisions: 12,
            label: '${tp.fontSize.toInt()}px',
            onChanged: (v) => tp.setFontSize(v),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tp.isDarkMode ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'This is a preview of the selected font size. ChatWave messaging makes communication beautiful.',
            style: TextStyle(fontSize: tp.fontSize, color: tp.isDarkMode ? Colors.white70 : ZenoColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSection(ThemeProvider tp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Advanced'),
        Container(
          decoration: BoxDecoration(
            color: tp.isDarkMode ? ZenoColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tp.isDarkMode ? const Color(0xFF3D3D5C) : const Color(0xFFE0E0E0)),
          ),
          child: Column(
            children: [
              _buildColorPickerTile(tp, 'Status Bar Color', tp.statusBarColor, (c) => tp.setStatusBarColor(c)),
              Divider(height: 1, color: tp.isDarkMode ? const Color(0xFF3D3D5C) : const Color(0xFFE0E0E0), indent: 16, endIndent: 16),
              _buildColorPickerTile(tp, 'Navigation Bar Color', tp.navBarColor, (c) => tp.setNavBarColor(c)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorPickerTile(ThemeProvider tp, String label, Color current, ValueChanged<Color> onPicked) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(
              fontSize: 15,
              color: tp.isDarkMode ? Colors.white : ZenoColors.textPrimary,
            )),
          ),
          GestureDetector(
            onTap: () => _showColorPickerDialog(tp, label, current, onPicked),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: current,
                shape: BoxShape.circle,
                border: Border.all(color: tp.isDarkMode ? const Color(0xFF3D3D5C) : const Color(0xFFE0E0E0), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPickerDialog(ThemeProvider tp, String title, Color current, ValueChanged<Color> onPicked) {
    final colors = [
      ZenoColors.primary, ZenoColors.accent, ZenoColors.accentPink, ZenoColors.accentOrange,
      ZenoColors.accentBlue, const Color(0xFF00B894), const Color(0xFFD63031), const Color(0xFFE17055),
      const Color(0xFF0984E3), const Color(0xFF6D214F), const Color(0xFF2C3E50), const Color(0xFF00FF88),
      const Color(0xFFFF6B6B), const Color(0xFFA29BFE), const Color(0xFF636E72), const Color(0xFFFD79A8),
      Colors.black, Colors.white,
    ];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 300,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: colors.map((c) => GestureDetector(
              onTap: () {
                onPicked(c);
                Navigator.pop(ctx);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: c.value == current.value ? ZenoColors.primary : Colors.grey.shade300,
                    width: c.value == current.value ? 3 : 1,
                  ),
                ),
                child: c.value == current.value
                    ? Icon(Icons.check, color: c.computeLuminance() > 0.5 ? Colors.black : Colors.white, size: 20)
                    : null,
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );
  }

  Widget _buildApplyButton(ThemeProvider tp) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Theme applied successfully!'),
              backgroundColor: ZenoColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ZenoColors.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: ZenoColors.primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text('Apply Theme', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
