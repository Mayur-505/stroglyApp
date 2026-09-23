import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import 'otp_verification_screen.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _sendVerificationCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('Please enter your email address');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiClient.instance.post(ApiConstants.forgotPassword, {
        'email': email,
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res.isOk) {
        _emailController.clear();

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1B1B1D),
            content: Text(
              'Verification code sent to your email!',
              style: GoogleFonts.outfit(
                color: AppColors.primaryLime,
                fontWeight: FontWeight.w600,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16.0),
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to OTP Verification screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OTPVerificationScreen(email: email),
          ),
        );
      } else {
        _showError(res.error ?? res.data?['message']?.toString() ?? 'Failed to send verification code');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Connection error. Please try again.');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2C1414),
        content: Text(
          message,
          style: GoogleFonts.outfit(
            color: const Color(0xFFFF5B5B),
            fontWeight: FontWeight.w600,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16.0),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar with Back Arrow
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3D Hand holding Phone & Security Lock Image (Figma UI)
              Image.asset(
                'assets/images/forgot_password.png',
                height: 160,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 28),

              // Forgot Password Title (Figma UI)
              Text(
                'Forgot Password?',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle (Figma UI)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'No worries! Enter your registered email address and we’ll send you a verification code to reset your password.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white60,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Email Input Field (Figma Pill Container)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161619),
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1.0,
                  ),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlignVertical: TextAlignVertical.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    hintText: 'Enter your email',
                    hintStyle: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white38,
                    ),
                    prefixIcon: const Icon(
                      Icons.mail_outline_rounded,
                      color: Colors.white54,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Send Verification Code Button (Lime Solid Pill)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const ValueKey('send_verification_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLime,
                    foregroundColor: const Color(0xFF111113),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: _isLoading ? null : _sendVerificationCode,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF111113),
                          ),
                        )
                      : Text(
                          'Send Verification Code',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 36),

              // Remember your password? Sign In Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Remember your password? ',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white60,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLime,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
