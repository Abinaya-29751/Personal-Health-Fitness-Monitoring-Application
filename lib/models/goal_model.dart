// lib/models/goal_model.dart
class Goal {
  final int? id;
  final String title;
  final String description;
  final String category; // e.g., 'steps', 'weight', 'workout'
  final double target;
  final double current;
  final String unit; // e.g., 'steps', 'kg', 'sessions'
  final DateTime startDate;
  final DateTime endDate;
  final bool completed;

  Goal({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.target,
    required this.current,
    required this.unit,
    required this.startDate,
    required this.endDate,
    this.completed = false,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      target: json['target'],
      current: json['current'],
      unit: json['unit'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'target': target,
      'current': current,
      'unit': unit,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'completed': completed,
    };
  }

  double get progress => current / target;

  Goal copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    double? target,
    double? current,
    String? unit,
    DateTime? startDate,
    DateTime? endDate,
    bool? completed,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      target: target ?? this.target,
      current: current ?? this.current,
      unit: unit ?? this.unit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      completed: completed ?? this.completed,
    );
  }
}