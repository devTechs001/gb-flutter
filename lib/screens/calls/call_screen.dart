import 'package:flutter/material.dart';
import 'dart:math';

class CallScreen extends StatefulWidget {
  final String callerName;
  final String? callerPhoto;
  final String type; // 'audio' or 'video'

  const CallScreen({
    super.key,
    required this.callerName,
    this.callerPhoto,
    this.type = 'video',
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isMuted = false;
  bool _isSpeaker = false;
  bool _isCallEnded = false;
  int _callDuration = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _startCallTimer();
  }

  void _startCallTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_isCallEnded) {
        setState(() => _callDuration++);
        _startCallTimer();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _formattedDuration {
    final min = _callDuration ~/ 60;
    final sec = _callDuration % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void _endCall() {
    setState(() => _isCallEnded = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF0D0D1A),
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background particle effect for video calls
            if (widget.type == 'video')
              Positioned.fill(
                child: CustomPaint(
                  painter: _CallParticlePainter(progress: _pulseController.value),
                ),
              ),
            // Main content
            Column(
              children: [
                const Spacer(flex: 2),
                // Avatar / caller info
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    final scale = 1.0 + (_pulseController.value * 0.03);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              widget.type == 'video' ? Colors.blue : Colors.green,
                              widget.type == 'video' ? Colors.purple : Colors.teal,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (widget.type == 'video' ? Colors.blue : Colors.green).withValues(alpha: 0.3),
                              blurRadius: 30 + (_pulseController.value * 20),
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: widget.callerPhoto != null
                            ? CircleAvatar(radius: 60, backgroundImage: NetworkImage(widget.callerPhoto!))
                            : Icon(
                                widget.type == 'video' ? Icons.videocam : Icons.phone,
                                color: Colors.white, size: 50,
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  widget.callerName,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _isCallEnded ? 'Call ended' : (_callDuration > 0 ? _formattedDuration : 'Connecting...'),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16),
                ),
                const Spacer(flex: 2),
                // Control buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _controlButton(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        label: _isMuted ? 'Unmute' : 'Mute',
                        color: _isMuted ? Colors.orange : Colors.white54,
                        onTap: () => setState(() => _isMuted = !_isMuted),
                      ),
                      _controlButton(
                        icon: _isSpeaker ? Icons.volume_up : Icons.volume_down,
                        label: _isSpeaker ? 'Speaker' : 'Speaker',
                        color: _isSpeaker ? Colors.blue : Colors.white54,
                        onTap: () => setState(() => _isSpeaker = !_isSpeaker),
                      ),
                      if (widget.type == 'video')
                        _controlButton(
                          icon: Icons.switch_camera,
                          label: 'Flip',
                          color: Colors.white54,
                          onTap: () {},
                        ),
                      _controlButton(
                        icon: Icons.call_end,
                        label: 'End',
                        color: Colors.red,
                        size: 48,
                        onTap: _endCall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required Color color,
    double size = 28,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size + 24,
            height: size + 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Icon(icon, color: color, size: size * 0.7),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
}

class _CallParticlePainter extends CustomPainter {
  final double progress;
  _CallParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    for (int i = 0; i < 15; i++) {
      final x = (sin(i * 2.7 + progress * 2 * pi) * 0.5 + 0.5) * size.width;
      final y = (cos(i * 3.1 + progress * 3 * pi) * 0.5 + 0.5) * size.height;
      canvas.drawCircle(Offset(x, y), 20 + sin(progress * pi + i) * 10, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CallParticlePainter oldDelegate) => true;
}
