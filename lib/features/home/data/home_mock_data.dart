import 'package:flutter/material.dart';
import '../models/home_models.dart';

class HomeMockData {
  static const WorkoutItem featuredWorkout = WorkoutItem(
    id: 'full_body_burn',
    title: 'Full Body\nBurn',
    duration: '30 MIN',
    calories: '280 KCAL',
    level: 'BEGINNER',
    imagePath: 'assets/images/featured_workout.jpg',
    isFeatured: true,
  );

  static const List<WorkoutCategory> categories = [
    WorkoutCategory(
      id: 'home_workout',
      name: 'Home Workout',
      icon: Icons.home_rounded,
    ),
    WorkoutCategory(
      id: 'gym_workout',
      name: 'Gym Workout',
      icon: Icons.fitness_center_rounded,
    ),
    WorkoutCategory(
      id: 'fat_burn',
      name: 'Fat Burn',
      icon: Icons.local_fire_department_rounded,
    ),
    WorkoutCategory(
      id: 'strength',
      name: 'Strength',
      icon: Icons.bolt_rounded,
    ),
    WorkoutCategory(
      id: 'yoga',
      name: 'Yoga',
      icon: Icons.self_improvement_rounded,
    ),
  ];

  static const List<WorkoutItem> recommendedWorkouts = [
    WorkoutItem(
      id: 'fat_burn_20',
      title: '20 MIN FAT BURN',
      duration: '20 min',
      calories: '210 kcal',
      imagePath: 'assets/images/workout_fat_burn.jpg',
    ),
    WorkoutItem(
      id: 'abs_and_core',
      title: 'ABS & CORE',
      duration: '15 min',
      calories: '150 kcal',
      imagePath: 'assets/images/workout_abs_core.jpg',
    ),
  ];

  static const List<HomeNavItem> navItems = [
    HomeNavItem(
      label: 'Home',
      icon: Icons.home_rounded,
    ),
    HomeNavItem(
      label: 'Workout',
      icon: Icons.fitness_center_rounded,
    ),
    HomeNavItem(
      label: 'Progress',
      icon: Icons.insights_rounded,
    ),
    HomeNavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
    ),
  ];
}
