import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/status_model.dart';
import '../../providers/status_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../utils/helpers.dart';
import 'status_viewer_screen.dart';

class StatusTab extends StatelessWidget {
  const StatusTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<StatusProvider, AuthProvider>(
      builder: (context, statusProvider, authProvider, _) {
        final statuses = statusProvider.statuses;
        final currentUserId = authProvider.userId;
        final unviewedStatuses = statuses.where((s) {
          return s.userId != currentUserId &&
              !s.viewers.any((v) => v['userId'] == currentUserId);
        }).toList();
        final viewedStatuses = statuses.where((s) {
          return s.userId != currentUserId &&
              s.viewers.any((v) => v['userId'] == currentUserId);
        }).toList();
        final myStatuses = statuses.where((s) => s.userId == currentUserId).toList();

        return Scaffold(
          body: statuses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        size: 80,
                        color: AppColors.textHint.withOpacity(0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No status updates',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the camera button to share\nyour first status',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    _MyStatusTile(myStatuses: myStatuses),
                    if (unviewedStatuses.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Text(
                          'Recent updates',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      ...unviewedStatuses.map((s) => _StatusTile(status: s)),
                    ],
                    if (viewedStatuses.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          'Viewed updates',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      ...viewedStatuses.map((s) => _StatusTile(status: s)),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                mini: true,
                heroTag: 'camera',
                backgroundColor: AppColors.textSecondary,
                onPressed: () {
                  // Open camera
                },
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'add_status',
                backgroundColor: AppColors.accent,
                onPressed: () {
                  Navigator.pushNamed(context, '/create-status');
                },
                child: const Icon(Icons.edit_rounded, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MyStatusTile extends StatelessWidget {
  final List<StatusModel> myStatuses;

  const _MyStatusTile({required this.myStatuses});

  @override
  Widget build(BuildContext context) {
    final hasStatus = myStatuses.isNotEmpty;

    return InkWell(
      onTap: () {
        if (hasStatus) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StatusViewerScreen(
                statuses: myStatuses,
                initialIndex: 0,
              ),
            ),
          );
        } else {
          Navigator.pushNamed(context, '/create-status');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.accent,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundImage: null,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      'M',
                      style: TextStyle(
                        fontSize: 22,
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: const Icon(Icons.add, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasStatus ? 'Tap to view status' : 'Tap to add status update',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            if (hasStatus)
              Text(
                Helpers.formatTime(myStatuses.first.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final StatusModel status;

  const _StatusTile({required this.status});

  @override
  Widget build(BuildContext context) {
    final isUnviewed = status.viewers.isEmpty;
    final avatarColor = Helpers.generateAvatarColor(status.userName);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StatusViewerScreen(
              statuses: [status],
              initialIndex: 0,
            ),
          ),
        );
      },
      onLongPress: () => _showOptions(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: isUnviewed ? AppColors.accent : Colors.grey[300],
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: status.userPhoto != null
                        ? NetworkImage(status.userPhoto!)
                        : null,
                    backgroundColor: avatarColor,
                    child: status.userPhoto == null
                        ? Text(
                            Helpers.getInitials(status.userName),
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isUnviewed ? FontWeight.w600 : FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status.caption.isNotEmpty ? status.caption : Helpers.formatTime(status.timestamp),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textHint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              Helpers.formatTime(status.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications_off_outlined),
              title: const Text('Mute'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status muted')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.callRed),
              title: const Text('Delete', style: TextStyle(color: AppColors.callRed)),
              onTap: () {
                context.read<StatusProvider>().deleteStatus(status.statusId);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
