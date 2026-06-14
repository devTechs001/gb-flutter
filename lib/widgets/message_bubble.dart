import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/message_model.dart';
import '../theme/colors.dart';
import '../providers/theme_provider.dart';
import '../utils/helpers.dart';
import '../providers/chat_provider.dart';
import '../services/translation_service.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isMe;
  final bool showSenderName;
  final VoidCallback? onReply;
  final VoidCallback? onReact;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showSenderName = false,
    this.onReply,
    this.onReact,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _reactionController;
  late Animation<double> _reactionScale;
  bool _showReactions = false;

  bool _expanded = false;
  static const List<String> _quickReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

  @override
  void initState() {
    super.initState();
    _reactionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _reactionScale = CurvedAnimation(
      parent: _reactionController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _reactionController.dispose();
    super.dispose();
  }

  void _toggleReactions() {
    setState(() {
      _showReactions = !_showReactions;
      if (_showReactions) {
        _reactionController.forward();
      } else {
        _reactionController.reverse();
      }
    });
  }

  void _showMessageActions() {
    final theme = context.read<ThemeProvider>();
    final isDark = theme.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(ctx);
                Share.share(widget.message.content);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(ctx);
                Clipboard.setData(ClipboardData(text: widget.message.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.reply_rounded, color: theme.accentColor),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onReply?.call();
              },
            ),
            ListTile(
              leading: Icon(Icons.auto_awesome, color: Colors.amber),
              title: const Text('Translate'),
              subtitle: const Text('Translate this message'),
              onTap: () {
                Navigator.pop(ctx);
                _showTranslateMessage();
              },
            ),
            ListTile(
              leading: Icon(widget.message.isStarred ? Icons.star : Icons.star_border, color: Colors.amber),
              title: Text(widget.message.isStarred ? 'Unstar' : 'Star'),
              onTap: () {
                Navigator.pop(ctx);
                final chatProvider = context.read<ChatProvider>();
                chatProvider.starMessage(widget.message.chatId, widget.message.messageId, !widget.message.isStarred);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_outline, color: Colors.indigo),
              title: const Text('Save'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message saved'), duration: Duration(seconds: 1)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined, color: Colors.teal),
              title: const Text('Media'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Media details'), duration: Duration(seconds: 1)),
                );
              },
            ),
            if (widget.isMe)
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditDialog();
                },
              ),
            if (widget.isMe)
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showTranslateMessage() {
    final theme = context.read<ThemeProvider>();
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 4,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Translate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A3E) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(widget.message.content, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.5,
                  ),
                  itemCount: TranslationService.languages.length,
                  itemBuilder: (ctx, i) {
                    final lang = TranslationService.languages[i];
                    return GestureDetector(
                      onTap: () {
                        final translated = TranslationService.translate(widget.message.content, lang['code']!);
                        Navigator.pop(ctx);
                        showDialog(
                          context: context,
                          builder: (dCtx) => AlertDialog(
                            title: Text('${lang['name']} Translation'),
                            content: Text(translated),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Close')),
                              TextButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: translated));
                                  Navigator.pop(dCtx);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
                                },
                                child: const Text('Copy'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: accent.withValues(alpha: 0.2)),
                        ),
                        child: Center(child: Text(lang['name']!, style: TextStyle(color: accent, fontWeight: FontWeight.w500, fontSize: 13))),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog() {
    final controller = TextEditingController(text: widget.message.content);
    final theme = context.read<ThemeProvider>();
    final isDark = theme.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E32) : null,
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Edit your message...',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message updated')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final accent = theme.accentColor;
    final bubble = theme.bubbleColor;
    final isDark = theme.isDarkMode;

    if (widget.message.deleted) {
      return _buildDeletedMessage(isDark);
    }

    return Column(
      crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (widget.showSenderName && !widget.isMe)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4, bottom: 2),
            child: Text(
              widget.message.senderName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),
        if (widget.message.isForwarded) _buildForwardedLabel(accent, isDark),
        if (widget.message.replyTo != null && widget.message.replyTo!.isNotEmpty)
          _buildReplyPreview(accent, isDark),
        GestureDetector(
          onLongPress: _toggleReactions,
          onTap: _showMessageActions,
          child: Row(
            mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!widget.isMe)
                Padding(
                  padding: const EdgeInsets.only(right: 4, bottom: 8),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Helpers.generateAvatarColor(widget.message.senderName),
                    backgroundImage: widget.message.senderPhotoURL != null
                        ? CachedNetworkImageProvider(widget.message.senderPhotoURL!)
                        : null,
                    child: widget.message.senderPhotoURL == null
                        ? Text(
                            Helpers.getInitials(widget.message.senderName),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          )
                        : null,
                  ),
                ),
              Flexible(
                child: Column(
                  crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: widget.isMe ? bubble : (isDark ? const Color(0xFF1E1E32) : AppColors.messageReceived),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(widget.isMe ? 18 : 4),
                          bottomRight: Radius.circular(widget.isMe ? 4 : 18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isMe ? bubble : (isDark ? Colors.black : Colors.grey))
                                .withValues(alpha: isDark ? 0.2 : 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.message.type == 'text')
                            _buildTextContent(context, accent, isDark)
                          else if (widget.message.isMedia)
                            _buildMediaContent(accent, isDark)
                          else if (widget.message.isLocation)
                            _buildLocationContent(isDark)
                          else if (widget.message.isVoice)
                            _buildVoiceContent(accent, isDark)
                          else if (widget.message.isPoll)
                            _buildPollContent(accent, isDark)
                          else
                            _buildTextContent(context, accent, isDark),
                          if (widget.message.edited)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'edited',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: widget.isMe
                                      ? Colors.white.withValues(alpha: 0.6)
                                      : (isDark ? Colors.white38 : AppColors.textHint),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('HH:mm').format(widget.message.timestamp),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.isMe
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : (isDark ? Colors.white38 : AppColors.textHint),
                                ),
                              ),
                              if (widget.isMe) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  _getStatusIcon,
                                  size: 14,
                                  color: _getStatusColor(accent).withValues(alpha: 0.8),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (widget.message.reactions.isNotEmpty || _showReactions)
                      _buildReactionsBar(accent, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent(BuildContext context, Color accent, bool isDark) {
    final text = widget.message.content;
    const int maxLen = 200;
    final isLong = text.length > maxLen;
    final shown = isLong && !_expanded ? '${text.substring(0, maxLen)}...' : text;
    final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
    final hasLink = urlRegex.hasMatch(text);

    if (hasLink && widget.message.linkPreviewUrl != null) {
      return _buildLinkPreview(text, isDark);
    }

    if (widget.message.isPoll) {
      return _buildPollContent(accent, isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SelectionArea(
          child: Text(
            shown,
            style: TextStyle(
              fontSize: 15,
              height: 1.3,
              color: widget.isMe ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
        if (isLong)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _expanded ? 'Show less' : 'Read more',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.isMe ? Colors.white70 : accent,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLinkPreview(String text, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectionArea(
          child: Text(
            text.replaceAll(RegExp(r'https?:\/\/[^\s]+'), '').trim(),
            style: TextStyle(
              fontSize: 15,
              height: 1.3,
              color: widget.isMe ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.message.linkPreviewImage != null)
                CachedNetworkImage(
                  imageUrl: widget.message.linkPreviewImage!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    height: 80,
                    color: Colors.grey[100],
                    child: const Icon(Icons.link, color: Colors.grey),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.message.linkPreviewTitle != null)
                      Text(
                        widget.message.linkPreviewTitle!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (widget.message.linkPreviewDescription != null)
                      Text(
                        widget.message.linkPreviewDescription!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (widget.message.linkPreviewUrl != null)
                      Text(
                        widget.message.linkPreviewUrl!,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white30 : Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceContent(Color accent, bool isDark) {
    final duration = widget.message.duration ?? 0;
    final waveform = widget.message.waveform ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (widget.isMe ? Colors.white : accent).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                size: 20,
                color: widget.isMe ? Colors.white : accent,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              height: 30,
              child: CustomPaint(
                painter: _WaveformPainter(
                  waveform: waveform.isEmpty
                      ? List.generate(20, (i) => sin(i * 0.5) * 0.5 + 0.5)
                      : waveform,
                  color: widget.isMe
                      ? Colors.white.withValues(alpha: 0.8)
                      : accent.withValues(alpha: 0.8),
                  playedPercent: 0,
                  accentColor: accent,
                ),
              ),
            ),
          ],
        ),
        Text(
          Helpers.formatDuration(duration.toInt()),
          style: TextStyle(
            fontSize: 11,
            color: widget.isMe ? Colors.white.withValues(alpha: 0.7) : (isDark ? Colors.white38 : AppColors.textHint),
          ),
        ),
      ],
    );
  }

  Widget _buildPollContent(Color accent, bool isDark) {
    final options = widget.message.pollOptions ?? [];
    final votes = widget.message.pollVotes ?? {};
    final totalVotes = votes.values.fold<int>(0, (sum, list) => sum + list.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.message.pollQuestion ?? 'Poll',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: widget.isMe ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
        ),
        const SizedBox(height: 8),
        ...options.asMap().entries.map((entry) {
          final option = entry.value['text'] as String? ?? '';
          final optionVotes = votes[option]?.length ?? 0;
          final percent = totalVotes > 0 ? (optionVotes / totalVotes * 100) : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (widget.isMe ? Colors.white : accent).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (widget.isMe ? Colors.white : accent).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    if (totalVotes > 0) ...[
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.withValues(alpha: 0.1),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: percent / 100,
                              child: Container(
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: accent.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  option,
                                  style: TextStyle(fontSize: 13, color: widget.isMe ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${percent.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isMe ? Colors.white.withValues(alpha: 0.8) : (isDark ? Colors.white38 : AppColors.textHint),
                        ),
                      ),
                    ] else
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(fontSize: 13, color: widget.isMe ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
        Text(
          '$totalVotes votes',
          style: TextStyle(
            fontSize: 11,
            color: widget.isMe ? Colors.white.withValues(alpha: 0.7) : (isDark ? Colors.white38 : AppColors.textHint),
          ),
        ),
      ],
    );
  }

  Widget _buildForwardedLabel(Color accent, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.redo,
            size: 14,
            color: widget.isMe ? Colors.white.withValues(alpha: 0.7) : (isDark ? Colors.white38 : AppColors.textHint),
          ),
          const SizedBox(width: 4),
          Text(
            'Forwarded${widget.message.forwardedFrom != null ? ' from ${widget.message.forwardedFrom}' : ''}',
            style: TextStyle(
              fontSize: 11,
              color: widget.isMe ? Colors.white.withValues(alpha: 0.7) : (isDark ? Colors.white38 : AppColors.textHint),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeletedMessage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.grey).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, size: 16, color: isDark ? Colors.white38 : Colors.grey[500]),
                  const SizedBox(width: 8),
                  Text(
                    'This message was deleted',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Message restored'), duration: Duration(seconds: 1)),
                      );
                    },
                    child: Text(
                      'Restore',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.blue[300] : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(Color accent, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (widget.isMe ? Colors.white : (isDark ? Colors.white : accent)).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: widget.isMe ? Colors.white.withValues(alpha: 0.7) : accent,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message.replySender ?? 'Reply',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: widget.isMe ? Colors.white.withValues(alpha: 0.7) : accent,
            ),
          ),
          Text(
            widget.message.replyContent ?? widget.message.replyTo ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: widget.isMe ? Colors.white.withValues(alpha: 0.6) : (isDark ? Colors.white54 : Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(Color accent, bool isDark) {
    if (widget.message.type == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onTap: () => _showMediaViewer(context),
          child: CachedNetworkImage(
            imageUrl: widget.message.mediaURL ?? '',
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
        ),
      );
    }
    if (widget.message.type == 'video') {
      return GestureDetector(
        onTap: () {},
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.message.thumbnailURL != null)
                CachedNetworkImage(
                  imageUrl: widget.message.thumbnailURL!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow, color: accent, size: 36),
              ),
            ],
          ),
        ),
      );
    }
    if (widget.message.type == 'audio') {
      return _buildVoiceContent(accent, isDark);
    }
    if (widget.message.type == 'document') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (widget.isMe ? Colors.white : accent).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.description,
                color: widget.isMe ? Colors.white : accent,
                size: 28,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.message.fileName ?? 'Document',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: widget.isMe ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.message.fileSize != null)
                    Text(
                      Helpers.formatFileSize(widget.message.fileSize!),
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.isMe ? Colors.white.withValues(alpha: 0.7) : (isDark ? Colors.white38 : AppColors.textHint),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.download,
              color: widget.isMe ? Colors.white.withValues(alpha: 0.8) : accent,
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLocationContent(bool isDark) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 40, color: AppColors.callRed.withValues(alpha: 0.7)),
            const SizedBox(height: 8),
            Text('📍 Location', style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionsBar(Color accent, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E1E32) : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (widget.message.reactions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.message.reactions.map((r) {
                  final count = _getReactionCount(r['reaction'] ?? '');
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      '${r['reaction'] ?? ''}${count > 1 ? ' $count' : ''}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ),
          if (_showReactions)
            ScaleTransition(
              scale: _reactionScale,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _quickReactions.map((emoji) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => _showReactions = false);
                        widget.onReact?.call();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: const TextStyle(fontSize: 24),
                          child: Text(emoji),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _getReactionCount(String reaction) {
    return widget.message.reactions.where((r) => r['reaction'] == reaction).length;
  }

  void _showMediaViewer(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: widget.message.mediaURL ?? '',
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _getStatusIcon {
    if (widget.message.readBy.isNotEmpty) return Icons.done_all;
    if (widget.message.deliveredTo.isNotEmpty) return Icons.done_all;
    return Icons.check;
  }

  Color _getStatusColor(Color accent) {
    if (widget.message.readBy.isNotEmpty) return AppColors.online;
    if (widget.message.deliveredTo.isNotEmpty) return accent;
    return Colors.white.withValues(alpha: 0.5);
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> waveform;
  final Color color;
  final double playedPercent;
  final Color accentColor;

  _WaveformPainter({
    required this.waveform,
    required this.color,
    this.playedPercent = 0,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    final barWidth = size.width / waveform.length;
    final middle = size.height / 2;

    for (int i = 0; i < waveform.length; i++) {
      final amplitude = waveform[i].clamp(0.0, 1.0);
      final barHeight = amplitude * size.height * 0.8;
      final x = i * barWidth + barWidth * 0.2;

      if (i / waveform.length <= playedPercent) {
        paint.color = accentColor;
      } else {
        paint.color = color;
      }

      canvas.drawLine(
        Offset(x, middle - barHeight / 2),
        Offset(x, middle + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.playedPercent != playedPercent || oldDelegate.waveform != waveform;
}
