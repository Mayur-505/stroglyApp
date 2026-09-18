import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/category_workout_models.dart';

class CategoryWorkoutTile extends StatelessWidget {
  final CategoryWorkoutItem item;
  final VoidCallback? onTap;

  const CategoryWorkoutTile({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161619),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
          child: Row(
          children: [
            // Thumbnail Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: SizedBox(
                width: 66,
                height: 66,
                child: item.imagePath.startsWith('http')
                    ? Image.network(
                        item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF1B1B1D),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: Colors.white38,
                            size: 26,
                          ),
                        ),
                      )
                    : Image.asset(
                        item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF1B1B1D),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: Colors.white38,
                            size: 26,
                          ),
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 16),

            // Workout Details (Title + Levels & Duration)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${item.levels} levels',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white54,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '|',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.white30,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.duration,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Right Badge: Free pill or Crown icon
            if (item.isFree)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLime,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  'Free',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF141416),
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.0),
                child: CrownBadgeIcon(
                  size: 20,
                  color: AppColors.primaryLime,
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}

class CrownBadgeIcon extends StatelessWidget {
  final double size;
  final Color color;

  const CrownBadgeIcon({
    super.key,
    this.size = 20,
    this.color = const Color(0xFFA3D223),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.8),
      painter: _CrownPainter(color),
    );
  }
}

class _CrownPainter extends CustomPainter {
  final Color color;

  _CrownPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.14, h * 0.95)
      ..lineTo(w * 0.86, h * 0.95)
      ..lineTo(w * 0.98, h * 0.32)
      ..lineTo(w * 0.68, h * 0.62)
      ..lineTo(w * 0.50, h * 0.18)
      ..lineTo(w * 0.32, h * 0.62)
      ..lineTo(w * 0.02, h * 0.32)
      ..close();
    canvas.drawPath(path, paint);

    // Small circular pearls on tips
    final r = w * 0.075;
    canvas.drawCircle(Offset(w * 0.04, h * 0.28), r, paint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.14), r, paint);
    canvas.drawCircle(Offset(w * 0.96, h * 0.28), r, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
