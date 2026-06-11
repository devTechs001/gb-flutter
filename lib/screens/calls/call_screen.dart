import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/call_model.dart';
import '../../providers/call_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';

class CallScreen extends StatefulWidget {
  final CallModel? call;
  final bool isIncoming;

  const CallScreen({
    super.key,
    this.call,
    this.isIncoming = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _durationTimer;
  int _callDuration = 0;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isVideoOn = false;
  String _callStatus = 'ringing';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (!widget.isIncoming) {
      _startCall();
    }
  }

  void _startCall() {
    setState(() => _callStatus = 'ringing');
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _callStatus = 'ongoing');
        _startDurationTimer();
      }
    });
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _callDuration++);
    });
  }

  void _endCall() {
    _durationTimer?.cancel();
    _pulseController.dispose();

    if (widget.call != null) {
      context.read<CallProvider>().updateCallDuration(
        widget.call!.callId,
        _callDuration,
      );
    }

    Navigator.pop(context);
  }

  void _toggleMute() => setState(() => _isMuted = !_isMuted);
  void _toggleSpeaker() => setState(() => _isSpeakerOn = !_isSpeakerOn);
  void _toggleVideo() => setState(() => _isVideoOn = !_isVideoOn);

  void _acceptCall() {
    setState(() => _callStatus = 'ongoing');
    _startDurationTimer();
  }

  void _declineCall() {
    _pulseController.dispose();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final call = widget.call;
    final contactName = call != null
        ? (call.direction == Constants.callDirectionIncoming
            ? call.callerName
            : call.receiverName)
        : 'Contact';
    final contactPhoto = call != null
        ? (call.direction == Constants.callDirectionIncoming
            ? call.callerPhoto
            : call.receiverPhoto)
        : null;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.primaryLight,
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            );
          },
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Contact info
                Column(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundImage: contactPhoto != null
                          ? NetworkImage(contactPhoto)
                          : null,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: contactPhoto == null
                          ? Text(
                              Helpers.getInitials(contactName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      contactName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _callStatus == 'ringing' ? 'Ringing...' : 'Ongoing',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                    if (_callStatus == 'ongoing')
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          Helpers.formatDuration(_callDuration),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                  ],
                ),

                const Spacer(flex: 2),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      // Toggle row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ActionButton(
                            icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                            label: _isMuted ? 'Unmute' : 'Mute',
                            color: _isMuted ? AppColors.accent : Colors.white.withOpacity(0.2),
                            iconColor: _isMuted ? Colors.white : Colors.white.withOpacity(0.8),
                            onPressed: _toggleMute,
                          ),
                          _ActionButton(
                            icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                            label: _isSpeakerOn ? 'Speaker' : 'Speaker',
                            color: _isSpeakerOn ? AppColors.accent : Colors.white.withOpacity(0.2),
                            iconColor: _isSpeakerOn ? Colors.white : Colors.white.withOpacity(0.8),
                            onPressed: _toggleSpeaker,
                          ),
                          _ActionButton(
                            icon: _isVideoOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                            label: _isVideoOn ? 'Video' : 'Video',
                            color: _isVideoOn ? AppColors.accent : Colors.white.withOpacity(0.2),
                            iconColor: _isVideoOn ? Colors.white : Colors.white.withOpacity(0.8),
                            onPressed: _toggleVideo,
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // End call / Accept-Decline row
                      if (widget.isIncoming && _callStatus == 'ringing')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ActionButton(
                              icon: Icons.call_end_rounded,
                              label: 'Decline',
                              color: AppColors.callRed,
                              iconColor: Colors.white,
                              size: 64,
                              iconSize: 32,
                              onPressed: _declineCall,
                            ),
                            _ActionButton(
                              icon: Icons.call_rounded,
                              label: 'Accept',
                              color: AppColors.callGreen,
                              iconColor: Colors.white,
                              size: 64,
                              iconSize: 32,
                              onPressed: _acceptCall,
                            ),
                          ],
                        )
                      else
                        _ActionButton(
                          icon: Icons.call_end_rounded,
                          label: 'End Call',
                          color: AppColors.callRed,
                          iconColor: Colors.white,
                          size: 72,
                          iconSize: 36,
                          onPressed: _endCall,
                        ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final double size;
  final double iconSize;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    this.size = 48,
    this.iconSize = 24,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
