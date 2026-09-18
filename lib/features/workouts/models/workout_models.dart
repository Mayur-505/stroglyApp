class MuscleGroupItem {
  final String id;
  final String title;
  final String workoutCount;
  final String imagePath;

  const MuscleGroupItem({
    required this.id,
    required this.title,
    required this.workoutCount,
    required this.imagePath,
  });

  factory MuscleGroupItem.fromJson(Map<String, dynamic> json) {
    return MuscleGroupItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      workoutCount: json['workoutCount']?.toString() ?? '10 Workouts',
      imagePath: json['imagePath']?.toString() ?? 'assets/images/muscle_abs.jpg',
    );
  }
}

class TargetFocusItem {
  final String id;
  final String title;
  final String workoutCount;
  final String imagePath;

  const TargetFocusItem({
    required this.id,
    required this.title,
    required this.workoutCount,
    required this.imagePath,
  });

  factory TargetFocusItem.fromJson(Map<String, dynamic> json) {
    return TargetFocusItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      workoutCount: json['workoutCount']?.toString() ?? '10 Workouts',
      imagePath: json['imagePath']?.toString() ?? 'assets/images/target_lose_weight.jpg',
    );
  }
}

class QuickWorkoutItem {
  final String id;
  final String title;
  final String workoutCount;
  final String imagePath;

  const QuickWorkoutItem({
    required this.id,
    required this.title,
    required this.workoutCount,
    required this.imagePath,
  });

  factory QuickWorkoutItem.fromJson(Map<String, dynamic> json) {
    return QuickWorkoutItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      workoutCount: json['workoutCount']?.toString() ?? '5 Workouts',
      imagePath: json['imagePath']?.toString() ?? 'assets/images/need_hiit.jpg',
    );
  }
}
