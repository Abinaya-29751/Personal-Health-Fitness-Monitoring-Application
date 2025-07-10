// lib/utils/helpers.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity_model.dart';
import '../models/workout_model.dart';

class AppHelpers {
  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format time
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }

  // Calculate BMI
  static double calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  // Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Normal weight';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  // Calculate calories burned from steps
  static int calculateCaloriesFromSteps(int steps, double weightKg) {
    // A rough estimation: 1 step burns about 0.04 calories for a 70kg person
    final caloriesPerStep = 0.04 * (weightKg / 70);
    return (steps * caloriesPerStep).round();
  }

  // Calculate distance from steps
  static double calculateDistanceFromSteps(int steps, double heightCm) {
    // Average stride length is approximately 0.43 times height
    final strideLength = 0.43 * heightCm / 100; // in meters
    final distanceM = steps * strideLength;
    return distanceM / 1000; // convert to kilometers
  }

  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Format workout duration
  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '$hours hr ${remainingMinutes > 0 ? '$remainingMinutes min' : ''}';
    } else {
      return '$minutes min';
    }
  }

  // Calculate weekly average steps
  static int calculateAverageWeeklySteps(List<Activity> activities) {
    if (activities.isEmpty) return 0;

    int totalSteps = 0;
    for (final activity in activities) {
      totalSteps += activity.steps;
    }

    return (totalSteps / activities.length).round();
  }

  // Get appropriate workout icon based on category
  static IconData getWorkoutIcon(String category) {
    switch (category.toLowerCase()) {
      case 'strength training':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'hiit':
        return Icons.timer;
      case 'yoga':
        return Icons.self_improvement;
      case 'pilates':
        return Icons.accessibility_new;
      case 'flexibility':
        return Icons.extension;
      case 'calisthenics':
        return Icons.sports_gymnastics;
      case 'sports':
        return Icons.sports_basketball;
      default:
        return Icons.sports;
    }
  }

  // Get appropriate goal icon based on category
  static IconData getGoalIcon(String category) {
    switch (category.toLowerCase()) {
      case 'steps':
        return Icons.directions_walk;
      case 'weight':
        return Icons.monitor_weight;
      case 'workouts':
        return Icons.fitness_center;
      case 'distance':
        return Icons.straighten;
      case 'active minutes':
        return Icons.timelapse;
      case 'calories burned':
        return Icons.local_fire_department;
      default:
        return Icons.emoji_events;
    }
  }

  // Get a list of week days (Monday to Sunday)
  static List<String> getWeekDays() {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  }

  // Get a color based on workout intensity
  static Color getIntensityColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // Calculate weekly workout stats
  static Map<String, int> calculateWeeklyWorkoutStats(List<Workout> workouts) {
    int totalWorkouts = 0;
    int totalMinutes = 0;
    int totalCalories = 0;

    for (final workout in workouts) {
      totalWorkouts++;
      totalMinutes += workout.durationMinutes;
      totalCalories += workout.caloriesBurned;
    }

    return {
      'workouts': totalWorkouts,
      'minutes': totalMinutes,
      'calories': totalCalories,
    };
  }

  // Validate email
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  // Validate password strength
  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  // Animation helper
  static Widget slideInTransition(
      Widget child,
      Animation<double> animation,
      {bool fromLeft = true}
      ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(fromLeft ? -1 : 1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  // Generate random pastel color
  static Color generatePastelColor(int seed) {
    final random = seed % 360;
    return HSLColor.fromAHSL(1.0, random.toDouble(), 0.7, 0.8).toColor();
  }
}