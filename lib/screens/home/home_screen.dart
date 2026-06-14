import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/call_provider.dart';
import '../../providers/status_provider.dart';
import '../drawer/zeno_drawer.dart';
import '../chat/chats_tab.dart';
import '../status/status_tab.dart';
import '../calls/calls_tab.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabController;

  final _navigatorKeys = List.generate(4, (_) => GlobalKey<NavigatorState>());

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // FAB animation available for status tab
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    }
    setState(() => _selectedIndex = index);
    if (index == 1) {
      _fabController.forward();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _fabController.reverse();
      });
    }
  }

  void _pushInCurrentTab(Widget screen) {
    _navigatorKeys[_selectedIndex].currentState?.push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget _buildTab(int index, Widget child) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => child,
          settings: settings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final accent = themeProvider.accentColor;
    final chatProvider = context.watch<ChatProvider>();
    final auth = context.watch<AuthProvider>();
    final callProvider = context.watch<CallProvider>();
    final statusProvider = context.watch<StatusProvider>();
    final totalUnread = chatProvider.chats.fold<int>(
      0, (sum, c) => sum + (c.unreadCount[auth.userId] ?? 0),
    );
    final missedCalls = callProvider.calls.where((c) => c.status == 'missed' && c.direction == 'incoming').length;
    final unseenStatuses = statusProvider.statuses.where((s) => s.userId != auth.userId && !s.viewers.any((v) => v['userId'] == auth.userId)).length;

    return Scaffold(
      drawer: ZenoDrawer(onNavigate: _pushInCurrentTab),
      body: Stack(
        children: [
          _buildTab(0, const ChatsTab()),
          _buildTab(1, const StatusTab()),
          _buildTab(2, const CallsTab()),
          _buildTab(3, const SettingsScreen()),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: isDark
                ? ColorFilter.mode(Colors.black.withValues(alpha: 0.1), BlendMode.srcOver)
                : ColorFilter.mode(Colors.white.withValues(alpha: 0.1), BlendMode.srcOver),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: accent,
              unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[600],
              backgroundColor: isDark
                  ? const Color(0xFF1A1A2E).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              elevation: 0,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              items: [
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: totalUnread > 0,
                    label: Text(
                      totalUnread > 99 ? '99+' : '$totalUnread',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    child: const Icon(Icons.chat_bubble_outline_rounded),
                  ),
                  activeIcon: Badge(
                    isLabelVisible: totalUnread > 0,
                    label: Text(
                      totalUnread > 99 ? '99+' : '$totalUnread',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    child: const Icon(Icons.chat_bubble_rounded),
                  ),
                  label: 'Chats',
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: unseenStatuses > 0,
                    label: Text('$unseenStatuses', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    child: const Icon(Icons.circle_outlined),
                  ),
                  activeIcon: Badge(
                    isLabelVisible: unseenStatuses > 0,
                    label: Text('$unseenStatuses', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    child: const Icon(Icons.circle_rounded),
                  ),
                  label: 'Status',
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: missedCalls > 0,
                    label: Text('$missedCalls', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    child: const Icon(Icons.phone_outlined),
                  ),
                  activeIcon: Badge(
                    isLabelVisible: missedCalls > 0,
                    label: Text('$missedCalls', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    child: const Icon(Icons.phone_rounded),
                  ),
                  label: 'Calls',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.tune_rounded),
                  activeIcon: const Icon(Icons.tune_rounded),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
