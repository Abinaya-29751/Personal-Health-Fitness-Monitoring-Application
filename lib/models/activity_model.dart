// lib/models/activity_model.dart
import 'package:flutter/foundation.dart';

class Activity {
  final String id;
  final DateTime date;
  final int steps;
  final double distanceKm;
  final int caloriesBurned;
  final int activeMinutes;

  Activity({
    required this.id,
    required this.date,
    this.steps = 0,
    this.distanceKm = 0.0,
    this.caloriesBurned = 0,
    this.activeMinutes = 0,
  });

  Activity copyWith({
    String? id,
    DateTime? date,
    int? steps,
    double? distanceKm,
    int? caloriesBurned,
    int? activeMinutes,
  }) {
    return Activity(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      distanceKm: distanceKm ?? this.distanceKm,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      activeMinutes: activeMinutes ?? this.activeMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'steps': steps,
      'distanceKm': distanceKm,
      'caloriesBurned': caloriesBurned,
      'activeMinutes': activeMinutes,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      steps: map['steps'] ?? 0,
      distanceKm: map['distanceKm'] ?? 0.0,
      caloriesBurned: map['caloriesBurned'] ?? 0,
      activeMinutes: map['activeMinutes'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'Activity(id: $id, date: $date, steps: $steps, distanceKm: $distanceKm, caloriesBurned: $caloriesBurned, activeMinutes: $activeMinutes)';
  }
}