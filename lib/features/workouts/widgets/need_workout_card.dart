import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/app_image.dart';
import '../models/workout_models.dart';

class NeedWorkoutCard extends StatelessWidget {
  final QuickWorkoutItem item;
  final VoidCallback? onTap;

  const NeedWorkoutCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1D),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Rounded square thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: SizedBox(
                width: 48,
                height: 48,
                child: AppImage(
                  imagePath: item.imagePath,
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    color: const Color(0xFF242426),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      color: Colors.white38,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.workoutCount,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white60,
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
}
