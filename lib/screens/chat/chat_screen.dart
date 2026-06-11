import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../utils/helpers.dart';
import '../../widgets/message_bubble.dart';
import '../../services/media_service.dart';
import '../status/status_screen.dart';
import '../profile/profile_screen.dart';
import 'group_info_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  bool _isEmojiVisible = false;
  bool _isRecording = false;
  bool _showScrollButton = false;
  String? _replyToMessageId;
  String? _replyToContent;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<ChatProvider>().loadMessages(widget.chat.chatId);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.position.pixels > 500;
    if (show != _showScrollButton) {
      setState(() => _showScrollButton = show);
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onTyping() {
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {});
  }

  Future<void> _pickMedia(ImageSource source) async {
    final xFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (xFile != null) {
      _sendMediaMessage(File(xFile.path), 'image');
    }
  }

  Future<void> _sendMediaMessage(File file, String type) async {
    final auth = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final url = await chatProvider.chatService.uploadMedia(
      file.path,
      '${type == 'image' ? 'chat_images' : 'chat_videos'}/${widget.chat.chatId}/${DateTime.now().millisecondsSinceEpoch}',
    );
    if (url != null) {
      await chatProvider.sendMessage(
        chatId: widget.chat.chatId,
        senderId: auth.userId,
        senderName: auth.userModel?.displayName ?? 'User',
        type: type,
        content: '',
        mediaURL: url,
        replyTo: _replyToMessageId,
      );
      _cancelReply();
    }
  }

  void _sendTextMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    context.read<ChatProvider>().sendMessage(
          chatId: widget.chat.chatId,
          senderId: auth.userId,
          senderName: auth.userModel?.displayName ?? 'User',
          type: 'text',
          content: text,
          replyTo: _replyToMessageId,
        );

    _messageController.clear();
    _cancelReply();
  }

  void _cancelReply() {
    setState(() {
      _replyToMessageId = null;
      _replyToContent = null;
    });
  }

  void _showEmojiPicker() {
    setState(() => _isEmojiVisible = !_isEmojiVisible);
    if (_isEmojiVisible) _focusNode.unfocus();
  }

  Future<void> _pickDocument() async {
    final mediaService = MediaService();
    final file = await mediaService.pickDocument();
    if (file != null) {
      final auth = context.read<AuthProvider>();
      final chatProvider = context.read<ChatProvider>();
      final url = await chatProvider.chatService.uploadMedia(
        file.path!,
        'chat_documents/${widget.chat.chatId}/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
      );
      if (url != null) {
        await chatProvider.sendMessage(
          chatId: widget.chat.chatId,
          senderId: auth.userId,
          senderName: auth.userModel?.displayName ?? 'User',
          type: 'document',
          content: '',
          mediaURL: url,
          fileName: file.name,
          fileSize: file.size,
          replyTo: _replyToMessageId,
        );
        _cancelReply();
      }
    }
  }

  Future<void> _shareLocation() async {
    final auth = context.read<AuthProvider>();
    await context.read<ChatProvider>().sendMessage(
          chatId: widget.chat.chatId,
          senderId: auth.userId,
          senderName: auth.userModel?.displayName ?? 'User',
          type: 'location',
          content: '📍 Location',
          latitude: 0.0,
          longitude: 0.0,
        );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _attachmentButton(Icons.camera_alt, 'Camera', AppColors.notificationRed, () {
                    Navigator.pop(context);
                    _pickMedia(ImageSource.camera);
                  }),
                  _attachmentButton(Icons.photo_library, 'Gallery', AppColors.accentLight, () {
                    Navigator.pop(context);
                    _pickMedia(ImageSource.gallery);
                  }),
                  _attachmentButton(Icons.description, 'Document', AppColors.primaryLight, () {
                    Navigator.pop(context);
                    _pickDocument();
                  }),
                  _attachmentButton(Icons.location_on, 'Location', AppColors.callGreen, () {
                    Navigator.pop(context);
                    _shareLocation();
                  }),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _attachmentButton(Icons.headset_mic, 'Audio', Colors.purple, () {
                    Navigator.pop(context);
                    // Voice call
                  }),
                  _attachmentButton(Icons.videocam, 'Video', Colors.indigo, () {
                    Navigator.pop(context);
                    // Video call
                  }),
                  _attachmentButton(Icons.contact_phone, 'Contact', Colors.teal, () {
                    Navigator.pop(context);
                    // Share contact
                  }),
                  _attachmentButton(Icons.poll, 'Poll', Colors.amber, () {
                    Navigator.pop(context);
                  }),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachmentButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final messages = chatProvider.messages;
    final otherUser = auth.userModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () {
            if (widget.chat.isGroup) {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => GroupInfoScreen(chat: widget.chat),
              ));
            } else {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ));
            }
          },
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Helpers.generateAvatarColor(
                      widget.chat.displayName.isNotEmpty
                          ? widget.chat.displayName
                          : (otherUser?.displayName ?? 'U'),
                    ),
                    backgroundImage: widget.chat.displayPhoto.isNotEmpty
                        ? CachedNetworkImageProvider(widget.chat.displayPhoto)
                        : (otherUser?.photoURL != null
                            ? CachedNetworkImageProvider(otherUser!.photoURL!)
                            : null),
                    child: (widget.chat.displayPhoto.isEmpty && (otherUser?.photoURL == null))
                        ? Text(
                            Helpers.getInitials(widget.chat.displayName.isNotEmpty
                                ? widget.chat.displayName
                                : (otherUser?.displayName ?? 'U')),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  if (otherUser?.isOnline == true)
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 12, height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.online,
                          border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.chat.displayName.isNotEmpty
                          ? widget.chat.displayName
                          : (otherUser?.displayName ?? 'User'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      otherUser?.isOnline == true ? 'online' : Helpers.formatLastSeen(otherUser?.lastSeen),
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'media') {}
              if (v == 'group') {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => GroupInfoScreen(chat: widget.chat),
                ));
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'media', child: Text('View media')),
              if (widget.chat.isGroup)
                const PopupMenuItem(value: 'group', child: Text('Group info')),
              const PopupMenuItem(value: 'search', child: Text('Search')),
              const PopupMenuItem(value: 'mute', child: Text('Mute')),
              const PopupMenuItem(value: 'wallpaper', child: Text('Wallpaper')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_outline, size: 40, color: AppColors.textHint),
                            const SizedBox(height: 12),
                            Text(
                              'Messages are end-to-end encrypted',
                              style: TextStyle(color: AppColors.textHint, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            itemCount: messages.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isMe = message.senderId == auth.userId;
                              return MessageBubble(
                                message: message,
                                isMe: isMe,
                                showSenderName: widget.chat.isGroup && !isMe,
                              );
                            },
                          ),
                          if (_showScrollButton)
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: FloatingActionButton.small(
                                onPressed: _scrollToBottom,
                                backgroundColor: AppColors.accent,
                                child: const Icon(Icons.arrow_downward, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
          ),
          if (_replyToMessageId != null)
            Container(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 20, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _replyToContent ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: _cancelReply,
                  ),
                ],
              ),
            ),
          Container(
            color: AppColors.surface,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isEmojiVisible)
                    SizedBox(
                      height: 300,
                      child: EmojiPicker(
                        onEmojiSelected: (category, emoji) {
                          _messageController.text += emoji.emoji;
                        },
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined),
                          color: AppColors.textSecondary,
                          onPressed: _showEmojiPicker,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.attach_file),
                                  color: AppColors.textSecondary,
                                  onPressed: _showAttachmentOptions,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    focusNode: _focusNode,
                                    onChanged: (_) => _onTyping(),
                                    textInputAction: TextInputAction.newline,
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      hintText: 'Message',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                                      isCollapsed: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_messageController.text.trim().isEmpty)
                          GestureDetector(
                            onLongPressStart: (_) => setState(() => _isRecording = true),
                            onLongPressEnd: (_) => setState(() => _isRecording = false),
                            child: Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accent,
                              ),
                              child: Icon(
                                _isRecording ? Icons.mic : Icons.mic_none,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accent,
                            ),
                            child: InkWell(
                              onTap: _sendTextMessage,
                              child: const Icon(Icons.send, color: Colors.white, size: 20),
                            ),
                          ),
                      ],
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
}
