import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/services/language_service.dart';
import '../models/onboarding_item.dart';
import '../widgets/onboarding_indicator.dart';
import '../../language/screens/language_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  List<OnboardingItem> get _pages => [
    OnboardingItem(
      imagePath: AppAssets.onboarding1,
      title: LanguageService.tr('onboarding_1_title'),
      description: LanguageService.tr('onboarding_1_desc'),
    ),
    OnboardingItem(
      imagePath: AppAssets.onboarding2,
      title: LanguageService.tr('onboarding_2_title'),
      description: LanguageService.tr('onboarding_2_desc'),
    ),
    OnboardingItem(
      imagePath: AppAssets.onboarding3,
      title: LanguageService.tr('onboarding_3_title'),
      description: LanguageService.tr('onboarding_3_desc'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    LanguageService.instance.currentLanguageNotifier.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    LanguageService.instance.currentLanguageNotifier.removeListener(_onLanguageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _onGetStarted();
    }
  }

  void _onGetStarted() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LanguageSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    final size = MediaQuery.of(context).size;
    final isLastPage = _currentIndex == _pages.length - 1;

    final figmaHeight = 932.0;
    final frame2Height = size.height * (350.0 / figmaHeight);
    final bottomOverlayHeight = size.height * 0.44;

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. PageView for Background Images with seamless lower fade to black (matching Splash Screen)
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.316, 0.46, 0.603, 1.0],
                  colors: [
                    Colors.white,
                    Colors.white,
                    Color(0x99FFFFFF),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Image.asset(
                    page.imagePath,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: AppColors.backgroundBlack),
                  );
                },
              ),
            ),
          ),

          // 2. Figma Frame 2 Linear Gradient Overlay (matching Splash Screen)
          // background: linear-gradient(180deg, rgba(163, 210, 35, 0) 0%, #A3D223 100%);
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: frame2Height,
            child: IgnorePointer(
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
          ),

          // 3. Bottom Content (Title, Subtitle, Indicators, and Actions)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: bottomOverlayHeight,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Title with smooth animated switch
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        _pages[_currentIndex].title,
                        key: ValueKey<String>(_pages[_currentIndex].title),
                        style: GoogleFonts.outfit(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          height: 1.15,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Subtitle
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        _pages[_currentIndex].description,
                        key: ValueKey<String>(_pages[_currentIndex].description),
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.88),
                          height: 1.35,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bottom Controls Row:
                    // For slides 1 & 2: Indicator on Left, Capsule Arrow Button on Right
                    // For slide 3: Full-width "Get Started →" Button
                    if (!isLastPage)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Page Indicators
                          OnboardingIndicator(
                            count: _pages.length,
                            activeIndex: _currentIndex,
                          ),

                          // Rounded Next Arrow Button
                          GestureDetector(
                            onTap: _onNext,
                            child: Container(
                              width: 64,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(25.0),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      // Final Screen: Full-width "Get Started →" Button (matching Screen 1 & 2 frosted glass style)
                      GestureDetector(
                        onTap: _onGetStarted,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(25.0),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                LanguageService.tr('get_started'),
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
