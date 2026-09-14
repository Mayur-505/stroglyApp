class WorkoutTrainingLocation {
  final String id;
  final String title;
  final String imagePath;

  const WorkoutTrainingLocation({
    required this.id,
    required this.title,
    required this.imagePath,
  });
}

class WorkoutEquipmentChoice {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath;

  const WorkoutEquipmentChoice({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

class WorkoutDifficultyLevel {
  final String id;
  final String title;
  final int filledStars; // 0 to 4

  const WorkoutDifficultyLevel({
    required this.id,
    required this.title,
    required this.filledStars,
  });
}
