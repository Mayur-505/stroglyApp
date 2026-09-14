import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../data/progress_mock_data.dart';
import '../models/progress_models.dart';

class ProgressSummaryCard extends StatelessWidget {
  final String dateRange;
  final String year;
  final String averageValue;
  final String averageUnit;
  final List<WeeklyChartDayData>? days;

  const ProgressSummaryCard({
    super.key,
    this.dateRange = 'Aug 30 - Sep 5',
    this.year = '2026',
    this.averageValue = '1',
    this.averageUnit = 'Average (min)',
    this.days,
  });

  @override
  Widget build(BuildContext context) {
    final chartDays = days ?? ProgressMockData.workoutChart.days;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateRange,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    year,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    averageValue,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    averageUnit,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dotted Guideline + 7 Day Bars
          SizedBox(
            height: 90,
            child: Stack(
              children: [
                // Dotted Guideline
                Positioned(
                  left: 0,
                  right: 0,
                  top: 36,
                  child: CustomPaint(
                    painter: _SummaryDottedLinePainter(),
                    size: const Size(double.infinity, 1),
                  ),
                ),

                // 7 Day Bars
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: chartDays.map((day) {
                    return _buildDayColumn(day);
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(WeeklyChartDayData day) {
    const maxHeight = 56.0;
    final barHeight = (day.value * maxHeight).clamp(0.0, maxHeight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Bar or Dot
        SizedBox(
          height: maxHeight,
          width: 22,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: day.hasActivity
                ? Container(
                    width: 5.5,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLime,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  )
                : Container(
                    width: 3.5,
                    height: 3.5,
                    margin: const EdgeInsets.only(bottom: 2.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFF424248),
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),

        // Day Label
        Text(
          day.dayLabel,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: day.isHighlighted ? FontWeight.w800 : FontWeight.w500,
            color: day.isHighlighted ? Colors.white : Colors.white38,
          ),
        ),
      ],
    );
  }
}

class _SummaryDottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF28282D)
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
