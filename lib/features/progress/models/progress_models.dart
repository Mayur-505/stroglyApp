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

  factory DayStatusItem.fromJson(Map<String, dynamic> json) {
    return DayStatusItem(
      dayName: json['dayName']?.toString() ?? '',
      dateText: json['dateText']?.toString() ?? '',
      isCompleted: json['isCompleted'] == true,
      isToday: json['isToday'] == true,
    );
  }
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

  factory ProgressStatItem.fromJson(Map<String, dynamic> json) {
    return ProgressStatItem(
      title: json['title']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      totalValue: json['totalValue']?.toString() ?? '0',
      weekValue: json['weekValue']?.toString() ?? '0',
      iconPath: json['iconPath']?.toString(),
    );
  }
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

  factory WeeklyChartDayData.fromJson(Map<String, dynamic> json) {
    return WeeklyChartDayData(
      dayLabel: json['dayLabel']?.toString() ?? '',
      value: (json['value'] is num)
          ? (json['value'] as num).toDouble()
          : (double.tryParse(json['value']?.toString() ?? '0') ?? 0.0),
      hasActivity: json['hasActivity'] == true,
      isHighlighted: json['isHighlighted'] == true,
    );
  }
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

  factory WeeklyActivityChartData.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'] as List<dynamic>? ?? [];
    return WeeklyActivityChartData(
      metricTitle: json['metricTitle']?.toString() ?? '',
      weeklyAverageText: json['weeklyAverageText']?.toString() ?? '',
      mainValueText: json['mainValueText']?.toString() ?? '',
      days: rawDays
          .map((e) =>
              WeeklyChartDayData.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
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

  factory WorkoutHistoryLogItem.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryLogItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      calories: json['calories']?.toString() ?? '',
    );
  }
}
