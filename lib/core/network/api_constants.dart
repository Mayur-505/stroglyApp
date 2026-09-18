import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Configurable base URL
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://strongly.be.greewebsolutions.com/api/v1';
    }
    try {
      if (Platform.isAndroid) {
        // 10.0.2.2 maps to host localhost in Android Emulator
        return 'https://strongly.be.greewebsolutions.com/api/v1';
      }
    } catch (_) {}
    return 'https://strongly.be.greewebsolutions.com/api/v1';
  }

  // System & Content
  static const String health = '/health';

  // Auth
  static const String guestLogin = '/auth/guest';
  static const String googleLogin = '/auth/google';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // User Profile
  static const String questionnaire = '/user/questionnaire';
  static const String updateLanguage = '/user/language';
  static const String backup = '/user/backup';
  static const String restore = '/user/restore';

  // Home & Feed
  static const String homeFeed = '/home/feed';

  // Workouts
  static const String exploreWorkouts = '/workouts/explore';
  static const String categoryWorkouts = '/workouts/categories';
  static const String searchTags = '/workouts/search-tags';
  static const String searchWorkouts = '/workouts/search';
  static String customizationOptions(String id) => '/workouts/$id/customization-options';

  // Plans
  static String planDetail(String planId) => '/plans/$planId';
  static String planDayExercises(String planId, int dayNumber) => '/plans/$planId/days/$dayNumber';
  static String completePlanDay(String planId, int dayNumber) => '/plans/$planId/days/$dayNumber/complete';

  // Progress
  static const String progressDashboard = '/progress/dashboard';
  static const String progressHistory = '/progress/history';
  static const String logWeight = '/progress/weight';
  static const String syncSteps = '/progress/steps';

  // Subscriptions
  static const String subscriptionPlans = '/subscriptions/plans';
  static const String verifyPurchase = '/subscriptions/verify';
  static const String subscriptionStatus = '/subscriptions/my-status';
}
