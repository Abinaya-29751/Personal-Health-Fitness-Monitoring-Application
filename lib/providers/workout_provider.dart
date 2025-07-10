// lib/providers/workout_provider.dart
import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';

class WorkoutProvider with ChangeNotifier {
  List<Workout> _workouts = [];

  List<Workout> get workouts => _workouts;

  // Get workouts for a specific date range
  List<Workout> getWorkoutsByDateRange(DateTime start, DateTime end) {
    return _workouts.where((workout) {
      return workout.date.isAfter(start) && workout.date.isBefore(end);
    }).toList();
  }

  // Get workouts by category
  List<Workout> getWorkoutsByCategory(String category) {
    return _workouts.where((workout) => workout.category == category).toList();
  }

  void addWorkout(Workout workout) {
    _workouts.add(workout);
    notifyListeners();
  }

  void updateWorkout(Workout workout) {
    final index = _workouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      _workouts[index] = workout;
      notifyListeners();
    }
  }

  void deleteWorkout(int id) {
    _workouts.removeWhere((workout) => workout.id == id);
    notifyListeners();
  }

  void setWorkouts(List<Workout> workouts) {
    _workouts = workouts;
    notifyListeners();
  }
}
