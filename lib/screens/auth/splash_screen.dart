import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/call_provider.dart';
import '../../providers/status_provider.dart';
import '../../theme/zeno_colors.dart';
import '../../services/sample_data_service.dart';
import '../../services/local_storage_service.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _waveAnim;
  late Animation<double> _pulseAnim;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.4, 1.0, curve: Curves.easeInOut)),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic)),
    );
    _waveAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _particles = List.generate(40, (i) => _Particle(
      x: Random().nextDouble(),
      y: Random().nextDouble(),
      size: Random().nextDouble() * 3 + 1,
      speed: Random().nextDouble() * 0.2 + 0.05,
      opacity: Random().nextDouble() * 0.4 + 0.1,
      isStar: Random().nextBool(),
    ));

    _animController.forward();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<void> _devModeLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    final statusProvider = Provider.of<StatusProvider>(context, listen: false);

    await LocalStorageService().initialize();
    await authProvider.setupDevUser(
      displayName: 'Alex Dev',
      status: 'Building ChatWave 🚀',
    );
    SampleDataService.loadSampleData(chatProvider, authProvider);
    SampleDataService.loadSampleCalls(callProvider, authProvider);
    SampleDataService.loadSampleStatus(statusProvider, authProvider);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C5CE7),
              Color(0xFF4834D4),
              Color(0xFF2D1B69),
              Color(0xFF1A0A3E),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) => CustomPaint(
                painter: _WavePainter(
                  progress: _waveAnim.value,
                  color: ZenoColors.accent.withValues(alpha: 0.06),
                ),
                size: Size.infinite,
              ),
            ),
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) => CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  progress: _animController.value * 0.3,
                ),
                size: Size.infinite,
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _glowAnim,
                        child: _buildLogo(),
                      ),
                      const SizedBox(height: 12),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFFA29BFE)],
                        ).createShader(bounds),
                        child: const Text(
                          'ChatWave',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SlideTransition(
                        position: _slideAnim,
                        child: Text(
                          'Ride the wave of connection',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: _pulseAnim,
                            child: SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ZenoColors.accent.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Connecting you securely',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildDevModeButton(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _pulseAnim,
      child: Container(
        width: 140, height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: ZenoColors.accent.withValues(alpha: 0.3),
              blurRadius: 50,
              spreadRadius: 10,
            ),
            BoxShadow(
              color: ZenoColors.primaryLight.withValues(alpha: 0.2),
              blurRadius: 80,
              spreadRadius: 20,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: ClipOval(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, _) => CustomPaint(
                    painter: _InnerWavePainter(
                      progress: _waveAnim.value,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    size: const Size(140, 140),
                  ),
                ),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mode_comment_rounded, size: 56, color: Colors.white),
                    SizedBox(height: 2),
                    Icon(Icons.waves_rounded, size: 18, color: Colors.white70),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDevModeButton() {
    return SlideTransition(
      position: _slideAnim,
      child: GestureDetector(
        onTap: _devModeLogin,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ZenoColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.developer_mode, color: ZenoColors.accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Dev Mode: Skip Login',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Load sample data & explore',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.4), size: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;

  _WavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * 0.04;
    final offset = progress * size.width;

    path.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.7 +
          sin((x + offset) * 0.02) * waveHeight +
          sin((x + offset) * 0.04) * waveHeight * 0.5;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => oldDelegate.progress != progress;
}

class _InnerWavePainter extends CustomPainter {
  final double progress;
  final Color color;

  _InnerWavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final r = radius * (0.3 + progress * 0.3 + i * 0.15);
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _InnerWavePainter oldDelegate) => oldDelegate.progress != progress;
}

class _Particle {
  final double x, y, size, speed, opacity;
  final bool isStar;
  _Particle({required this.x, required this.y, required this.size, required this.speed, required this.opacity, this.isStar = false});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: p.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      final y = (p.y + progress * p.speed) % 1.0;
      if (p.isStar) {
        final path = Path();
        final cx = p.x * size.width;
        final cy = y * size.height;
        final r = p.size;
        for (int i = 0; i < 5; i++) {
          final angle = -pi / 2 + i * 2 * pi / 5;
          final outerX = cx + r * cos(angle);
          final outerY = cy + r * sin(angle);
          if (i == 0) path.moveTo(outerX, outerY);
          else path.lineTo(outerX, outerY);
          final innerAngle = angle + pi / 5;
          final innerX = cx + r * 0.4 * cos(innerAngle);
          final innerY = cy + r * 0.4 * sin(innerAngle);
          path.lineTo(innerX, innerY);
        }
        path.close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawCircle(Offset(p.x * size.width, y * size.height), p.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
