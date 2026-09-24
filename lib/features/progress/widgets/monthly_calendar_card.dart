import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/progress_models.dart';

class MonthlyCalendarCard extends StatelessWidget {
  final String monthTitle;
  final List<MonthlyCalendarDay>? days;
  final Set<int>? completedDays;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final ValueChanged<MonthlyCalendarDay>? onDaySelected;

  final int? selectedDay;

  const MonthlyCalendarCard({
    super.key,
    this.monthTitle = 'September 2026',
    this.days,
    this.completedDays,
    this.selectedDay,
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

  List<MonthlyCalendarDay> _generateCalendarDays() {
    if (days != null && days!.isNotEmpty) {
      return days!;
    }

    int year = 2026;
    int month = 9;

    try {
      final parts = monthTitle.split(' ');
      if (parts.length == 2) {
        final monthStr = parts[0].toLowerCase();
        final parsedYear = int.tryParse(parts[1]);
        if (parsedYear != null) year = parsedYear;

        const months = [
          'january', 'february', 'march', 'april', 'may', 'june',
          'july', 'august', 'september', 'october', 'november', 'december'
        ];
        final idx = months.indexOf(monthStr);
        if (idx != -1) month = idx + 1;
      }
    } catch (_) {}

    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final prevMonthDays = DateTime(year, month, 0).day;

    // Sunday = 0, Monday = 1, ..., Saturday = 6
    final startOffset = firstDay.weekday % 7;

    final List<MonthlyCalendarDay> generated = [];

    // Trailing days from previous month
    for (int i = startOffset - 1; i >= 0; i--) {
      generated.add(
        MonthlyCalendarDay(
          dayNumber: prevMonthDays - i,
          isCurrentMonth: false,
          isCompleted: false,
        ),
      );
    }

    // Days of current month
    final today = DateTime.now();
    for (int day = 1; day <= daysInMonth; day++) {
      bool completed = completedDays?.contains(day) ?? false;
      generated.add(
        MonthlyCalendarDay(
          dayNumber: day,
          isCurrentMonth: true,
          isCompleted: completed,
        ),
      );
    }

    // Leading days from next month to complete the grid (multiple of 7)
    final remaining = (7 - (generated.length % 7)) % 7;
    for (int day = 1; day <= remaining; day++) {
      generated.add(
        MonthlyCalendarDay(
          dayNumber: day,
          isCurrentMonth: false,
          isCompleted: false,
        ),
      );
    }

    return generated;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDays = _generateCalendarDays();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF161619),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          // Month navigation bar (Figma UI)
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
                onPressed: onPreviousMonth,
              ),
              Text(
                monthTitle,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
                onPressed: onNextMonth,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Dotted Divider Line (Figma UI)
          CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _DottedLinePainter(),
          ),
          const SizedBox(height: 14),

          // Days of Week Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekDayNames.map((name) {
              return Expanded(
                child: Center(
                  child: Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white60,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Monthly Days Grid (7 columns matching Figma UI)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: effectiveDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 14,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final day = effectiveDays[index];
              return _buildDayItem(day);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(MonthlyCalendarDay day) {
    final bool isSelected = day.isCurrentMonth && selectedDay == day.dayNumber;

    Widget childWidget;
    if (day.isCompleted) {
      childWidget = Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primaryLime,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 2.0)
              : null,
        ),
        child: const Center(
          child: Icon(
            Icons.check_rounded,
            size: 16,
            color: Color(0xFF141416),
          ),
        ),
      );
    } else {
      childWidget = Container(
        width: 28,
        height: 28,
        decoration: isSelected
            ? BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryLime, width: 2.0),
              )
            : null,
        child: Center(
          child: Text(
            '${day.dayNumber}',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
              color: isSelected
                  ? AppColors.primaryLime
                  : (day.isCurrentMonth ? Colors.white : Colors.white38),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDaySelected != null ? () => onDaySelected!(day) : null,
      child: Center(child: childWidget),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
