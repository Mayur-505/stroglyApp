import 'package:flutter/material.dart';

class ProfileSettingItem {
  final String id;
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const ProfileSettingItem({
    required this.id,
    required this.title,
    required this.icon,
    this.onTap,
  });
}

const List<ProfileSettingItem> defaultProfileSettings = [
  /*
  ProfileSettingItem(
    id: 'my_profile_item',
    title: 'My Profile',
    icon: Icons.mood_rounded,
  ),
  ProfileSettingItem(
    id: 'my_workouts',
    title: 'My Workouts',
    icon: Icons.fitness_center_rounded,
  ),
  ProfileSettingItem(
    id: 'general_settings',
    title: 'General Settings',
    icon: Icons.settings_rounded,
  ),
  */
  ProfileSettingItem(
    id: 'language',
    title: 'Language',
    icon: Icons.translate_rounded,
  ),
  /*
  ProfileSettingItem(
    id: 'rate_us',
    title: 'Rate Us',
    icon: Icons.star_rounded,
  ),
  */
  ProfileSettingItem(
    id: 'delete_account',
    title: 'Delete Account',
    icon: Icons.delete_outline_rounded,
  ),
];

class PremiumBenefitItem {
  final String id;
  final String text;

  const PremiumBenefitItem({
    required this.id,
    required this.text,
  });
}

class SubscriptionTermItem {
  final String numberTitle;
  final String description;

  const SubscriptionTermItem({
    required this.numberTitle,
    required this.description,
  });
}
