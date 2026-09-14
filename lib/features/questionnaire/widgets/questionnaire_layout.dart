import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/language_service.dart';

class QuestionnaireLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final String? buttonText;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const QuestionnaireLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.buttonText,
    required this.onNext,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topColorHeight = (size.height * 0.35).clamp(310.0, 350.0);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Signature Top Lime to Black Gradient Glow (matching Figma Scree106-112)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topColorHeight,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.35, 0.68, 0.95],
                    colors: [
                      Color(0xFFA3D223), // #A3D223 vibrant brand lime
                      Color(0xB3A3D223), // rich lime covering title
                      Color(0x38A3D223), // smooth transition
                      Color(0x00A3D223), // fades seamlessly into black
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Navigation Bar with polished Back Button
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        if (onBack != null)
                          GestureDetector(
                            onTap: onBack,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1.0,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 40, height: 40),
                      ],
                    ),
                  ),

                  // Generous space above title as requested
                  const SizedBox(height: 18),

                  // Header Section with unified fixed height so EVERY screen starts at the EXACT same line
                  SizedBox(
                    height: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            height: 1.15,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            subtitle!,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Space above options increased as requested
                  const SizedBox(height: 48),

                  // Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: child,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Action Button
                  GestureDetector(
                    onTap: onNext,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181A),
                        borderRadius: BorderRadius.circular(28.0),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            buttonText ?? LanguageService.tr('next'),
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

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
