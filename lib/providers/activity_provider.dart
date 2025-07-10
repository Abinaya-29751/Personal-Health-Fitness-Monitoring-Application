// lib/providers/activity_provider.dart
import 'package:flutter/foundation.dart';
import '../models/activity_model.dart';

class ActivityProvider with ChangeNotifier {
  List<Activity> _activities = [];

  List<Activity> get activities => _activities;

  Activity? get todayActivity {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      return _activities.firstWhere((activity) {
        final activityDate = DateTime(
          activity.date.year,
          activity.date.month,
          activity.date.day,
        );
        return activityDate.isAtSameMomentAs(today);
      });
    } catch (e) {
      return null;
    }
  }

  List<Activity> getActivitiesForWeek() {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - now.weekday + 1);
    final weekEnd = weekStart.add(const Duration(days: 7));

    return _activities.where((activity) {
      return activity.date.isAfter(weekStart) &&
          activity.date.isBefore(weekEnd);
    }).toList();
  }

  void addActivity(Activity activity) {
    _activities.add(activity);
    notifyListeners();
  }

  void updateActivity(Activity activity) {
    final index = _activities.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      _activities[index] = activity;
      notifyListeners();
    }
  }

  void setActivities(List<Activity> activities) {
    _activities = activities;
    notifyListeners();
  }

  // New methods for step counting and activity tracking

  // Initialize today's activity if it doesn't exist
  void initTodayActivity() {
    if (todayActivity == null) {
      final now = DateTime.now();
      final newActivity = Activity(
        id: 'activity_${now.year}_${now.month}_${now.day}',
        date: DateTime(now.year, now.month, now.day),
        steps: 0,
        distanceKm: 0.0,
        caloriesBurned: 0,
        activeMinutes: 0,
      );

      addActivity(newActivity);
    }
  }

  // Increment steps count
  void incrementSteps() {
    if (todayActivity == null) {
      initTodayActivity();
    }

    final updatedActivity = todayActivity!.copyWith(
      steps: todayActivity!.steps + 1,
    );

    updateActivity(updatedActivity);
  }

  void updateSteps(int steps) {
    if (todayActivity == null) {
      initTodayActivity();
    }

    final updatedActivity = todayActivity!.copyWith(
      steps: steps,
    );

    updateActivity(updatedActivity);
  }

  // Update distance based on steps
  void updateDistance(double distanceKm) {
    if (todayActivity == null) {
      initTodayActivity();
    }

    final updatedActivity = todayActivity!.copyWith(
      distanceKm: distanceKm,
    );

    updateActivity(updatedActivity);
  }

  // Update calories burned
  void updateCalories(int calories) {
    if (todayActivity == null) {
      initTodayActivity();
    }

    final updatedActivity = todayActivity!.copyWith(
      caloriesBurned: calories,
    );

    updateActivity(updatedActivity);
  }

  // Update active minutes
  void updateActiveMinutes(int minutes) {
    if (todayActivity == null) {
      initTodayActivity();
    }

    final updatedActivity = todayActivity!.copyWith(
      activeMinutes: minutes,
    );

    updateActivity(updatedActivity);
  }

  // Refresh activity data from sensors or health services
  Future<void> refreshActivityData() async {
    // This would typically fetch data from health services
    // For now, just make sure today's activity exists
    initTodayActivity();
    notifyListeners();

    return Future.value();
  }
}