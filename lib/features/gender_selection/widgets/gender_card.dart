import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class GenderCard extends StatelessWidget {
  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isMale;

  const GenderCard({
    super.key,
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
    this.isMale = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        height: 135,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isSelected
                ? const [
                    Color(0xFFA3D223),
                    Color(0x66A3D223),
                  ]
                : const [
                    Color(0xFFA3D223),
                    Color(0x00A3D223),
                  ],
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryLime.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(1.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(19.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Semicircle / Dome background on bottom-left
              Positioned(
                left: 14,
                bottom: 0,
                child: Container(
                  width: 125,
                  height: 75,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLime
                        : const Color(0xFF26390E),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(75),
                      topRight: Radius.circular(75),
                    ),
                  ),
                ),
              ),

              // Athlete cutout image on the left
              Positioned(
                left: isMale ? 18 : 22,
                bottom: 0,
                top: 8,
                width: 125,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),

              // Text Label on the right
              Positioned(
                right: 36,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? AppColors.primaryLime : Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
