import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/progress_models.dart';

class WeeklyBarChartCard extends StatelessWidget {
  final WeeklyActivityChartData chartData;
  final VoidCallback? onTap;

  const WeeklyBarChartCard({
    super.key,
    required this.chartData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
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
          // Top Row: Metric Title + Weekly Average
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chartData.metricTitle,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Weekly Average',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chartData.weeklyAverageText,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Main Highlighted Metric
          Text(
            chartData.mainValueText,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),

          // Chart Area: Dotted Baseline + 7 Day Columns
          Stack(
            alignment: Alignment.center,
            children: [
              // Dotted Horizontal Guideline
              Positioned(
                left: 0,
                right: 0,
                bottom: 38,
                child: SizedBox(
                  height: 1,
                  child: CustomPaint(
                    painter: _DottedLinePainter(),
                  ),
                ),
              ),

              // 7 Day Bars / Dots and Day Letters
              SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: chartData.days.map((dayItem) {
                    return _buildDayColumn(dayItem);
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildDayColumn(WeeklyChartDayData dayItem) {
    const maxBarHeight = 46.0;
    final barHeight = (dayItem.value * maxBarHeight).clamp(14.0, maxBarHeight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Bar or Dot
        SizedBox(
          height: maxBarHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: dayItem.hasActivity
                ? Container(
                    width: 5.0,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLime,
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  )
                : Container(
                    width: 4.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),

        // Day label (S, M, T, W, T, F, S)
        Text(
          dayItem.dayLabel,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight:
                dayItem.isHighlighted ? FontWeight.w800 : FontWeight.w500,
            color: dayItem.isHighlighted
                ? Colors.white
                : Colors.white.withValues(alpha: 0.40),
          ),
        ),
      ],
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite || size.width <= 0) return;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
