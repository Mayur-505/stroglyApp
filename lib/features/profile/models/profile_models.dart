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
