import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import 'profile_setup_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPScreen({super.key, required this.phoneNumber});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());
  int _resendSeconds = 30;
  bool _resendActive = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendActive = false;
    _resendSeconds = 30;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _resendActive = true;
        }
      });
      return _resendSeconds > 0 && mounted;
    });
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  void _onOtpChange(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    final fullOtp = _otpControllers.map((c) => c.text).join();
    if (fullOtp.length == 6) {
      _verifyOTP();
    }
  }

  void _verifyOTP() async {
    final fullOtp = _otpControllers.map((c) => c.text).join();
    if (fullOtp.length < 6) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOTP(
      authProvider.verificationId ?? '',
      fullOtp,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
      );
    } else if (mounted) {
      _shakeController.reset();
      _shakeController.forward();
      for (final c in _otpControllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Invalid OTP. Try again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verify Phone'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.smartphone_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Enter the OTP sent to',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.phoneNumber,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 36),
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (context, _) {
                final offset = _shakeAnim.value * 12.0;
                return Transform.translate(
                  offset: Offset(
                    _shakeAnim.value > 0.5 ? -offset : offset,
                    0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Container(
                        width: 48,
                        height: 56,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _focusNodes[i].hasFocus
                                ? AppColors.primary
                                : AppColors.divider,
                            width: _focusNodes[i].hasFocus ? 2 : 1,
                          ),
                          boxShadow: _focusNodes[i].hasFocus
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: TextField(
                          controller: _otpControllers[i],
                          focusNode: _focusNodes[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                          onChanged: (v) => _onOtpChange(i, v),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
            const SizedBox(height: 36),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _resendActive
                      ? 'Didn\'t receive the code? '
                      : 'Resend OTP in $_resendSeconds s',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                if (_resendActive)
                  TextButton(
                    onPressed: () {
                      context.read<AuthProvider>().sendOTP(widget.phoneNumber);
                      _startResendTimer();
                      for (final c in _otpControllers) {
                        c.clear();
                      }
                      _focusNodes[0].requestFocus();
                    },
                    child: Text(
                      'Resend',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
