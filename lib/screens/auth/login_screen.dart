import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  Country _selectedCountry = Country(
    phoneCode: "91",
    countryCode: "IN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "India",
    example: "India",
    displayName: "India",
    displayNameNoCountryCode: "IN",
    e164Key: "",
  );

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      _shakeError('Please enter a valid phone number');
      return;
    }

    final fullNumber = '+${_selectedCountry.phoneCode}$phone';
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendOTP(fullNumber);

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPScreen(phoneNumber: fullNumber),
        ),
      );
    } else if (mounted) {
      _shakeError(authProvider.error ?? 'Failed to send OTP. Try again.');
    }
  }

  void _shakeError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Enter your phone number',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'GB Chat will send an OTP to verify your number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            onSelect: (country) {
                              setState(() => _selectedCountry = country);
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColors.divider),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${_selectedCountry.flagEmoji} +${_selectedCountry.phoneCode}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _selectedCountry.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: InputDecoration(
                            hintText: 'Phone number',
                            hintStyle: TextStyle(color: AppColors.textHint),
                            border: InputBorder.none,
                            filled: false,
                            counterText: '',
                          ),
                          style: const TextStyle(fontSize: 18),
                          validator: (v) {
                            if (v == null || v.trim().length < 10) {
                              return 'Enter a valid 10-digit number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _sendOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                        ),
                        child: auth.isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('Sending OTP...'),
                                ],
                              )
                            : const Text(
                                'Get OTP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
