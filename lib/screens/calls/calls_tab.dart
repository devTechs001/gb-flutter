import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/call_model.dart';
import '../../providers/call_provider.dart';
import '../../theme/colors.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';

class CallsTab extends StatelessWidget {
  const CallsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CallProvider>(
      builder: (context, callProvider, _) {
        final calls = callProvider.calls;

        return Scaffold(
          body: calls.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone_callback_outlined,
                        size: 80,
                        color: AppColors.textHint.withOpacity(0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No calls',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your call history will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: calls.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    indent: 80,
                    color: AppColors.divider,
                  ),
                  itemBuilder: (context, index) {
                    final call = calls[index];
                    return _CallTile(call: call);
                  },
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.accent,
            onPressed: () {
              Navigator.pushNamed(context, '/new-call');
            },
            child: const Icon(Icons.phone_rounded, color: Colors.white),
          ),
        );
      },
    );
  }
}

class _CallTile extends StatelessWidget {
  final CallModel call;

  const _CallTile({required this.call});

  IconData get _directionIcon {
    switch (call.direction) {
      case Constants.callDirectionIncoming:
        return Icons.call_received_rounded;
      case Constants.callDirectionOutgoing:
        return Icons.call_made_rounded;
      default:
        return Icons.call_received_rounded;
    }
  }

  IconData get _typeIcon {
    switch (call.type) {
      case Constants.callTypeAudio:
        return Icons.phone_rounded;
      case Constants.callTypeVideo:
        return Icons.videocam_rounded;
      default:
        return Icons.phone_rounded;
    }
  }

  Color? get _callStatusColor {
    if (call.status == Constants.callStatusMissed) {
      return AppColors.callRed;
    }
    return null;
  }

  String get _callStatusLabel {
    switch (call.status) {
      case Constants.callStatusMissed:
        return 'Missed';
      case Constants.callStatusAnswered:
        return 'Answered';
      case Constants.callStatusEnded:
        return 'Ended';
      default:
        return call.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMissed = call.status == Constants.callStatusMissed;
    final displayName = call.direction == Constants.callDirectionIncoming
        ? call.callerName
        : call.receiverName;
    final displayPhoto = call.direction == Constants.callDirectionIncoming
        ? call.callerPhoto
        : call.receiverPhoto;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/call', arguments: call);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: displayPhoto != null
                      ? NetworkImage(displayPhoto)
                      : null,
                  backgroundColor: Helpers.generateAvatarColor(displayName),
                  child: displayPhoto == null
                      ? Text(
                          Helpers.getInitials(displayName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isMissed ? AppColors.callRed : AppColors.callGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      _typeIcon,
                      size: 12,
                      color: Colors.white,
                    ),
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
                    displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isMissed ? FontWeight.w600 : FontWeight.w400,
                      color: isMissed ? AppColors.callRed : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        _directionIcon,
                        size: 14,
                        color: isMissed ? AppColors.callRed : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isMissed ? _callStatusLabel : _callStatusLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: isMissed ? AppColors.callRed : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Helpers.formatTime(call.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: isMissed ? AppColors.callRed : AppColors.textHint,
                  ),
                ),
                if (call.duration > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      call.durationFormatted,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
