import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/auth_session_manager.dart';
import '../../home/screens/home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = false;
  bool _isLoading = false;

  Future<void> _openWebUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    if (!_agreeTerms) {
      _showError('Please agree to the Terms of Service & Privacy Policy');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Agar current session guest hai to guestId bhejo
      final currentUserId = AuthSessionManager.instance.userId;
      final isCurrentGuest = AuthSessionManager.instance.isGuest;

      final res = await ApiClient.instance.post(ApiConstants.signup, {
        'name': name,
        'email': email,
        'password': password,
        // Guest session hai to same _id se real user banao
        if (isCurrentGuest && currentUserId != null && currentUserId.isNotEmpty)
          'guestId': currentUserId,
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res.isOk && res.data is Map) {
        final token = res.data['token']?.toString() ?? res.data['data']?['token']?.toString();
        final user = res.data['user'] ?? res.data['data']?['user'];
        final userId = user != null ? user['_id']?.toString() ?? '' : '';

        if (token != null && token.isNotEmpty) {
          await AuthSessionManager.instance.saveSession(
            token: token,
            userId: userId,
            isGuest: false,
            name: name,
            email: email,
          );

          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          if (mounted) {
            setState(() => _agreeTerms = false);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF1B1B1D),
                content: Text(
                  'Account created successfully! Welcome, $name',
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

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          }
        } else {
          _showError(res.data['message']?.toString() ?? 'Registration failed. Please try again.');
        }
      } else {
        final errorMsg = res.error ?? res.data?['message']?.toString() ?? 'Failed to create account';
        _showError(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Connection error. Please try again.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2C1414),
        content: Text(
          message,
          style: GoogleFonts.outfit(color: const Color(0xFFFF5B5B)),
        ),
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
              // Top Bar with Back Icon
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
              const SizedBox(height: 20),

              // Brand Logo & Header Box (Figma UI)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLime,
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.directions_run_rounded,
                        color: Colors.black,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'STRONGLY',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryLime,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '✦',
                            style: TextStyle(
                              color: AppColors.primaryLime,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Become Your Strongest.',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Create Account Title & Subtitle (Figma UI)
              Text(
                'Create Account',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign up to get started with your dashboard',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 28),

              // Full Name Field
              _buildInputField(
                controller: _nameController,
                hintText: 'Full name',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),

              // Email Field
              _buildInputField(
                controller: _emailController,
                hintText: 'Enter your email',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              // Password Field
              _buildInputField(
                controller: _passwordController,
                hintText: 'Enter your password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleObscure: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              const SizedBox(height: 14),

              // Confirm Password Field
              _buildInputField(
                controller: _confirmPasswordController,
                hintText: 'Confirm password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onToggleObscure: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
              const SizedBox(height: 18),

              // Checkbox Row (Figma UI)
              GestureDetector(
                onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _agreeTerms ? Colors.white : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _agreeTerms ? Colors.white : Colors.white38,
                          width: 1.5,
                        ),
                      ),
                      child: _agreeTerms
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.black,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _openWebUrl('https://strongly.greewebsolutions.com/terms'),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _openWebUrl('https://strongly.greewebsolutions.com/privacy'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Create Account Primary Button (Lime Pill Button)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const ValueKey('signup_submit_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLime,
                    foregroundColor: const Color(0xFF111113),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleSignup,
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
                          'Create Account',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Already have an account? Log In Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
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
                      'Log In',
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
        keyboardType: keyboardType,
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
