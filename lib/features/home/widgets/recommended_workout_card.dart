import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/home_models.dart';

class RecommendedWorkoutCard extends StatelessWidget {
  final WorkoutItem workout;
  final VoidCallback? onTap;

  const RecommendedWorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = 20.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B1D),
            borderRadius: BorderRadius.circular(borderRadius - 1.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workout Image Banner
              SizedBox(
                height: 125,
                width: double.infinity,
                child: workout.imagePath.startsWith('http')
                    ? Image.network(
                        workout.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF222818),
                          child: const Center(
                            child: Icon(
                              Icons.fitness_center_rounded,
                              color: AppColors.primaryLime,
                              size: 36,
                            ),
                          ),
                        ),
                      )
                    : Image.asset(
                        workout.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF222818),
                          child: const Center(
                            child: Icon(
                              Icons.fitness_center_rounded,
                              color: AppColors.primaryLime,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 13,
                          color: AppColors.primaryLime,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          workout.duration,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(
                          Icons.local_fire_department_outlined,
                          size: 13,
                          color: AppColors.primaryLime,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          workout.calories,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
