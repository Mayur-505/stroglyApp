import '../models/workout_models.dart';

class WorkoutMockData {
  static const List<MuscleGroupItem> muscleGroupsRow1 = [
    MuscleGroupItem(
      id: 'abs',
      title: 'ABS',
      workoutCount: '11 Workouts',
      imagePath: 'assets/images/muscle_abs.jpg',
    ),
    MuscleGroupItem(
      id: 'leg',
      title: 'LEG',
      workoutCount: '6 Workouts',
      imagePath: 'assets/images/muscle_leg.jpg',
    ),
    MuscleGroupItem(
      id: 'full_body',
      title: 'FULL\nBODY',
      workoutCount: '13 Workouts',
      imagePath: 'assets/images/muscle_fullbody.jpg',
    ),
    MuscleGroupItem(
      id: 'shoulder',
      title: 'SHOULDER',
      workoutCount: '7 Workouts',
      imagePath: 'assets/images/muscle_shoulder.jpg',
    ),
  ];

  static const List<MuscleGroupItem> muscleGroupsRow2 = [
    MuscleGroupItem(
      id: 'chest',
      title: 'CHEST',
      workoutCount: '5 Workouts',
      imagePath: 'assets/images/muscle_chest.jpg',
    ),
    MuscleGroupItem(
      id: 'back',
      title: 'BACK',
      workoutCount: '8 Workouts',
      imagePath: 'assets/images/muscle_back.jpg',
    ),
    MuscleGroupItem(
      id: 'arm',
      title: 'ARM',
      workoutCount: '13 Workouts',
      imagePath: 'assets/images/muscle_arm.jpg',
    ),
    MuscleGroupItem(
      id: 'core',
      title: 'CORE',
      workoutCount: '10 Workouts',
      imagePath: 'assets/images/need_core.jpg',
    ),
  ];

  static const List<TargetFocusItem> targetFocusList = [
    TargetFocusItem(
      id: 'lose_weight',
      title: 'LOSE WEIGHT',
      workoutCount: '13 Workouts',
      imagePath: 'assets/images/target_lose_weight.jpg',
    ),
    TargetFocusItem(
      id: 'build_muscle',
      title: 'BUILD MUSCLE',
      workoutCount: '15 Workouts',
      imagePath: 'assets/images/target_build_muscle.jpg',
    ),
    TargetFocusItem(
      id: 'stretch',
      title: 'STRETCH',
      workoutCount: '4 Workouts',
      imagePath: 'assets/images/target_stretch.jpg',
    ),
    TargetFocusItem(
      id: 'endurance',
      title: 'ENDURANCE',
      workoutCount: '10 Workouts',
      imagePath: 'assets/images/target_endurance.jpg',
    ),
    TargetFocusItem(
      id: 'core_power',
      title: 'CORE POWER',
      workoutCount: '8 Workouts',
      imagePath: 'assets/images/target_core.jpg',
    ),
  ];

  static const List<QuickWorkoutItem> guessYouNeedList = [
    QuickWorkoutItem(
      id: 'hiit',
      title: 'HIIT',
      workoutCount: '5 Workouts',
      imagePath: 'assets/images/need_hiit.jpg',
    ),
    QuickWorkoutItem(
      id: 'build_muscle',
      title: 'Build muscle',
      workoutCount: '8 Workouts',
      imagePath: 'assets/images/need_muscle.jpg',
    ),
    QuickWorkoutItem(
      id: 'stretch_need',
      title: 'Stretch',
      workoutCount: '5 Workouts',
      imagePath: 'assets/images/need_stretch.jpg',
    ),
    QuickWorkoutItem(
      id: 'leg_need',
      title: 'Leg',
      workoutCount: '6 Workouts',
      imagePath: 'assets/images/need_leg.jpg',
    ),
    QuickWorkoutItem(
      id: 'core_blast',
      title: 'Core Blast',
      workoutCount: '10 Workouts',
      imagePath: 'assets/images/need_core.jpg',
    ),
    QuickWorkoutItem(
      id: 'cardio_rush',
      title: 'Cardio Rush',
      workoutCount: '7 Workouts',
      imagePath: 'assets/images/need_cardio.jpg',
    ),
    QuickWorkoutItem(
      id: 'arm_sculpt',
      title: 'Arm Sculpt',
      workoutCount: '9 Workouts',
      imagePath: 'assets/images/need_arms.jpg',
    ),
    QuickWorkoutItem(
      id: 'recovery',
      title: 'Recovery',
      workoutCount: '4 Workouts',
      imagePath: 'assets/images/need_recovery.jpg',
    ),
  ];
}
