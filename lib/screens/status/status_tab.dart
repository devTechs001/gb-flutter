import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/status_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/status_model.dart';
import '../../theme/colors.dart';
import '../../utils/helpers.dart';
import 'status_viewer_screen.dart';
import 'status_screen.dart';

class StatusTab extends StatelessWidget {
  const StatusTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;
    return Consumer2<StatusProvider, AuthProvider>(
      builder: (context, statusProvider, auth, _) {
        final statuses = statusProvider.statuses;
        final myStatuses = statuses.where((s) => s.userId == auth.userId).toList();
        final otherStatuses = statuses.where((s) => s.userId != auth.userId).toList();
        final unseenCount = otherStatuses.where(
          (s) => !s.viewers.any((v) => v['userId'] == auth.userId),
        ).length;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(
                height: 78,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  itemCount: 1 + otherStatuses.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildMyStory(context, myStatuses.isNotEmpty, isDark, theme);
                    }
                    final s = otherStatuses[index - 1];
                    final viewed = s.viewers.any((v) => v['userId'] == auth.userId);
                    return _buildStoryCircle(
                      context,
                      name: s.userName,
                      color: Helpers.generateAvatarColor(s.userName),
                      viewed: viewed,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => StatusViewerScreen(statuses: [s], initialIndex: 0),
                        ));
                      },
                    );
                  },
                ),
              )),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
                child: Row(
                  children: [
                    Text('RECENT UPDATES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? Colors.white38 : Colors.grey[500], letterSpacing: 1)),
                    if (unseenCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
                        child: Text('$unseenCount new', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              )),
              if (otherStatuses.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accent.withValues(alpha: 0.1),
                            ),
                            child: Icon(Icons.circle_rounded, size: 32, color: AppColors.accent.withValues(alpha: 0.4)),
                          ),
                          const SizedBox(height: 12),
                          const Text('No recent updates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          const Text('Contacts will appear here when they post', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final s = otherStatuses[index];
                      final viewed = s.viewers.any((v) => v['userId'] == auth.userId);
                      return _buildStatusTile(context, s, viewed, auth.userId);
                    },
                    childCount: otherStatuses.length,
                  ),
                ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.small(
                heroTag: 'status_text',
                backgroundColor: AppColors.textSecondary,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatusScreen())),
                child: const Icon(Icons.edit_rounded, color: Colors.white),
              ),
              const SizedBox(height: 6),
              FloatingActionButton(
                heroTag: 'status_camera',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatusScreen())),
                backgroundColor: AppColors.accent,
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyStory(BuildContext context, bool hasStatus, bool isDark, ThemeProvider theme) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatusScreen())),
      child: Container(
        width: 64,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasStatus
                        ? const LinearGradient(colors: [AppColors.accent, AppColors.primary])
                        : null,
                    color: hasStatus ? null : Colors.grey[300],
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.add, size: 10, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Text('My Status', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.black87), overflow: TextOverflow.ellipsis, maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCircle(BuildContext context, {required String name, required Color color, required bool viewed, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: viewed
                    ? LinearGradient(colors: [Colors.grey[400]!, Colors.grey[300]!])
                    : const LinearGradient(colors: [AppColors.accent, AppColors.primary]),
              ),
              padding: const EdgeInsets.all(2.5),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: color,
                child: Text(Helpers.getInitials(name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 1),
            Text(name, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis, maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTile(BuildContext context, StatusModel s, bool viewed, String userId) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;
    return ListTile(
      leading: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: viewed
              ? LinearGradient(colors: [Colors.grey[400]!, Colors.grey[300]!])
              : const LinearGradient(colors: [AppColors.accent, AppColors.primary]),
        ),
        padding: const EdgeInsets.all(3),
        child: CircleAvatar(
          radius: 23,
          backgroundColor: Helpers.generateAvatarColor(s.userName),
          child: Text(Helpers.getInitials(s.userName), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      title: Text(s.userName, style: TextStyle(fontWeight: FontWeight.w600, color: viewed ? (isDark ? Colors.white54 : Colors.grey) : (isDark ? Colors.white : Colors.black87))),
      subtitle: Text(
        s.caption.isNotEmpty ? s.caption : 'No caption',
        style: TextStyle(color: isDark ? Colors.white38 : AppColors.textHint, fontSize: 12),
      ),
      trailing: Text(
        Helpers.formatTime(s.timestamp),
        style: TextStyle(fontSize: 11, color: isDark ? Colors.white24 : Colors.grey[400]),
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => StatusViewerScreen(statuses: [s], initialIndex: 0),
        ));
      },
    );
  }
}
