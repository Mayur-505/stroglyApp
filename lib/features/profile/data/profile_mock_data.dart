import 'package:flutter/material.dart';
import '../models/profile_models.dart';

class ProfileMockData {
  static const List<ProfileSettingItem> settings = [
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
    ProfileSettingItem(
      id: 'language',
      title: 'Language',
      icon: Icons.translate_rounded,
    ),
    ProfileSettingItem(
      id: 'rate_us',
      title: 'Rate Us',
      icon: Icons.star_rounded,
    ),
  ];

  static const List<PremiumBenefitItem> premiumBenefits = [
    PremiumBenefitItem(
      id: 'b1',
      text: 'Step-by-Step Video Coaching',
    ),
    PremiumBenefitItem(
      id: 'b2',
      text: 'Workouts Made Just for You',
    ),
    PremiumBenefitItem(
      id: 'b3',
      text: '100+ Home Workouts',
    ),
    PremiumBenefitItem(
      id: 'b4',
      text: 'Train Without Interruptions',
    ),
    PremiumBenefitItem(
      id: 'b5',
      text: 'Enjoy an Ad-Free Experience',
    ),
  ];

  static const List<SubscriptionTermItem> subscriptionTerms = [
    SubscriptionTermItem(
      numberTitle: '1. Auto-Renewal',
      description:
          'Your subscription automatically renews at the end of each billing period unless canceled before the renewal date.',
    ),
    SubscriptionTermItem(
      numberTitle: '2. Secure Payment',
      description:
          'All payments are processed securely through trusted payment providers. We never store your payment details.',
    ),
    SubscriptionTermItem(
      numberTitle: '3. Cancel Anytime',
      description:
          'You can cancel your subscription anytime. Your Premium benefits will remain active until the current billing period ends.',
    ),
    SubscriptionTermItem(
      numberTitle: '4. Refund Policy',
      description:
          'Payments are generally non-refundable. Refund requests may be considered according to our refund policy and applicable terms.',
    ),
  ];
}
