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

  factory WorkoutCategory.fromJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ?? '';
    final rawName = json['name']?.toString() ?? '';
    final iconStr = (json['icon']?.toString() ?? '').toLowerCase();
    final idLower = rawId.toLowerCase();

    IconData iconData;
    if (iconStr.contains('home') || idLower.contains('home')) {
      iconData = Icons.home_rounded;
    } else if (iconStr.contains('fire') || iconStr.contains('burn') || idLower.contains('burn')) {
      iconData = Icons.local_fire_department_rounded;
    } else if (iconStr.contains('bolt') || iconStr.contains('strength') || idLower.contains('strength')) {
      iconData = Icons.bolt_rounded;
    } else if (iconStr.contains('self') || iconStr.contains('yoga') || idLower.contains('yoga') || idLower.contains('stretch')) {
      iconData = Icons.self_improvement_rounded;
    } else if (idLower.contains('full') || idLower.contains('body')) {
      iconData = Icons.accessibility_new_rounded;
    } else if (idLower.contains('abs') || idLower.contains('core')) {
      iconData = Icons.sports_gymnastics_rounded;
    } else {
      iconData = Icons.fitness_center;
    }

    String formattedName = rawName;
    if (formattedName.isEmpty || formattedName == rawId) {
      formattedName = rawId
          .replaceAll('_', ' ')
          .split(' ')
          .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
          .join(' ');
    }

    return WorkoutCategory(
      id: rawId,
      name: formattedName,
      icon: iconData,
    );
  }
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

  factory WorkoutItem.fromJson(Map<String, dynamic> json) {
    return WorkoutItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '20 min',
      calories: json['calories']?.toString() ?? '200 kcal',
      level: json['level']?.toString(),
      imagePath: json['imagePath']?.toString() ?? 'assets/images/featured_workout.jpg',
      isFeatured: json['isFeatured'] == true,
    );
  }
}

class HomeNavItem {
  final String label;
  final IconData icon;

  const HomeNavItem({
    required this.label,
    required this.icon,
  });
}

const List<HomeNavItem> appNavItems = [
  HomeNavItem(label: 'Home', icon: Icons.home_rounded),
  HomeNavItem(label: 'Workout', icon: Icons.fitness_center_rounded),
  HomeNavItem(label: 'Progress', icon: Icons.insights_rounded),
  HomeNavItem(label: 'Profile', icon: Icons.person_outline_rounded),
];
