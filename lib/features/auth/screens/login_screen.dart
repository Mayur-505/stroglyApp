import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/auth_session_manager.dart';
import '../../home/screens/home_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiClient.instance.post(ApiConstants.login, {
        'email': email,
        'password': password,
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res.isOk && res.data is Map) {
        final token = res.data['token']?.toString() ?? res.data['data']?['token']?.toString();
        final user = res.data['user'] ?? res.data['data']?['user'];
        final userId = user != null ? user['_id']?.toString() ?? '' : '';
        final userName = user != null ? user['name']?.toString() : null;
        final userEmail = user != null ? user['email']?.toString() : email;

        if (token != null && token.isNotEmpty) {
          await AuthSessionManager.instance.saveSession(
            token: token,
            userId: userId,
            isGuest: false,
            name: userName,
            email: userEmail,
          );

          _emailController.clear();
          _passwordController.clear();

          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF1B1B1D),
                content: Text(
                  'Welcome back, ${userName ?? 'Athlete'}!',
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
          _showError(res.data['message']?.toString() ?? 'Login failed. Please try again.');
        }
      } else {
        final errorMsg = res.error ?? res.data?['message']?.toString() ?? 'Invalid email or password';
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
                  key: const ValueKey('login_back_button'),
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

              // Brand Logo & Header Box (Figma UI)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lime Square Icon Box with Running Athlete
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

                  // Brand Text Column
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
              const SizedBox(height: 44),

              // Welcome Back Title & Subtitle
              Text(
                'Welcome Back!',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Log in to continue to Strongly',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 32),

              // Email Input Field (Figma Pill Shape)
              _buildInputField(
                controller: _emailController,
                hintText: 'Enter your email',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password Input Field (Figma Pill Shape with Obscure Toggle)
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
              const SizedBox(height: 12),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot Password',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Primary Login Button (Lime Pill Button)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const ValueKey('login_submit_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLime,
                    foregroundColor: const Color(0xFF111113),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
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
                          'Login',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 28),

              // Or Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.12),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'or',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.12),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Google Social Login Button (Figma Dark Pill)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF161619),
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF1B1B1D),
                        content: Text(
                          'Google login coming soon!',
                          style: GoogleFonts.outfit(
                            color: AppColors.primaryLime,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google Icon Asset Image (Figma UI)
                      Image.asset(
                        'assets/images/google_icon.png',
                        width: 22,
                        height: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continue with Google',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Don't have an account? Sign up Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
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
                          builder: (_) => const SignupScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign up',
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

  // Reusable Pill Text Input Field with Perfect Vertical Centering
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
