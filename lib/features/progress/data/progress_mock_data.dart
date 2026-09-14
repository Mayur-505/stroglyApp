import '../models/progress_models.dart';

class ProgressMockData {
  static const List<DayStatusItem> weekDays = [
    DayStatusItem(dayName: 'S', dateText: '30', isCompleted: false),
    DayStatusItem(dayName: 'M', dateText: '1', isCompleted: true),
    DayStatusItem(dayName: 'T', dateText: '2', isCompleted: true),
    DayStatusItem(dayName: 'W', dateText: '3', isCompleted: true, isToday: true),
    DayStatusItem(dayName: 'T', dateText: '3', isCompleted: false),
    DayStatusItem(dayName: 'F', dateText: '4', isCompleted: false),
    DayStatusItem(dayName: 'S', dateText: '5', isCompleted: false),
  ];

  static const ProgressStatItem workoutStat = ProgressStatItem(
    title: 'Workout',
    unit: 'min',
    totalValue: '4',
    weekValue: '4',
  );

  static const ProgressStatItem caloriesStat = ProgressStatItem(
    title: 'Calories',
    unit: 'cal',
    totalValue: '43',
    weekValue: '43',
  );

  static const ProgressStatItem weightStat = ProgressStatItem(
    title: 'Weight',
    unit: 'lbs',
    totalValue: '184.1',
    weekValue: '4',
  );

  static const int currentSteps = 1500;
  static const int targetSteps = 6000;

  static const WeeklyActivityChartData workoutChart = WeeklyActivityChartData(
    metricTitle: 'Workout',
    weeklyAverageText: '1 min',
    mainValueText: '<1 min',
    days: [
      WeeklyChartDayData(dayLabel: 'S', value: 0.0, hasActivity: false),
      WeeklyChartDayData(dayLabel: 'M', value: 0.35, hasActivity: true),
      WeeklyChartDayData(dayLabel: 'T', value: 0.90, hasActivity: true),
      WeeklyChartDayData(
        dayLabel: 'W',
        value: 0.65,
        hasActivity: true,
        isHighlighted: true,
      ),
      WeeklyChartDayData(dayLabel: 'T', value: 0.0, hasActivity: false),
      WeeklyChartDayData(dayLabel: 'F', value: 0.0, hasActivity: false),
      WeeklyChartDayData(dayLabel: 'S', value: 0.0, hasActivity: false),
    ],
  );

  static const WeeklyActivityChartData calorieChart = WeeklyActivityChartData(
    metricTitle: 'Calorie',
    weeklyAverageText: '14 Calories',
    mainValueText: '<1 Calories',
    days: [
      WeeklyChartDayData(dayLabel: 'S', value: 0.0, hasActivity: false),
      WeeklyChartDayData(dayLabel: 'M', value: 0.35, hasActivity: true),
      WeeklyChartDayData(dayLabel: 'T', value: 0.90, hasActivity: true),
      WeeklyChartDayData(
        dayLabel: 'W',
        value: 0.65,
        hasActivity: true,
        isHighlighted: true,
      ),
      WeeklyChartDayData(dayLabel: 'T', value: 0.0, hasActivity: false),
      WeeklyChartDayData(dayLabel: 'F', value: 0.0, hasActivity: false),
      WeeklyChartDayData(dayLabel: 'S', value: 0.0, hasActivity: false),
    ],
  );

  static const List<MonthlyCalendarDay> monthlyDays = [
    // Week 1: Aug 30, Sep 1 (✔), Sep 2 (✔), Sep 3 (✔), Sep 4, Sep 5
    MonthlyCalendarDay(dayNumber: 30, isCurrentMonth: false),
    MonthlyCalendarDay(dayNumber: 1, isCompleted: true),
    MonthlyCalendarDay(dayNumber: 2, isCompleted: true),
    MonthlyCalendarDay(dayNumber: 3, isCompleted: true),
    MonthlyCalendarDay(dayNumber: 3, isCurrentMonth: true),
    MonthlyCalendarDay(dayNumber: 4, isCurrentMonth: true),
    MonthlyCalendarDay(dayNumber: 5, isCurrentMonth: true),

    // Week 2
    MonthlyCalendarDay(dayNumber: 6),
    MonthlyCalendarDay(dayNumber: 7),
    MonthlyCalendarDay(dayNumber: 8),
    MonthlyCalendarDay(dayNumber: 9),
    MonthlyCalendarDay(dayNumber: 10),
    MonthlyCalendarDay(dayNumber: 11),
    MonthlyCalendarDay(dayNumber: 12),

    // Week 3
    MonthlyCalendarDay(dayNumber: 13),
    MonthlyCalendarDay(dayNumber: 14),
    MonthlyCalendarDay(dayNumber: 15),
    MonthlyCalendarDay(dayNumber: 16),
    MonthlyCalendarDay(dayNumber: 17),
    MonthlyCalendarDay(dayNumber: 18),
    MonthlyCalendarDay(dayNumber: 19),

    // Week 4
    MonthlyCalendarDay(dayNumber: 20),
    MonthlyCalendarDay(dayNumber: 21),
    MonthlyCalendarDay(dayNumber: 22),
    MonthlyCalendarDay(dayNumber: 23),
    MonthlyCalendarDay(dayNumber: 24),
    MonthlyCalendarDay(dayNumber: 25),
    MonthlyCalendarDay(dayNumber: 26),

    // Week 5
    MonthlyCalendarDay(dayNumber: 27),
    MonthlyCalendarDay(dayNumber: 28),
    MonthlyCalendarDay(dayNumber: 29),
    MonthlyCalendarDay(dayNumber: 30),
  ];

  static const List<WorkoutHistoryLogItem> workoutHistoryLogs = [
    WorkoutHistoryLogItem(
      id: 'log_1',
      title: 'Full Body Shred Level 1',
      time: '04:13 PM',
      date: 'Sep 5',
      duration: '12:02',
      calories: '80.20',
    ),
    WorkoutHistoryLogItem(
      id: 'log_2',
      title: 'Full Body Shred Level 1',
      time: '01:13 PM',
      date: 'Sep 5',
      duration: '12:02',
      calories: '80.20',
    ),
    WorkoutHistoryLogItem(
      id: 'log_3',
      title: 'Full Body Shred Level 1',
      time: '01:13 PM',
      date: 'Sep 4',
      duration: '12:02',
      calories: '80.20',
    ),
    WorkoutHistoryLogItem(
      id: 'log_4',
      title: 'Full Body Shred Level 1',
      time: '01:13 PM',
      date: 'Sep 3',
      duration: '12:02',
      calories: '80.20',
    ),
    WorkoutHistoryLogItem(
      id: 'log_5',
      title: 'Full Body Shred Level 1',
      time: '01:13 PM',
      date: 'Sep 3',
      duration: '12:02',
      calories: '80.20',
    ),
    WorkoutHistoryLogItem(
      id: 'log_6',
      title: 'Full Body Shred Level 1',
      time: '01:13 PM',
      date: 'Sep 2',
      duration: '12:02',
      calories: '80.20',
    ),
    WorkoutHistoryLogItem(
      id: 'log_7',
      title: 'Full Body Shred Level 1',
      time: '01:13 PM',
      date: 'Sep 1',
      duration: '12:02',
      calories: '80.20',
    ),
  ];
}
