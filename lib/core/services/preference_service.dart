import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String gender;
  int height;
  String heightUnit;
  int weight;
  String weightUnit;
  int age;
  String activityLevel;
  List<String> goals;
  String workoutPlace;
  String fitnessLevel;
  String duration;
  String trainingDays;

  UserProfile({
    this.gender = 'Male',
    this.height = 175,
    this.heightUnit = 'CM',
    this.weight = 75,
    this.weightUnit = 'Kg',
    this.age = 25,
    this.activityLevel = 'Moderate',
    List<String>? goals,
    this.workoutPlace = 'Home',
    this.fitnessLevel = 'Beginner',
    this.duration = '30 min',
    this.trainingDays = '5 Days',
  }) : goals = goals != null
            ? List<String>.from(goals)
            : ['Lose Weight', 'Six Pack', 'Stay Active'];

  Map<String, dynamic> toMap() => {
        'gender': gender,
        'height': height,
        'heightUnit': heightUnit,
        'weight': weight,
        'weightUnit': weightUnit,
        'age': age,
        'activityLevel': activityLevel,
        'goals': goals,
        'workoutPlace': workoutPlace,
        'fitnessLevel': fitnessLevel,
        'duration': duration,
        'trainingDays': trainingDays,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        gender: map['gender'] ?? 'Male',
        height: map['height'] ?? 175,
        heightUnit: map['heightUnit'] ?? 'CM',
        weight: map['weight'] ?? 75,
        weightUnit: map['weightUnit'] ?? 'Kg',
        age: map['age'] ?? 25,
        activityLevel: map['activityLevel'] ?? 'Moderate',
        goals: List<String>.from(map['goals'] ?? ['Lose Weight', 'Six Pack']),
        workoutPlace: map['workoutPlace'] ?? 'Home',
        fitnessLevel: map['fitnessLevel'] ?? 'Beginner',
        duration: map['duration'] ?? '30 min',
        trainingDays: map['trainingDays'] ?? '5 Days',
      );
}

class PreferenceService {
  PreferenceService._();

  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyUserProfile = 'user_profile';

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, value);
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(profile.toMap());
    await prefs.setString(_keyUserProfile, jsonStr);
  }

  static Future<UserProfile> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyUserProfile);
    if (jsonStr == null || jsonStr.isEmpty) {
      return UserProfile();
    }
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserProfile.fromMap(map);
    } catch (_) {
      return UserProfile();
    }
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
