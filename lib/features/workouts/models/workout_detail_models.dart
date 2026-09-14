class WorkoutDayItem {
  final int dayNumber;
  final String duration;
  final double progress; // 0.0 to 1.0
  final bool isUnlocked;
  final bool isCompleted;

  const WorkoutDayItem({
    required this.dayNumber,
    required this.duration,
    this.progress = 0.0,
    this.isUnlocked = false,
    this.isCompleted = false,
  });

  bool get isInProgress => isUnlocked && !isCompleted && progress > 0;

  WorkoutDayItem copyWith({
    int? dayNumber,
    String? duration,
    double? progress,
    bool? isUnlocked,
    bool? isCompleted,
  }) {
    return WorkoutDayItem(
      dayNumber: dayNumber ?? this.dayNumber,
      duration: duration ?? this.duration,
      progress: progress ?? this.progress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class WorkoutDetailData {
  final String id;
  final String title;
  final String heroImage;
  final int totalDays;
  final String dailyDuration;
  final int strengthLevel; // 0 to 3
  final int cardioLevel; // 0 to 3
  final String descriptionParagraph1;
  final String descriptionParagraph2;
  final List<WorkoutDayItem> days;

  const WorkoutDetailData({
    required this.id,
    required this.title,
    required this.heroImage,
    this.totalDays = 30,
    this.dailyDuration = '8-15',
    this.strengthLevel = 2,
    this.cardioLevel = 2,
    required this.descriptionParagraph1,
    required this.descriptionParagraph2,
    required this.days,
  });
}
