// lib/models/workout_model.dart
class Workout {
  final int? id;
  final String name;
  final String description;
  final String category; // e.g., 'strength', 'cardio', 'flexibility'
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime date;
  final List<Exercise> exercises;

  Workout({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.date,
    required this.exercises,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      durationMinutes: json['durationMinutes'],
      caloriesBurned: json['caloriesBurned'],
      date: DateTime.parse(json['date']),
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'date': date.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

class Exercise {
  final int? id;
  final String name;
  final String description;
  final String? imageUrl;
  final int sets;
  final int reps;
  final double? weight; // in kg (can be null for bodyweight exercises)

  Exercise({
    this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.sets,
    required this.reps,
    this.weight,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }
}