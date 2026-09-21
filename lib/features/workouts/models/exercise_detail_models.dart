class ExerciseDetailItem {
  final String id;
  final String title;
  final String targetArea;
  final String imagePath;
  final String videoUrl;
  final String duration;
  final List<String> instructions;
  final List<String> keyTips;

  const ExerciseDetailItem({
    required this.id,
    required this.title,
    required this.targetArea,
    required this.imagePath,
    this.videoUrl = '',
    this.duration = '00:30',
    required this.instructions,
    required this.keyTips,
  });

  factory ExerciseDetailItem.fromJson(Map<String, dynamic> json) {
    final rawInst = json['instructions'] as List<dynamic>? ?? [];
    final rawTips = json['keyTips'] as List<dynamic>? ?? [];
    return ExerciseDetailItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      targetArea: json['targetArea']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? 'assets/images/jumping_jacks.jpg',
      videoUrl: json['videoUrl']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '00:30',
      instructions: rawInst.map((e) => e.toString()).toList(),
      keyTips: rawTips.map((e) => e.toString()).toList(),
    );
  }
}
