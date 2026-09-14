class ExerciseDetailItem {
  final String id;
  final String title;
  final String targetArea;
  final String imagePath;
  final String duration;
  final List<String> instructions;
  final List<String> keyTips;

  const ExerciseDetailItem({
    required this.id,
    required this.title,
    required this.targetArea,
    required this.imagePath,
    this.duration = '00:30',
    required this.instructions,
    required this.keyTips,
  });
}
