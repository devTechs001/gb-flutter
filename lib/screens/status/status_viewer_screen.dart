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
                  child: s.type == 'image'
                      ? Image.network(
                          s.mediaURL,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, size: 64, color: Colors.grey[500]),
                                const SizedBox(height: 16),
                                Text(
                                  s.caption,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontFamily: s.fontFamily,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            s.caption,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontFamily: s.fontFamily,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
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
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                    onPressed: () {},
                  ),
                ],
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
