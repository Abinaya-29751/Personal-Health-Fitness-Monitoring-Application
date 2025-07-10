// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // App info
  static const String appName = 'Fitness Tracker';
  static const String appVersion = '1.0.0';

  // Navigation routes
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String dashboardRoute = '/dashboard';
  static const String workoutRoute = '/workout';
  static const String activityRoute = '/activity';
  static const String profileRoute = '/profile';
  static const String goalsRoute = '/goals';

  // Shared preferences keys
  static const String userPrefKey = 'user_data';
  static const String themeModePrefKey = 'theme_mode';
  static const String rememberMePrefKey = 'remember_me';

  // Workout categories
  static const List<String> workoutCategories = [
    'Strength Training',
    'Cardio',
    'HIIT',
    'Yoga',
    'Pilates',
    'Flexibility',
    'Calisthenics',
    'Sports',
    'Other'
  ];

  // Goal categories
  static const List<String> goalCategories = [
    'Steps',
    'Weight',
    'Workouts',
    'Distance',
    'Active Minutes',
    'Calories Burned'
  ];

  // Units
  static const Map<String, String> goalUnits = {
    'Steps': 'steps',
    'Weight': 'kg',
    'Workouts': 'sessions',
    'Distance': 'km',
    'Active Minutes': 'minutes',
    'Calories Burned': 'calories'
  };

  // Animation durations
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration splashScreenDuration = Duration(seconds: 2);

  // Colors
  static const Color primaryDarkColor = Color(0xFF4A148C);
  static const Color primaryLightColor = Color(0xFFE1BEE7);
  static const Color accentColor = Color(0xFF00BCD4);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);

  // Workout difficulty levels
  static const List<String> difficultyLevels = ['Beginner', 'Intermediate', 'Advanced'];

  // Default goal values
  static const int defaultStepGoal = 10000;
  static const int defaultActiveMinutesGoal = 30;
  static const int defaultWorkoutsPerWeekGoal = 3;

  // Widget sizes
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonHeight = 48.0;
  static const double iconSize = 24.0;

  // Text styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
  );

  static const TextStyle smallStyle = TextStyle(
    fontSize: 14,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
}