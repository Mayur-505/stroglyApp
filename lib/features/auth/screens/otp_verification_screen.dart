import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import 'reset_password_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _startSeconds = 600; // 10 minutes OTP expiration
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _startSeconds = 600); // 10 minutes
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_startSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _startSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text.trim()).join();

  Future<void> _verifyOTP() async {
    final code = _otpCode;
    if (code.length < 6) {
      _showError('Please enter all 6 digits of the OTP code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiClient.instance.post(ApiConstants.otpVerify, {
        'email': widget.email,
        'otp': code,
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res.isOk) {
        final Map? dataMap = res.data is Map ? res.data as Map : null;
        final resetToken = dataMap?['resetToken']?.toString() ??
            dataMap?['data']?['resetToken']?.toString() ??
            res['resetToken']?.toString();

        debugPrint('[OTP Verify] resetToken extracted: $resetToken');

        if (resetToken != null && resetToken.isNotEmpty) {
          for (var c in _controllers) {
            c.clear();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1B1B1D),
              content: Text(
                'OTP verified successfully!',
                style: GoogleFonts.outfit(
                  color: AppColors.primaryLime,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );

          if (!mounted) return;

          // Navigate to Reset Password Screen with resetToken
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(
                resetToken: resetToken,
                email: widget.email,
              ),
            ),
          );
        } else {
          _showError('Invalid verification token');
        }
      } else {
        _showError(res.error ?? res.data?['message']?.toString() ?? 'Invalid OTP code');
      }
    } catch (e) {
      debugPrint('[OTP Verify] Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Connection error. Please try again.');
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_startSeconds > 0) return;

    setState(() => _isResending = true);

    try {
      final res = await ApiClient.instance.post(ApiConstants.resendOtp, {
        'email': widget.email,
      });

      if (!mounted) return;
      setState(() => _isResending = false);

      if (res.isOk) {
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1B1B1D),
            content: Text(
              'A fresh OTP code has been sent to ${widget.email}',
              style: GoogleFonts.outfit(
                color: AppColors.primaryLime,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      } else {
        _showError(res.error ?? res.data?['message']?.toString() ?? 'Failed to resend code');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isResending = false);
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
    final minutes = (_startSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_startSeconds % 60).toString().padLeft(2, '0');
    final timerFormatted = '$minutes:$seconds';

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

              // 3D Glossy Green Envelope Image (Figma UI)
              Image.asset(
                'assets/images/otp_verify.png',
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 28),

              // Title: Verify Your Email
              Text(
                'Verify Your Email',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle with lime email text (Figma UI)
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white60,
                    height: 1.45,
                  ),
                  children: [
                    const TextSpan(text: "We've sent a 6-digit verification code to\n"),
                    TextSpan(
                      text: widget.email,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLime,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // 6 OTP Digit Input Boxes Row (Figma UI)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 54,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      maxLength: 1,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFF1B1B1E),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: const BorderSide(
                            color: AppColors.primaryLime,
                            width: 1.8,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          if (index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            _focusNodes[index].unfocus();
                          }
                        } else if (index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // Resend code countdown timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Resend code in ',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                  Text(
                    timerFormatted,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Verify & Continue Button (Lime Solid Pill)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const ValueKey('verify_otp_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLime,
                    foregroundColor: const Color(0xFF111113),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: _isLoading ? null : _verifyOTP,
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
                          'Verify & Continue',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 28),

              // Didn't receive the code? Resend Code Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                  GestureDetector(
                    onTap: _isResending || _startSeconds > 0 ? null : _resendOTP,
                    child: Text(
                      'Resend Code',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _startSeconds > 0
                            ? Colors.white38
                            : AppColors.primaryLime,
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
