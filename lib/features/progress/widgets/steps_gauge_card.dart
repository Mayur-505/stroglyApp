import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class StepsGaugeCard extends StatelessWidget {
  final int currentSteps;
  final int targetSteps;
  final VoidCallback? onTap;

  const StepsGaugeCard({
    super.key,
    required this.currentSteps,
    this.targetSteps = 6000,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (targetSteps > 0)
        ? (currentSteps / targetSteps).clamp(0.0, 1.0)
        : 0.25;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF161619),
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Footprints Icon + "Steps" + Chevron
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Lime footprints / steps icon
                    const Icon(
                      Icons.directions_walk_rounded,
                      color: AppColors.primaryLime,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Steps',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white38,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Semi-circular Arc Gauge
            SizedBox(
              height: 76,
              child: Center(
                child: CustomPaint(
                  size: const Size(120, 75),
                  painter: _StepsArcGaugePainter(progress: progress),
                  child: SizedBox(
                    width: 120,
                    height: 75,
                    child: Align(
                      alignment: const Alignment(0, 0.5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$currentSteps',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'stp',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepsArcGaugePainter extends CustomPainter {
  final double progress;

  _StepsArcGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.95);
    final radius = size.width * 0.44;

    const startAngle = math.pi; // 180 degrees (left)
    const sweepAngle = math.pi; // 180 degrees sweep to right

    // Track Paint (unfilled background arc)
    final trackPaint = Paint()
      ..color = const Color(0xFF28282D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Active Progress Paint (gradient from olive to bright lime)
    final progressSweep = sweepAngle * progress;

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF6B8B18),
          AppColors.primaryLime,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );

    // Thumb indicator (glowing bright lime circle at the tip of progress)
    final thumbAngle = startAngle + progressSweep;
    final thumbCenter = Offset(
      center.dx + radius * math.cos(thumbAngle),
      center.dy + radius * math.sin(thumbAngle),
    );

    final glowPaint = Paint()
      ..color = AppColors.primaryLime.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(thumbCenter, 8.0, glowPaint);

    final thumbPaint = Paint()..color = AppColors.primaryLime;
    canvas.drawCircle(thumbCenter, 5.0, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant _StepsArcGaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
