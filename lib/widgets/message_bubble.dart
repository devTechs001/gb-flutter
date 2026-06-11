import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/message_model.dart';
import '../../theme/colors.dart';
import '../../utils/helpers.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showSenderName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showSenderName = false,
  });

  @override
  Widget build(BuildContext context) {
    if (message.deleted) {
      return _buildDeletedMessage();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showSenderName && !isMe)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4, bottom: 2),
              child: Text(
                message.senderName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentLight,
                ),
              ),
            ),
          if (message.replyTo != null && message.replyTo!.isNotEmpty)
            _buildReplyPreview(),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Helpers.generateAvatarColor(message.senderName),
                    backgroundImage: message.senderPhotoURL != null
                        ? CachedNetworkImageProvider(message.senderPhotoURL!)
                        : null,
                    child: message.senderPhotoURL == null
                        ? Text(
                            Helpers.getInitials(message.senderName),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          )
                        : null,
                  ),
                ),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.messageSent : AppColors.messageReceived,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isMe ? 12 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.isForwarded)
                        Row(
                          children: [
                            const Icon(Icons.redo, size: 14, color: AppColors.textHint),
                            const SizedBox(width: 4),
                            Text(
                              'Forwarded',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      if (message.isLocation)
                        _buildLocationContent()
                      else if (message.isMedia)
                        _buildMediaContent()
                      else
                        Text(
                          message.content,
                          style: const TextStyle(fontSize: 15),
                        ),
                      if (message.edited)
                        Text(
                          'edited',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textHint,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('HH:mm').format(message.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              _getStatusIcon,
                              size: 14,
                              color: _getStatusColor,
                            ),
                          ],
                        ],
                      ),
                      if (message.reactions.isNotEmpty)
                        _buildReactions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeletedMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 8),
                  Text(
                    'This message was deleted',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500],
                    fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (isMe ? Colors.white : AppColors.primaryLight).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isMe ? AppColors.accent : AppColors.accentLight,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reply',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isMe ? AppColors.accent : AppColors.accentLight,
            ),
          ),
          Text(
            message.replyTo ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    if (message.type == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: message.mediaURL ?? '',
          placeholder: (_, __) => Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (_, __, ___) => Container(
            height: 200,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image),
          ),
          fit: BoxFit.cover,
        ),
      );
    }
    if (message.type == 'video') {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (message.thumbnailURL != null)
              CachedNetworkImage(imageUrl: message.thumbnailURL!, fit: BoxFit.cover),
            const Icon(Icons.play_circle_fill, size: 50, color: Colors.white),
          ],
        ),
      );
    }
    if (message.type == 'audio') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.play_circle_filled, color: AppColors.accent, size: 32),
            const SizedBox(width: 8),
            Expanded(
              child: LinearProgressIndicator(value: 0, color: AppColors.accent),
            ),
            const SizedBox(width: 8),
            Text(
              Helpers.formatDuration(message.duration?.toInt() ?? 0),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }
    if (message.type == 'document') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.description, color: AppColors.accentLight, size: 32),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.fileName ?? 'Document',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (message.fileSize != null)
                    Text(
                      Helpers.formatFileSize(message.fileSize!),
                      style: TextStyle(fontSize: 11, color: AppColors.textHint),
                    ),
                ],
              ),
            ),
            const Icon(Icons.download, color: AppColors.accentLight),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLocationContent() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 40, color: AppColors.callRed),
            SizedBox(height: 8),
            Text('📍 Location', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildReactions() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: message.reactions.map((r) {
          return Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Text(r['reaction'] ?? '', style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
      ),
    );
  }

  IconData get _getStatusIcon {
    if (message.readBy.isNotEmpty) return Icons.done_all;
    if (message.deliveredTo.isNotEmpty) return Icons.done_all;
    return Icons.done;
  }

  Color get _getStatusColor {
    if (message.readBy.isNotEmpty) return AppColors.accentLight;
    if (message.deliveredTo.isNotEmpty) return AppColors.textHint;
    return AppColors.textHint;
  }
}
