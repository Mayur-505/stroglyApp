import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../data/progress_mock_data.dart';
import '../models/progress_models.dart';

class MonthlyCalendarCard extends StatelessWidget {
  final String monthTitle;
  final List<MonthlyCalendarDay> days;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final ValueChanged<MonthlyCalendarDay>? onDaySelected;

  const MonthlyCalendarCard({
    super.key,
    this.monthTitle = 'September 2026',
    this.days = ProgressMockData.monthlyDays,
    this.onPreviousMonth,
    this.onNextMonth,
    this.onDaySelected,
  });

  static const List<String> _weekDayNames = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF161619),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          // Month navigation bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white38,
                  size: 20,
                ),
                onPressed: onPreviousMonth ?? () {},
              ),
              Text(
                monthTitle,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white38,
                  size: 20,
                ),
                onPressed: onNextMonth ?? () {},
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Days of Week Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekDayNames.map((name) {
              return Expanded(
                child: Center(
                  child: Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white38,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Monthly Days Grid (7 columns)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 14,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              return _buildDayItem(day);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(MonthlyCalendarDay day) {
    if (day.isCompleted) {
      return Center(
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.primaryLime,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              size: 16,
              color: Color(0xFF141416),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onDaySelected != null ? () => onDaySelected!(day) : null,
      child: Center(
        child: Text(
          '${day.dayNumber}',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: day.isCurrentMonth ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }
}
