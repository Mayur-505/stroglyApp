import 'package:flutter/material.dart';

class WorkoutCategory {
  final String id;
  final String name;
  final IconData icon;

  const WorkoutCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class WorkoutItem {
  final String id;
  final String title;
  final String duration;
  final String calories;
  final String? level;
  final String imagePath;
  final bool isFeatured;

  const WorkoutItem({
    required this.id,
    required this.title,
    required this.duration,
    required this.calories,
    this.level,
    required this.imagePath,
    this.isFeatured = false,
  });
}

class HomeNavItem {
  final String label;
  final IconData icon;

  const HomeNavItem({
    required this.label,
    required this.icon,
  });
}
