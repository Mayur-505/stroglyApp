class DayStatusItem {
  final String dayName;
  final String dateText;
  final bool isCompleted;
  final bool isToday;

  const DayStatusItem({
    required this.dayName,
    required this.dateText,
    this.isCompleted = false,
    this.isToday = false,
  });
}

class ProgressStatItem {
  final String title;
  final String unit;
  final String totalValue;
  final String weekValue;
  final String? iconPath;

  const ProgressStatItem({
    required this.title,
    required this.unit,
    required this.totalValue,
    required this.weekValue,
    this.iconPath,
  });
}

class WeeklyChartDayData {
  final String dayLabel;
  final double value;
  final bool hasActivity;
  final bool isHighlighted;

  const WeeklyChartDayData({
    required this.dayLabel,
    required this.value,
    required this.hasActivity,
    this.isHighlighted = false,
  });
}

class WeeklyActivityChartData {
  final String metricTitle;
  final String weeklyAverageText;
  final String mainValueText;
  final List<WeeklyChartDayData> days;

  const WeeklyActivityChartData({
    required this.metricTitle,
    required this.weeklyAverageText,
    required this.mainValueText,
    required this.days,
  });
}

enum ProgressTabType {
  summary,
  history,
}

class MonthlyCalendarDay {
  final int dayNumber;
  final bool isCurrentMonth;
  final bool isCompleted;
  final bool isSelected;

  const MonthlyCalendarDay({
    required this.dayNumber,
    this.isCurrentMonth = true,
    this.isCompleted = false,
    this.isSelected = false,
  });
}

class WorkoutHistoryLogItem {
  final String id;
  final String title;
  final String time;
  final String date;
  final String duration;
  final String calories;

  const WorkoutHistoryLogItem({
    required this.id,
    required this.title,
    required this.time,
    required this.date,
    required this.duration,
    required this.calories,
  });
}
