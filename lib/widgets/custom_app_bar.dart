import 'package:flutter/material.dart';
import '../theme/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      bottom: bottom,
      backgroundColor: backgroundColor ?? AppColors.primary,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}

class StatusTile extends StatelessWidget {
  final String name;
  final String? photoURL;
  final bool isViewed;
  final String timestamp;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const StatusTile({
    super.key,
    required this.name,
    this.photoURL,
    this.isViewed = false,
    required this.timestamp,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isViewed ? Colors.grey[400]! : AppColors.accent,
            width: 3,
          ),
        ),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey[300],
          backgroundImage: photoURL != null ? NetworkImage(photoURL!) : null,
          child: photoURL == null
              ? Icon(Icons.person, color: Colors.grey[600])
              : null,
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(timestamp, style: TextStyle(color: AppColors.textHint, fontSize: 12)),
    );
  }
}

class CallTile extends StatelessWidget {
  final String name;
  final String? photoURL;
  final String type;
  final String direction;
  final String status;
  final String timestamp;
  final String? duration;
  final VoidCallback onTap;
  final VoidCallback? onVideoCall;

  const CallTile({
    super.key,
    required this.name,
    this.photoURL,
    required this.type,
    required this.direction,
    required this.status,
    required this.timestamp,
    this.duration,
    required this.onTap,
    this.onVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    final isMissed = status == 'missed';
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[300],
        backgroundImage: photoURL != null ? NetworkImage(photoURL!) : null,
        child: photoURL == null ? Icon(Icons.person, color: Colors.grey[600]) : null,
      ),
      title: Text(name, style: TextStyle(
        fontWeight: isMissed ? FontWeight.bold : FontWeight.normal,
      )),
      subtitle: Row(
        children: [
          Icon(
            direction == 'incoming' ? Icons.arrow_downward : Icons.arrow_upward,
            size: 14,
            color: isMissed ? AppColors.callRed : AppColors.callGreen,
          ),
          const SizedBox(width: 4),
          Icon(
            type == 'video' ? Icons.videocam : Icons.phone,
            size: 14,
            color: isMissed ? AppColors.callRed : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            isMissed ? 'Missed' : (duration ?? timestamp),
            style: TextStyle(
              fontSize: 12,
              color: isMissed ? AppColors.callRed : AppColors.textHint,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          type == 'video' ? Icons.videocam : Icons.phone,
          color: AppColors.accent,
        ),
        onPressed: onTap,
      ),
    );
  }
}
