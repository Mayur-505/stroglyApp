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

  factory WorkoutDayItem.fromJson(Map<String, dynamic> json) {
    return WorkoutDayItem(
      dayNumber: json['dayNumber'] is int
          ? json['dayNumber']
          : int.tryParse(json['dayNumber']?.toString() ?? '1') ?? 1,
      duration: json['duration']?.toString() ?? '10-20 min',
      progress: (json['progress'] is num)
          ? (json['progress'] as num).toDouble()
          : (double.tryParse(json['progress']?.toString() ?? '0') ?? 0.0),
      isUnlocked: json['isUnlocked'] == true,
      isCompleted: json['isCompleted'] == true,
    );
  }

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

  factory WorkoutDetailData.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'] as List<dynamic>? ?? [];
    return WorkoutDetailData(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Workout Plan',
      heroImage: json['heroImage']?.toString() ?? 'assets/images/featured_workout.jpg',
      totalDays: json['totalDays'] is int
          ? json['totalDays']
          : int.tryParse(json['totalDays']?.toString() ?? '30') ?? 30,
      dailyDuration: json['dailyDuration']?.toString() ?? '8-15',
      strengthLevel: json['strengthLevel'] is int
          ? json['strengthLevel']
          : int.tryParse(json['strengthLevel']?.toString() ?? '2') ?? 2,
      cardioLevel: json['cardioLevel'] is int
          ? json['cardioLevel']
          : int.tryParse(json['cardioLevel']?.toString() ?? '2') ?? 2,
      descriptionParagraph1: json['descriptionParagraph1']?.toString() ?? '',
      descriptionParagraph2: json['descriptionParagraph2']?.toString() ?? '',
      days: rawDays
          .map((e) => WorkoutDayItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
