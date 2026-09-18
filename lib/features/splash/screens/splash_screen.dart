import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/strongly_logo.dart';
import '../widgets/splash_loader.dart';
import '../../../core/services/preference_service.dart';
import '../../../core/services/language_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/auth_session_manager.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../home/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();

    // Initialize guest session in background if not authenticated
    if (!AuthSessionManager.instance.isAuthenticated) {
      ApiClient.instance.post(
        ApiConstants.guestLogin,
        {'language': LanguageService.instance.currentLanguage},
      ).then((res) {
        if (res.isOk && res.data is Map) {
          final token = res.data['token']?.toString();
          final user = res.data['user'];
          if (token != null && user != null) {
            AuthSessionManager.instance.saveSession(
              token: token,
              userId: user['_id']?.toString() ?? '',
              isGuest: true,
              name: user['name']?.toString(),
            );
          }
        }
      }).catchError((_) => null);
    }

    // Auto-navigate to OnboardingScreen (for first-timers) or HomeScreen
    _navTimer = Timer(const Duration(milliseconds: 2800), () async {
      if (!mounted) return;
      final isCompleted = await PreferenceService.isOnboardingCompleted();
      if (!mounted) return;

      final Widget destination =
          isCompleted ? const HomeScreen() : const OnboardingScreen();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Edge-to-edge transparent system overlays
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Athlete Image with seamless lower-body fade to pure black
          Positioned(
            top: size.height * 0.04,
            left: 0,
            right: 0,
            height: size.height * 0.70,
            child: ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.45, 0.70, 0.95],
                  colors: [
                    Colors.white,
                    Colors.white,
                    Color(0x99FFFFFF),
                    Colors.transparent,
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                AppAssets.athleteSplash,
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),

          // 2. Figma Frame 2 Linear Gradient Overlay
          // background: linear-gradient(180deg, rgba(163, 210, 35, 0) 0%, #A3D223 100%);
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.38,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00A3D223), // rgba(163, 210, 35, 0)
                    Color(0xFFA3D223), // #A3D223
                  ],
                ),
              ),
            ),
          ),

          // 3. Logo & Tagline
          Positioned(
            left: 0,
            right: 0,
            bottom: size.height * 0.22,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const StronglyLogo(
                      fontSize: 60,
                      letterSpacing: 0.0,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Become Your Strongest.',
                      style: AppTextStyles.tagline(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Custom Arc Spinner
          Positioned(
            left: 0,
            right: 0,
            bottom: size.height * 0.08,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Center(
                child: SplashLoader(
                  size: 26,
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
