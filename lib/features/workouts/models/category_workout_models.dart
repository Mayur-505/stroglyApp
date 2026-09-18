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

  bool get isLocked => !isFree;

  CategoryWorkoutItem copyWith({
    String? id,
    String? title,
    String? category,
    int? levels,
    String? duration,
    String? imagePath,
    bool? isFree,
  }) {
    return CategoryWorkoutItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      levels: levels ?? this.levels,
      duration: duration ?? this.duration,
      imagePath: imagePath ?? this.imagePath,
      isFree: isFree ?? this.isFree,
    );
  }

  factory CategoryWorkoutItem.fromJson(Map<String, dynamic> json) {
    return CategoryWorkoutItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Full body',
      levels: (json['levelsCount'] as num?)?.toInt() ?? 6,
      duration: json['duration']?.toString() ?? '20 min',
      imagePath: json['imagePath']?.toString() ?? 'assets/images/featured_workout.jpg',
      isFree: json['isFree'] ?? true,
    );
  }
}
