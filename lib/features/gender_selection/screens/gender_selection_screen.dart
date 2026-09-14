import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../widgets/gender_card.dart';
import '../../questionnaire/screens/questionnaire_flow_screen.dart';
import '../../../core/services/language_service.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String _selectedGender = 'MEN'; // Default as in Scree105 mockup

  void _onContinue() {
    final gender = _selectedGender == 'MEN' ? 'Male' : 'Female';
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            QuestionnaireFlowScreen(selectedGender: gender),
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

    final figmaHeight = 932.0;
    final frame2Height = size.height * (350.0 / figmaHeight);
    final bottomOverlayHeight = size.height * 0.44;

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Top Section: Gender Selection Cards centered within the black area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: bottomOverlayHeight,
            child: SafeArea(
              bottom: false,
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GenderCard(
                          label: LanguageService.tr('men'),
                          imagePath: AppAssets.maleAthlete,
                          isSelected: _selectedGender == 'MEN',
                          isMale: true,
                          onTap: () {
                            setState(() {
                              _selectedGender = 'MEN';
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        GenderCard(
                          label: LanguageService.tr('women'),
                          imagePath: AppAssets.femaleAthlete,
                          isSelected: _selectedGender == 'WOMEN',
                          isMale: false,
                          onTap: () {
                            setState(() {
                              _selectedGender = 'WOMEN';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Figma Frame 2 Linear Gradient Overlay (matching Splash and Onboarding Screens)
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

          // 3. Bottom Content (Title, Subtitle, and Continue Button) matching Scree102-104 position
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
                    Text(
                      LanguageService.tr('tell_us_about_yourself'),
                      style: GoogleFonts.outfit(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      LanguageService.tr('personalize_fitness_journey'),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _onContinue,
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
                              LanguageService.tr('continue_btn'),
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
