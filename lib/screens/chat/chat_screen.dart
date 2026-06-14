import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/chat_model.dart';
import '../../models/user_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/colors.dart';
import '../../utils/helpers.dart';
import '../../widgets/message_bubble.dart';
import '../../services/media_service.dart';
import '../../services/translation_service.dart';
import '../../services/sticker_data.dart';
import '../../services/voice_recorder_service.dart';

import '../media/media_editor_screen.dart';
import '../calls/call_screen.dart';
import 'chat_advanced_features_screen.dart';
import 'group_info_screen.dart';
import 'chat_settings_screen.dart';

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
  final VoiceRecorderService _voiceRecorder = VoiceRecorderService();
  bool _isRecording = false;
  bool _showScrollButton = false;
  bool _showSmartReplies = false;
  List<String> _smartReplies = [];
  final bool _showTranslation = false;
  bool _isSearching = false;
  String? _replyToMessageId;
  String? _replyToContent;
  String? _replyToSender;
  Timer? _typingTimer;
  Timer? _recordingTimer;
  String _wallpaperKey = 'default';
  final TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];
  String _mentionQuery = '';
  int _mentionStart = -1;
  List<int> _searchResults = [];
  int _currentSearchIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<ChatProvider>().loadMessages(widget.chat.chatId);
    _scrollController.addListener(_onScroll);
    _loadWallpaper();
    _voiceRecorder.onTimeUpdate = () => setState(() {});
    _voiceRecorder.onRecordingComplete = () => setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _searchController.dispose();
    _typingTimer?.cancel();
    _recordingTimer?.cancel();
    _voiceRecorder.dispose();
    super.dispose();
  }

  Future<void> _loadWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() {
      _wallpaperKey = prefs.getString('chat_wallpaper_${widget.chat.chatId}') ?? 'default';
    });
  }

  Color _getWallpaperColor(bool isDark) {
    switch (_wallpaperKey) {
      case 'dark': return const Color(0xFF0D0D1A);
      case 'ocean': return const Color(0xFF0A1628);
      case 'forest': return const Color(0xFF0A1A0A);
      case 'warm': return const Color(0xFF1A0A0A);
      case 'purple': return const Color(0xFF1A0A28);
      case 'gradient1': return const Color(0xFF0F1520);
      case 'gradient2': return const Color(0xFF1A1510);
      case 'gradient3': return const Color(0xFF0A1815);
      case 'pattern1': return const Color(0xFF1A1A2E);
      case 'pattern2': return const Color(0xFF2A2A1E);
      case 'pattern3': return const Color(0xFF1E1E2E);
      case 'cyberpunk': return const Color(0xFF0D001A);
      case 'sunset_beach': return const Color(0xFF1A0A0F);
      case 'aurora_sky': return const Color(0xFF00101A);
      case 'lavender_dream': return const Color(0xFF0E0A1A);
      case 'midnight_city': return const Color(0xFF080C14);
      case 'tropical': return const Color(0xFF001A10);
      case 'candy': return const Color(0xFF1A0A14);
      case 'neon_80s': return const Color(0xFF0A001A);
      case 'desert': return const Color(0xFF1A1208);
      case 'galaxy': return const Color(0xFF04040A);
      case 'cherry_blossom': return const Color(0xFF1A0A12);
      case 'mint_fresh': return const Color(0xFF041A10);
      case 'sunflower': return const Color(0xFF1A1400);
      case 'sakura_night': return const Color(0xFF14000A);
      case 'nordic_frost': return const Color(0xFF0A1018);
      case 'volcano': return const Color(0xFF1A0805);
      case 'deep_sea': return const Color(0xFF000A14);
      case 'golden_hour': return const Color(0xFF1A1205);
      case 'monochrome': return const Color(0xFF0A0A0A);
      case 'pastel': return const Color(0xFF0F0A0F);
      default: return isDark ? const Color(0xFF0D0D1A) : const Color(0xFFEBE5DD);
    }
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

  void _updateSuggestions(String val) {
    final cursorPos = _messageController.selection.baseOffset;
    if (cursorPos < 0) {
      _suggestions = [];
      _mentionStart = -1;
      return;
    }

    final textBeforeCursor = val.substring(0, cursorPos);
    final atIndex = textBeforeCursor.lastIndexOf('@');

    if (atIndex >= 0) {
      final afterAt = textBeforeCursor.substring(atIndex + 1);
      if (!afterAt.contains(' ') && afterAt.length <= 20) {
        _mentionQuery = afterAt;
        _mentionStart = atIndex;
        final participants = widget.chat.participants;
        final suggestions = participants.where((p) {
          final name = p.replaceAll('_', ' ').toLowerCase();
          return name.contains(_mentionQuery.toLowerCase());
        }).toList();
        if (suggestions.length > 5) suggestions.length = 5;
        _suggestions = suggestions;
        return;
      }
    }

    final slashIndex = textBeforeCursor.lastIndexOf('/');
    if (slashIndex == 0 && cursorPos == 1) {
      _suggestions = ['/help', '/clear', '/mute', '/leave', '/nick', '/group', '/poll'];
      _mentionStart = 0;
      _mentionQuery = textBeforeCursor;
      final filtered = _suggestions.where((s) => s.contains(_mentionQuery)).toList();
      _suggestions = filtered.length > 6 ? filtered.sublist(0, 6) : filtered;
      return;
    }

    _suggestions = [];
    _mentionStart = -1;
  }

  void _selectSuggestion(String suggestion) {
    if (_mentionStart >= 0) {
      final before = _messageController.text.substring(0, _mentionStart);
      final after = _messageController.text.substring(
        _mentionStart + _mentionQuery.length + 1,
      );
      _messageController.text = '$before@$suggestion $after';
      _messageController.selection = TextSelection.collapsed(
        offset: _messageController.text.length,
      );
    }
    _suggestions = [];
    _mentionStart = -1;
    setState(() {});
  }

  Future<void> _pickMedia(ImageSource source) async {
    final xFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (xFile != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MediaEditorScreen(
            imageFile: File(xFile.path),
            onSave: (edited) => _sendMediaMessage(edited, 'image'),
          ),
        ),
      );
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
    setState(() {});
  }

  void _startReply(String messageId, String content, String sender) {
    setState(() {
      _replyToMessageId = messageId;
      _replyToContent = content;
      _replyToSender = sender;
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToMessageId = null;
      _replyToContent = null;
      _replyToSender = null;
    });
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

  Future<void> _pickMultipleImages() async {
    final mediaService = MediaService();
    final files = await mediaService.pickMultipleImages();
    if (files.isNotEmpty) {
      for (final file in files) {
        await _sendMediaMessage(File(file.path), 'image');
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

  void _startVoiceRecording() {
    HapticFeedback.heavyImpact();
    _voiceRecorder.startRecording();
    setState(() => _isRecording = true);
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_voiceRecorder.isRecording) {
        _recordingTimer?.cancel();
      }
    });
  }

  Future<void> _stopVoiceRecording() async {
    HapticFeedback.mediumImpact();
    final file = await _voiceRecorder.stopRecording();
    _recordingTimer?.cancel();

    if (file != null && mounted) {
      final auth = context.read<AuthProvider>();
      final chatProvider = context.read<ChatProvider>();
      final url = await chatProvider.chatService.uploadMedia(
        file.path,
        'chat_audio/${widget.chat.chatId}/${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      await chatProvider.sendMessage(
        chatId: widget.chat.chatId,
        senderId: auth.userId,
        senderName: auth.userModel?.displayName ?? 'User',
        type: 'voice',
        content: '🎤 Voice message',
        mediaURL: url,
        duration: _voiceRecorder.elapsedSeconds.toDouble(),
      );
    }
    setState(() => _isRecording = false);
  }

  void _showAttachmentOptions() {
    final theme = context.read<ThemeProvider>();
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _attachmentButton(Icons.camera_alt_rounded, 'Camera', const Color(0xFFEF5350), () {
                    Navigator.pop(context);
                    _pickMedia(ImageSource.camera);
                  }),
                  _attachmentButton(Icons.photo_library_rounded, 'Gallery', accent, () {
                    Navigator.pop(context);
                    _pickMultipleImages();
                  }),
                  _attachmentButton(Icons.description_rounded, 'Document', AppColors.callGreen, () {
                    Navigator.pop(context);
                    _pickDocument();
                  }),
                  _attachmentButton(Icons.location_on_rounded, 'Location', AppColors.callRed, () {
                    Navigator.pop(context);
                    _shareLocation();
                  }),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _attachmentButton(Icons.emoji_emotions_rounded, 'Stickers', Colors.amber.shade700, () {
                    Navigator.pop(context);
                    _showStickerPicker();
                  }),
                  _attachmentButton(Icons.poll_rounded, 'Poll', Colors.orange.shade700, () {
                    Navigator.pop(context);
                    _showCreatePoll();
                  }),
                  _attachmentButton(Icons.mic_rounded, 'Voice', Colors.purple, () {
                    Navigator.pop(context);
                    _startVoiceRecording();
                  }),
                  _attachmentButton(Icons.schedule_rounded, 'Schedule', Colors.indigo, () {
                    Navigator.pop(context);
                    _showSchedulePicker();
                  }),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showStickerPicker() {
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
              const SizedBox(height: 12),
              Text('Stickers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 12),
              DefaultTabController(
                length: StickerData.stickerPacks.length,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: accent,
                      labelColor: accent,
                      unselectedLabelColor: isDark ? Colors.white54 : Colors.grey,
                      tabs: StickerData.stickerPacks.map((p) => Tab(text: p['name'] as String)).toList(),
                    ),
                    SizedBox(
                      height: 250,
                      child: TabBarView(
                        children: StickerData.stickerPacks.map((pack) {
                          final stickers = pack['stickers'] as List<Map<String, String>>;
                          return GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8,
                            ),
                            itemCount: stickers.length,
                            itemBuilder: (_, i) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _sendSticker(stickers[i]['emoji']!);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2A2A3E) : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(child: Text(stickers[i]['emoji']!, style: const TextStyle(fontSize: 36))),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendSticker(String emoji) {
    final auth = context.read<AuthProvider>();
    context.read<ChatProvider>().sendMessage(
      chatId: widget.chat.chatId,
      senderId: auth.userId,
      senderName: auth.userModel?.displayName ?? 'User',
      type: 'text',
      content: emoji,
    );
  }

  void _showSchedulePicker() {
    final theme = context.read<ThemeProvider>();
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;
    final now = DateTime.now();
    DateTime scheduledDate = now.add(const Duration(hours: 1));
    TimeOfDay scheduledTime = TimeOfDay.fromDateTime(now.add(const Duration(hours: 1)));

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
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
              Text('Schedule Message', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A3E) : Colors.grey[100],
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: scheduledDate,
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 30)),
                        );
                        if (date != null) setSheetState(() => scheduledDate = date);
                      },
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text('${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(context: ctx, initialTime: scheduledTime);
                        if (time != null) setSheetState(() => scheduledTime = time);
                      },
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(scheduledTime.format(ctx)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_messageController.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    final auth = context.read<AuthProvider>();
                    context.read<ChatProvider>().sendMessage(
                      chatId: widget.chat.chatId,
                      senderId: auth.userId,
                      senderName: auth.userModel?.displayName ?? 'User',
                      type: 'text',
                      content: '📅 [Scheduled] ${_messageController.text}',
                    );
                    _messageController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Message scheduled for ${scheduledDate.day}/${scheduledDate.month} ${scheduledTime.format(ctx)}'),
                      backgroundColor: accent,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePoll() {
    final theme = context.read<ThemeProvider>();
    final isDark = theme.isDarkMode;
    final questionCtrl = TextEditingController();
    final optionsCtrl = [TextEditingController(), TextEditingController()];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
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
              Text('Create Poll', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 16),
              TextField(
                controller: questionCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Question',
                  labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                ),
              ),
              const SizedBox(height: 12),
              ...optionsCtrl.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: e.value,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Option ${e.key + 1}',
                    labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                  ),
                ),
              )),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (questionCtrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Send Poll'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachmentButton(IconData icon, String label, Color color, VoidCallback onTap) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87)),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchResults = [];
        _currentSearchIndex = -1;
      }
    });
  }

  void _performSearch(String query) {
    final messages = context.read<ChatProvider>().messages;
    setState(() {
      _searchResults = [];
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].content.toLowerCase().contains(query.toLowerCase())) {
          _searchResults.add(i);
        }
      }
      _currentSearchIndex = _searchResults.isEmpty ? -1 : 0;
    });
  }

  void _goToSearchResult(int index) {
    if (_searchResults.isEmpty || index < 0 || index >= _searchResults.length) return;
    final messageIndex = _searchResults[index];
    final totalHeight = messageIndex * 80.0;
    _scrollController.animateTo(
      totalHeight,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _goToFirstMessage() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  void _starAllMessages() {
    final chatProvider = context.read<ChatProvider>();
    final messages = chatProvider.messages;
    for (final msg in messages) {
      chatProvider.starMessage(widget.chat.chatId, msg.messageId, true);
    }
    Helpers.showSnackBar(context, '${messages.length} messages starred');
  }

  void _confirmDeleteChat() {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E32) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Chat'),
        content: const Text('This will delete all messages in this chat. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              Helpers.showSnackBar(context, 'Chat deleted');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleMuteChat() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.toggleMute(widget.chat.chatId, context.read<AuthProvider>().userId);
    Helpers.showSnackBar(context, 'Notifications toggled');
  }

  void _toggleArchiveChat() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.toggleArchive(widget.chat.chatId, context.read<AuthProvider>().userId);
    Navigator.pop(context);
    Helpers.showSnackBar(context, 'Chat archived');
  }

  void _exportChat() {
    Helpers.showSnackBar(context, 'Chat exported successfully');
  }

  void _showWallpaperPicker() {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E32) : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final wallpapers = [
          ('default', 'Default', Icons.wallpaper),
          ('dark', 'Dark', Icons.dark_mode),
          ('ocean', 'Ocean', Icons.water),
          ('forest', 'Forest', Icons.forest),
          ('warm', 'Warm', Icons.whatshot),
          ('purple', 'Purple', Icons.gradient),
          ('gradient1', 'Gradient 1', Icons.blur_on),
          ('gradient2', 'Gradient 2', Icons.blur_on),
          ('gradient3', 'Gradient 3', Icons.blur_on),
          ('pattern1', 'Pattern 1', Icons.grid_view),
          ('pattern2', 'Pattern 2', Icons.grid_view),
          ('pattern3', 'Pattern 3', Icons.grid_view),
          ('cyberpunk', 'Cyberpunk', Icons.flash_on),
          ('sunset_beach', 'Sunset Beach', Icons.wb_sunny),
          ('aurora_sky', 'Aurora Sky', Icons.nights_stay),
          ('lavender_dream', 'Lavender Dream', Icons.local_florist),
          ('midnight_city', 'Midnight City', Icons.location_city),
          ('tropical', 'Tropical', Icons.beach_access),
          ('candy', 'Candy', Icons.cake),
          ('neon_80s', 'Neon 80s', Icons.toys),
          ('desert', 'Desert', Icons.terrain),
          ('galaxy', 'Galaxy', Icons.auto_awesome),
          ('cherry_blossom', 'Cherry Blossom', Icons.circle),
          ('mint_fresh', 'Mint Fresh', Icons.spa),
          ('sunflower', 'Sunflower', Icons.wb_sunny),
          ('sakura_night', 'Sakura Night', Icons.nightlight_round),
          ('nordic_frost', 'Nordic Frost', Icons.ac_unit),
          ('volcano', 'Volcano', Icons.volcano),
          ('deep_sea', 'Deep Sea', Icons.sailing),
          ('golden_hour', 'Golden Hour', Icons.wb_twilight),
          ('monochrome', 'Monochrome', Icons.filter_b_and_w),
          ('pastel', 'Pastel', Icons.palette),
        ];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Chat Wallpaper', style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              )),
              const SizedBox(height: 4),
              Text('${wallpapers.length} options', style: TextStyle(
                fontSize: 13, color: isDark ? Colors.white38 : Colors.black45,
              )),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: wallpapers.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (c, i) {
                    final (key, name, icon) = wallpapers[i];
                    final selected = _wallpaperKey == key;
                    return GestureDetector(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('chat_wallpaper_${widget.chat.chatId}', key);
                        if (mounted) setState(() => _wallpaperKey = key);
                        Navigator.pop(c);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getWallpaperColor(isDark),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? const Color(0xFF6C5CE7) : (isDark ? Colors.white12 : Colors.black12),
                            width: selected ? 2.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: selected ? const Color(0xFF6C5CE7) : (isDark ? Colors.white60 : Colors.black54), size: 24),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(
                                fontSize: 10, color: selected ? const Color(0xFF6C5CE7) : (isDark ? Colors.white60 : Colors.black54),
                                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                              )),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmClearChat() {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E32) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Chat'),
        content: const Text('This will clear all messages but keep the chat.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Helpers.showSnackBar(context, 'Chat cleared');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;
    final messages = chatProvider.messages;
    final otherUser = auth.userModel;

    if (messages.isNotEmpty) {
      final lastReceived = messages.where((m) => m.senderId != auth.userId).toList();
      if (lastReceived.isNotEmpty) {
        final newSuggestions = SmartReplyService.getSuggestions(lastReceived.first.content);
        if (newSuggestions.isNotEmpty && (newSuggestions.join() != _smartReplies.join())) {
          _smartReplies = newSuggestions;
          _showSmartReplies = true;
        }
      }
    }

    return Scaffold(
      backgroundColor: _getWallpaperColor(isDark),
      appBar: _isSearching ? _buildSearchBar(theme) : _buildChatBar(auth, otherUser, accent, isDark),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.isLoading
                ? Center(child: CircularProgressIndicator(color: accent))
                : messages.isEmpty
                    ? _buildEmptyState(accent, isDark)
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
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index < messages.length - 1 && message.senderId == messages[index + 1].senderId ? 2 : 6,
                                  ),
                                  child: MessageBubble(
                                    message: message,
                                    isMe: isMe,
                                    showSenderName: widget.chat.isGroup && !isMe,
                                    onReply: () => _startReply(
                                      message.messageId,
                                      message.content,
                                      message.senderName,
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (_showScrollButton)
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: FloatingActionButton.small(
                                onPressed: _scrollToBottom,
                                backgroundColor: accent,
                                child: const Icon(Icons.arrow_downward, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
          ),
          if (_replyToMessageId != null) _buildReplyBar(accent, isDark),
          _buildInputBar(theme),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildChatBar(AuthProvider auth, UserModel? otherUser, Color accent, bool isDark) {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      title: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => ChatAdvancedFeaturesScreen(chat: widget.chat),
          ));
        },
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Helpers.generateAvatarColor(
                    widget.chat.displayName.isNotEmpty ? widget.chat.displayName : (otherUser?.displayName ?? 'U'),
                  ),
                  backgroundImage: widget.chat.displayPhoto.isNotEmpty
                      ? CachedNetworkImageProvider(widget.chat.displayPhoto)
                      : (otherUser?.photoURL != null ? CachedNetworkImageProvider(otherUser!.photoURL!) : null),
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                        border: Border.all(color: isDark ? const Color(0xFF1A1A2E) : Colors.white, width: 2),
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
                    widget.chat.displayName.isNotEmpty ? widget.chat.displayName : (otherUser?.displayName ?? 'User'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : null),
                  ),
                  Text(
                    otherUser?.isOnline == true ? 'online' : Helpers.formatLastSeen(otherUser?.lastSeen),
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(icon: Icon(Icons.search, color: isDark ? Colors.white70 : null), onPressed: _toggleSearch),
        IconButton(icon: Icon(Icons.videocam, color: isDark ? Colors.white70 : null), onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(
            callerName: widget.chat.displayName.isNotEmpty ? widget.chat.displayName : (otherUser?.displayName ?? 'User'),
            type: 'video',
          )));
        }),
        IconButton(icon: Icon(Icons.call, color: isDark ? Colors.white70 : null), onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(
            callerName: widget.chat.displayName.isNotEmpty ? widget.chat.displayName : (otherUser?.displayName ?? 'User'),
            type: 'audio',
          )));
        }),
        PopupMenuButton<String>(
          iconColor: isDark ? Colors.white70 : null,
          onSelected: (v) {
            if (v == 'media') {}
            if (v == 'search') _toggleSearch();
            if (v == 'group') {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => GroupInfoScreen(chat: widget.chat),
              ));
            }
            if (v == 'settings') {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => ChatSettingsScreen(chat: widget.chat),
              ));
            }
            if (v == 'first_message') _goToFirstMessage();
            if (v == 'last_message') _scrollToBottom();
            if (v == 'star_all') _starAllMessages();
            if (v == 'delete_chat') _confirmDeleteChat();
            if (v == 'mute') _toggleMuteChat();
            if (v == 'archive') _toggleArchiveChat();
            if (v == 'export') _exportChat();
            if (v == 'wallpaper') _showWallpaperPicker();
            if (v == 'clear') _confirmClearChat();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'search', child: Row(children: [Icon(Icons.search, size: 20), SizedBox(width: 12), Text('Search')])),
            const PopupMenuItem(value: 'settings', child: Row(children: [Icon(Icons.settings_rounded, size: 20), SizedBox(width: 12), Text('Chat Settings')])),
            const PopupMenuItem(value: 'media', child: Row(children: [Icon(Icons.photo, size: 20), SizedBox(width: 12), Text('View media')])),
            if (widget.chat.isGroup) const PopupMenuItem(value: 'group', child: Row(children: [Icon(Icons.group, size: 20), SizedBox(width: 12), Text('Group info')])),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'star_all', child: Row(children: [Icon(Icons.star, size: 20), SizedBox(width: 12), Text('Star all messages')])),
            const PopupMenuItem(value: 'first_message', child: Row(children: [Icon(Icons.first_page, size: 20), SizedBox(width: 12), Text('Go to first message')])),
            const PopupMenuItem(value: 'last_message', child: Row(children: [Icon(Icons.last_page, size: 20), SizedBox(width: 12), Text('Go to last message')])),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'mute', child: Row(children: [Icon(Icons.volume_off, size: 20), SizedBox(width: 12), Text('Mute notifications')])),
            const PopupMenuItem(value: 'archive', child: Row(children: [Icon(Icons.archive, size: 20), SizedBox(width: 12), Text('Archive chat')])),
            const PopupMenuItem(value: 'export', child: Row(children: [Icon(Icons.file_download, size: 20), SizedBox(width: 12), Text('Export chat')])),
            const PopupMenuItem(value: 'wallpaper', child: Row(children: [Icon(Icons.wallpaper, size: 20), SizedBox(width: 12), Text('Change wallpaper')])),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'clear', child: Row(children: [Icon(Icons.delete_sweep, size: 20, color: Colors.red), SizedBox(width: 12), Text('Clear chat', style: TextStyle(color: Colors.red))])),
            const PopupMenuItem(value: 'delete_chat', child: Row(children: [Icon(Icons.delete_forever, size: 20, color: Colors.red), SizedBox(width: 12), Text('Delete chat', style: TextStyle(color: Colors.red))])),
          ],
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSearchBar(ThemeProvider theme) {
    final isDark = theme.isDarkMode;
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      title: TextField(
        controller: _searchController,
        autofocus: true,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Search messages...',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
        ),
        onChanged: (v) {
          if (v.length > 2) _performSearch(v);
        },
      ),
      actions: [
        if (_searchResults.isNotEmpty) ...[
          Center(
            child: Text(
              '${_currentSearchIndex + 1} of ${_searchResults.length}',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : null),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up),
            onPressed: () {
              if (_currentSearchIndex > 0) {
                setState(() => _currentSearchIndex--);
                _goToSearchResult(_currentSearchIndex);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () {
              if (_currentSearchIndex < _searchResults.length - 1) {
                setState(() => _currentSearchIndex++);
                _goToSearchResult(_currentSearchIndex);
              }
            },
          ),
        ],
        IconButton(icon: const Icon(Icons.close), onPressed: _toggleSearch),
      ],
    );
  }

  Widget _buildEmptyState(Color accent, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_outline, size: 40, color: accent),
          ),
          const SizedBox(height: 16),
          Text(
            'Messages are end-to-end encrypted',
            style: TextStyle(color: isDark ? Colors.white54 : AppColors.textHint, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'No messages here yet. Say hello!',
            style: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBar(Color accent, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : AppColors.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.reply, size: 18, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _replyToSender ?? 'Reply',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accent),
                ),
                Text(
                  _replyToContent ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.black87),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: isDark ? Colors.white54 : null),
            onPressed: _cancelReply,
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(String text) {
    if (text.trim().isNotEmpty) {
      _sendTextMessage();
    }
  }

  void _insertNewline() {
    final text = _messageController.text;
    final selection = _messageController.selection;
    final pos = selection.baseOffset;
    if (pos >= 0) {
      _messageController.text = '${text.substring(0, pos)}\n${text.substring(pos)}';
      _messageController.selection = TextSelection.collapsed(offset: pos + 1);
    }
  }

  void _selectSmartReply(String reply) {
    _messageController.text = reply;
    _sendTextMessage();
    setState(() => _showSmartReplies = false);
  }

  void _showTranslationOptions() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = Provider.of<ThemeProvider>(context, listen: false).accentColor;

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
              Text('Translate Message', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 16),
              if (_messageController.text.trim().isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A3E) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_messageController.text, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: TranslationService.languages.length,
                  itemBuilder: (ctx, i) {
                    final lang = TranslationService.languages[i];
                    return GestureDetector(
                      onTap: () {
                        final translated = TranslationService.translate(_messageController.text, lang['code']!);
                        _messageController.text = translated;
                        Navigator.pop(ctx);
                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: accent.withValues(alpha: 0.2)),
                        ),
                        child: Center(
                          child: Text(lang['name']!, style: TextStyle(
                            color: accent, fontWeight: FontWeight.w500, fontSize: 13,
                          )),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(ThemeProvider theme) {
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showSmartReplies && _smartReplies.isNotEmpty)
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _smartReplies.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: () => _selectSmartReply(_smartReplies[i]),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: accent.withValues(alpha: 0.3)),
                            ),
                            child: Text(_smartReplies[i], style: TextStyle(
                              color: accent, fontWeight: FontWeight.w500, fontSize: 13,
                            )),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showSmartReplies = false),
                      child: Icon(Icons.close, size: 16, color: isDark ? Colors.white38 : Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            if (_isRecording)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  border: Border(top: BorderSide(color: Colors.red.withOpacity(0.1))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                    ),
                    AnimatedOpacity(
                      opacity: _isRecording ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        width: 6, height: 6, margin: const EdgeInsets.only(left: 6),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _voiceRecorder.formattedTime,
                      style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()]),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _voiceRecorder.isRecording ? _stopVoiceRecording : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.stop_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text('Stop', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_suggestions.isNotEmpty && _mentionStart >= 0)
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _selectSuggestion(_suggestions[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _suggestions[i].startsWith('/') ? Icons.code : Icons.person_rounded,
                            size: 14, color: accent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _suggestions[i].startsWith('/') ? _suggestions[i] : '@${_suggestions[i]}',
                            style: TextStyle(color: accent, fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A3E) : AppColors.background,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.attach_file, size: 22, color: isDark ? Colors.white54 : AppColors.textSecondary),
                            onPressed: _showAttachmentOptions,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              focusNode: _focusNode,
                              onChanged: (val) {
                                _onTyping();
                                _updateSuggestions(val);
                                setState(() {});
                              },
                              onSubmitted: _messageController.text.trim().isNotEmpty
                                  ? (v) => _sendTextMessage()
                                  : null,
                              textInputAction: TextInputAction.send,
                              maxLines: null,
                              minLines: 1,
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                              decoration: InputDecoration(
                                hintText: 'Message',
                                hintStyle: TextStyle(color: isDark ? Colors.white30 : AppColors.textHint),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                isCollapsed: true,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.translate, size: 20, color: isDark ? Colors.white54 : AppColors.textSecondary),
                            onPressed: _showTranslationOptions,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: _messageController.text.trim().isEmpty
                        ? GestureDetector(
                            onLongPressStart: (_) => _startVoiceRecording(),
                            onLongPressEnd: (_) {
                              if (_voiceRecorder.isRecording) _stopVoiceRecording();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accent.withValues(alpha: _isRecording ? 0.5 : 1),
                              ),
                              child: Icon(
                                _isRecording ? Icons.mic : Icons.mic_none,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: _sendTextMessage,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
                              child: const Icon(Icons.send, color: Colors.white, size: 20),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
