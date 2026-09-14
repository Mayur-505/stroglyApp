import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/progress_models.dart';

class WeeklyCalendarCard extends StatelessWidget {
  final List<DayStatusItem> days;
  final VoidCallback? onTap;

  const WeeklyCalendarCard({
    super.key,
    required this.days,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF161619),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((day) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Day letter (S, M, T, W, T, F, S)
              Text(
                day.dayName,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 12),

              // Date number or completed checkmark
              day.isCompleted
                  ? Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLime,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF141416),
                        size: 18,
                      ),
                    )
                  : SizedBox(
                      width: 28,
                      height: 28,
                      child: Center(
                        child: Text(
                          day.dateText,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ],
          );
        }).toList(),
      ),
    ),
  );
}
}
