import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/home_models.dart';

class FeaturedWorkoutCard extends StatelessWidget {
  final WorkoutItem workout;
  final VoidCallback? onStartWorkout;

  const FeaturedWorkoutCard({
    super.key,
    required this.workout,
    this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = 24.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFA3D223),
            Color(0x00A3D223),
          ],
        ),
      ),
      padding: const EdgeInsets.all(1.0),
      child: Container(
        height: 330,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius - 1.0),
          color: const Color(0xFF1B1B1D),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: workout.imagePath.startsWith('http')
                  ? Image.network(
                      workout.imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF1E2616),
                        child: const Center(
                          child: Icon(
                            Icons.fitness_center_rounded,
                            color: AppColors.primaryLime,
                            size: 64,
                          ),
                        ),
                      ),
                    )
                  : Image.asset(
                      workout.imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF1E2616),
                        child: const Center(
                          child: Icon(
                            Icons.fitness_center_rounded,
                            color: AppColors.primaryLime,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
            ),

            // Gradient Overlay for contrast
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.90),
                    ],
                    stops: const [0.0, 0.35, 0.90],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row
                  Row(
                    children: [
                      if (workout.level != null) ...[
                        _buildBadge(text: workout.level!),
                        const SizedBox(width: 8),
                      ],
                      _buildBadge(
                        icon: Icons.timer_outlined,
                        text: workout.duration,
                      ),
                      const SizedBox(width: 8),
                      _buildBadge(
                        icon: Icons.local_fire_department_outlined,
                        text: workout.calories,
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Title
                  Text(
                    workout.title,
                    style: GoogleFonts.outfit(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.08,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Start Workout Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onStartWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLime,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Start Workout',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({IconData? icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
