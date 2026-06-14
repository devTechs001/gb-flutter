import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/privacy_provider.dart';
import '../../theme/zeno_colors.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback? onUnlocked;

  const LockScreen({super.key, this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with TickerProviderStateMixin {
  final _pinController = TextEditingController();
  String _enteredPin = '';
  int _attempts = 0;
  bool _isLockedOut = false;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;
  bool _showPin = false;
  bool _usePattern = false;

  AnimationController? _shakeController;
  Animation<double>? _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(_shakeController!);
  }

  @override
  void dispose() {
    _pinController.dispose();
    _shakeController?.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _onPinDigit(String digit) {
    if (_isLockedOut) return;
    if (_enteredPin.length >= 6) return;
    setState(() => _enteredPin += digit);
    if (_enteredPin.length == 6) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
    }
  }

  void _verifyPin() {
    final privacy = context.read<PrivacyProvider>();
    final correctPin = privacy.appLockPin;
    if (_enteredPin == correctPin) {
      setState(() => _attempts = 0);
      widget.onUnlocked?.call();
      Navigator.of(context).pop(true);
    } else {
      _shakeController?.forward(from: 0);
      setState(() {
        _attempts++;
        _enteredPin = '';
      });
      if (_attempts >= 3) {
        _startLockout();
      }
    }
  }

  void _startLockout() {
    final privacy = context.read<PrivacyProvider>();
    final minutes = int.tryParse(privacy.lockoutTimeMinutes) ?? 1;
    setState(() {
      _isLockedOut = true;
      _lockoutSeconds = minutes * 60;
    });
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_lockoutSeconds > 0) {
          _lockoutSeconds--;
        } else {
          _isLockedOut = false;
          _attempts = 0;
          _lockoutTimer?.cancel();
        }
      });
    });
  }

  void _onPatternEntered(List<int> pattern) {
    if (_isLockedOut) return;
    final pin = pattern.join('');
    if (pin.length < 4) return;
    setState(() => _enteredPin = pin);
    _verifyPin();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B2838),
              Color(0xFF0D1B2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildLogoSection(),
              const SizedBox(height: 32),
              _buildPinDots(),
              const SizedBox(height: 24),
              _buildStatusText(),
              const SizedBox(height: 16),
              if (!_usePattern) _buildNumberPad(),
              if (_usePattern) _buildPatternLock(),
              const Spacer(flex: 1),
              _buildBottomOptions(),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: ZenoColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.lock_outline, color: ZenoColors.primary, size: 36),
        ),
        const SizedBox(height: 16),
        Text(
          'ChatWave',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ZenoColors.primary,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter PIN to unlock',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildPinDots() {
    return AnimatedBuilder(
      animation: _shakeAnimation!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation!.value, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (i) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < _enteredPin.length
                  ? ZenoColors.primary
                  : Colors.white.withOpacity(0.2),
              border: Border.all(
                color: i < _enteredPin.length
                    ? ZenoColors.primary
                    : Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatusText() {
    if (_isLockedOut) {
      final min = _lockoutSeconds ~/ 60;
      final sec = _lockoutSeconds % 60;
      return Text(
        'Too many attempts. Try again in ${min}m ${sec}s',
        style: TextStyle(color: Colors.red[300], fontSize: 13),
      );
    }
    return Text(
      _enteredPin.isEmpty ? '' : '${_enteredPin.length}/6 digits',
      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
    );
  }

  Widget _buildNumberPad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          _buildNumberRow(['1', '2', '3']),
          _buildNumberRow(['4', '5', '6']),
          _buildNumberRow(['7', '8', '9']),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 72),
              _buildKey('0'),
              _buildBackspaceKey(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildKey(d)).toList(),
    );
  }

  Widget _buildKey(String digit) {
    return GestureDetector(
      onTap: _isLockedOut ? null : () => _onPinDigit(digit),
      child: Container(
        width: 72,
        height: 72,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(36),
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return GestureDetector(
      onTap: _isLockedOut ? null : _onBackspace,
      child: Container(
        width: 72,
        height: 72,
        margin: const EdgeInsets.all(6),
        alignment: Alignment.center,
        child: Icon(
          Icons.backspace_outlined,
          color: Colors.white.withOpacity(0.6),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildPatternLock() {
    return PatternLock(
      onPatternEntered: _onPatternEntered,
      isLockedOut: _isLockedOut,
    );
  }

  Widget _buildBottomOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {
            // TODO: Implement forgot PIN recovery
          },
          child: Text(
            'Forgot PIN?',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOptionIcon(Icons.fingerprint, 'Biometric', () {
              // TODO: Integrate local_auth
            }),
            const SizedBox(width: 24),
            _buildOptionIcon(
              _usePattern ? Icons.grid_on : Icons.pattern,
              _usePattern ? 'PIN' : 'Pattern',
              () => setState(() => _usePattern = !_usePattern),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class PatternLock extends StatefulWidget {
  final void Function(List<int> pattern) onPatternEntered;
  final bool isLockedOut;

  const PatternLock({
    super.key,
    required this.onPatternEntered,
    this.isLockedOut = false,
  });

  @override
  State<PatternLock> createState() => _PatternLockState();
}

class _PatternLockState extends State<PatternLock> {
  final List<int> _selected = [];

  void _onNodeTap(int index) {
    if (widget.isLockedOut) return;
    if (_selected.contains(index)) return;
    setState(() => _selected.add(index));
    if (_selected.length >= 4) {
      widget.onPatternEntered(List.from(_selected));
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _selected.clear());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final isSelected = _selected.contains(index);
            return GestureDetector(
              onTap: () => _onNodeTap(index),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? ZenoColors.primary
                      : Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: isSelected
                        ? ZenoColors.primary
                        : Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: isSelected
                    ? Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
