class CategoryWorkoutItem {
  final String id;
  final String title;
  final String category;
  final int levels;
  final String duration;
  final String imagePath;
  final bool isFree;

  const CategoryWorkoutItem({
    required this.id,
    required this.title,
    required this.category,
    required this.levels,
    required this.duration,
    required this.imagePath,
    required this.isFree,
  });
}
