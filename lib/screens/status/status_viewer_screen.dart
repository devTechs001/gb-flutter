import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/status_model.dart';
import '../../providers/status_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../utils/helpers.dart';

class StatusViewerScreen extends StatefulWidget {
  final List<StatusModel> statuses;
  final int initialIndex;

  const StatusViewerScreen({
    super.key,
    required this.statuses,
    this.initialIndex = 0,
  });

  @override
  State<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<StatusViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  Timer? _timer;
  double _progress = 0.0;
  bool _isPaused = false;
  final TextEditingController _replyController = TextEditingController();
  static const Duration _statusDuration = Duration(seconds: 5);
  static const Duration _progressInterval = Duration(milliseconds: 50);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _startAutoAdvance();
    _markAsViewed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _startAutoAdvance() {
    _timer?.cancel();
    _progress = 0.0;
    final totalTicks = _statusDuration.inMilliseconds ~/ _progressInterval.inMilliseconds;
    var ticks = 0;

    _timer = Timer.periodic(_progressInterval, (timer) {
      if (_isPaused) return;
      ticks++;
      _progress = ticks / totalTicks;

      if (_progress >= 1.0) {
        _goToNext();
      } else {
        setState(() {});
      }
    });
  }

  void _goToNext() {
    if (_currentIndex < widget.statuses.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  Widget _buildTextStatus(StatusModel s) {
    final caption = s.caption.isNotEmpty ? s.caption : 'No caption';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          caption,
          style: TextStyle(fontSize: 24, color: Colors.white, fontFamily: s.fontFamily),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _reactionChip(String emoji) {
    return GestureDetector(
      onTap: () {
        Helpers.showSnackBar(context, 'Reacted $emoji');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  void _markAsViewed() {
    final status = widget.statuses[_currentIndex];
    final userId = context.read<AuthProvider>().userId;
    final userName = context.read<AuthProvider>().userModel?.displayName ?? 'Unknown';

    if (status.userId != userId &&
        !status.viewers.any((v) => v['userId'] == userId)) {
      context.read<StatusProvider>().addViewer(status.statusId, userId, userName);
    }
  }

  void _onTap(TapUpDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.localPosition.dx;

    if (tapX < screenWidth / 3) {
      _goToPrevious();
    } else if (tapX > 2 * screenWidth / 3) {
      _goToNext();
    } else {
      _togglePause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.statuses[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: _onTap,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.statuses.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _startAutoAdvance();
                _markAsViewed();
              },
              itemBuilder: (context, index) {
                final s = widget.statuses[index];
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: s.backgroundColor != null
                      ? Color(s.backgroundColor!)
                      : Colors.black,
                  child: (s.type == 'image' && s.mediaURL.isNotEmpty)
                      ? Image.network(
                          s.mediaURL,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(color: Colors.white)),
                          errorBuilder: (_, __, ___) => _buildTextStatus(s),
                        )
                      : _buildTextStatus(s),
                );
              },
            ),

            // Progress bars
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 8,
              child: Row(
                children: List.generate(widget.statuses.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: index == _currentIndex
                              ? _progress
                              : index < _currentIndex
                                  ? 1.0
                                  : 0.0,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // User info
            Positioned(
              top: MediaQuery.of(context).padding.top + 36,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: status.userPhoto != null
                        ? NetworkImage(status.userPhoto!)
                        : null,
                    backgroundColor: Helpers.generateAvatarColor(status.userName),
                    child: status.userPhoto == null
                        ? Text(
                            Helpers.getInitials(status.userName),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          Helpers.formatTime(status.timestamp),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                        if (status.music != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.music_note, size: 12, color: AppColors.accent),
                              const SizedBox(width: 4),
                              Text(
                                status.music!,
                                style: TextStyle(
                                  color: AppColors.accent.withOpacity(0.9),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isPaused ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _togglePause,
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                    onSelected: (v) {
                      if (v == 'delete') {
                        context.read<StatusProvider>().deleteStatus(status.statusId);
                        Navigator.pop(context);
                      } else if (v == 'share') {
                        Helpers.showSnackBar(context, 'Status shared');
                      } else if (v == 'mute') {
                        Helpers.showSnackBar(context, 'Status muted');
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'share', child: ListTile(leading: Icon(Icons.share, color: Colors.white), title: Text('Share'))),
                      const PopupMenuItem(value: 'mute', child: ListTile(leading: Icon(Icons.volume_off, color: Colors.white), title: Text('Mute'))),
                      const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red)))),
                    ],
                  ),
                ],
              ),
            ),

            // Reaction row
            if (!status.isMuted)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 72,
                left: 0, right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _reactionChip('❤️'),
                        _reactionChip('😂'),
                        _reactionChip('😮'),
                        _reactionChip('🔥'),
                        _reactionChip('💯'),
                        _reactionChip('👍'),
                      ],
                    ),
                  ),
                ),
              ),

            // Reply input
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 8,
              left: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.keyboard, color: Colors.white.withOpacity(0.7)),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Reply to ${status.userName}...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.accent),
                      onPressed: () {
                        final text = _replyController.text.trim();
                        if (text.isNotEmpty) {
                          _replyController.clear();
                          Helpers.showSnackBar(context, 'Reply sent');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Pause indicator
            if (_isPaused)
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
