import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String resetToken;
  final String? email;

  const ResetPasswordScreen({
    super.key,
    required this.resetToken,
    this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final newPassword = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showError('Please fill in both password fields');
      return;
    }

    if (newPassword != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    if (newPassword.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiClient.instance.post(ApiConstants.resetPassword, {
        'resetToken': widget.resetToken,
        'newPassword': newPassword,
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res.isOk) {
        _passwordController.clear();
        _confirmPasswordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1B1B1D),
            content: Text(
              'Password reset successfully! Please log in with your new password.',
              style: GoogleFonts.outfit(
                color: AppColors.primaryLime,
                fontWeight: FontWeight.w600,
              ),
            ),
            duration: const Duration(seconds: 4),
          ),
        );

        // Return to Login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => route.isFirst,
        );
      } else {
        _showError(res.error ?? res.data?['message']?.toString() ?? 'Password reset failed');
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

              // 3D Hand Pointing to Password Bar Image (Figma UI)
              Image.asset(
                'assets/images/reset_password.png',
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 28),

              // Title: Create New Password (Figma UI)
              Text(
                'Create New Password',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle (Figma UI)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Your new password must be unique from those previously used.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white60,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // New Password Field (Figma Pill)
              _buildInputField(
                controller: _passwordController,
                hintText: 'Enter new password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleObscure: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              const SizedBox(height: 16),

              // Confirm New Password Field (Figma Pill)
              _buildInputField(
                controller: _confirmPasswordController,
                hintText: 'Confirm new password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onToggleObscure: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
              const SizedBox(height: 32),

              // Reset Password Button (Lime Solid Pill)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const ValueKey('reset_password_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLime,
                    foregroundColor: const Color(0xFF111113),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleResetPassword,
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
                          'Reset Password',
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
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => route.isFirst,
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

  // Pill Text Field
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161619),
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.outfit(
          fontSize: 14,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          hintText: hintText,
          hintStyle: GoogleFonts.outfit(
            fontSize: 14,
            color: Colors.white38,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white54,
            size: 20,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.white54,
                    size: 20,
                  ),
                  onPressed: onToggleObscure,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                )
              : null,
        ),
      ),
    );
  }
}
