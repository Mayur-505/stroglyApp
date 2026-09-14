import '../models/workout_detail_models.dart';

class WorkoutDetailMockData {
  static WorkoutDetailData getFullBodyBurnDetail({String? customTitle, String? customImage}) {
    final title = customTitle ?? 'Full Body Burn';
    final image = customImage ?? 'assets/images/featured_workout.jpg';

    final days = List.generate(30, (index) {
      final dayNumber = index + 1;
      final isUnlocked = dayNumber == 1;
      return WorkoutDayItem(
        dayNumber: dayNumber,
        duration: '09-20 min',
        progress: isUnlocked ? 0.35 : 0.0,
        isUnlocked: isUnlocked,
        isCompleted: false,
      );
    });

    return WorkoutDetailData(
      id: 'full_body_burn',
      title: title,
      heroImage: image,
      totalDays: 30,
      dailyDuration: '8-15',
      strengthLevel: 2,
      cardioLevel: 2,
      descriptionParagraph1:
          'Get ready to move, sweat, and feel stronger with $title a complete workout designed to activate your entire body in just 20 minutes. From powerful lower-body movements to core-focused exercises and upper-body challenges, every move is designed to keep you engaged and your energy high.',
      descriptionParagraph2:
          "No matter where you're starting from, all you need is 20 minutes and the determination to show up. Push through each exercise, challenge your limits, and finish the workout feeling stronger, more energized, and proud of yourself. Your best workout starts with one decision.",
      days: days,
    );
  }
}
