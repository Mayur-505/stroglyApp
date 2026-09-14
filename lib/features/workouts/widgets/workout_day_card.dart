import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/workout_detail_models.dart';

class WorkoutDayCard extends StatelessWidget {
  final WorkoutDayItem item;
  final VoidCallback? onTap;

  const WorkoutDayCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.isUnlocked ? onTap : null,
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF161619),
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Left: DAY and Day Number
            SizedBox(
              width: 44,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAY',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${item.dayNumber}',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Middle: Duration and Progress Bar
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: Colors.white60,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item.duration,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  // Progress capsule
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth * 0.82;
                      final effectiveProgress = item.isCompleted
                          ? 1.0
                          : item.progress.clamp(0.0, 1.0);

                      return Container(
                        width: maxWidth,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF28282D),
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: effectiveProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: (item.isCompleted || item.isInProgress)
                                  ? AppColors.primaryLime
                                  : (item.isUnlocked
                                      ? Colors.white30
                                      : const Color(0xFF28282D)),
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Right: Completed, Continue button, Arrow, or Lock
            if (item.isCompleted)
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryLime.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryLime,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.primaryLime,
                  size: 20,
                ),
              )
            else if (item.isInProgress)
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryLime,
                  borderRadius: BorderRadius.circular(17.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Continue',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF141416),
                  ),
                ),
              )
            else if (item.isUnlocked)
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF242428),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              )
            else
              const Icon(
                Icons.lock_rounded,
                color: Colors.white30,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
