import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/goal_model.dart';
import '../providers/user_provider.dart';
import '../services/database_service.dart';
import '../widgets/goal_tracker.dart';
import '../utils/constants.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Goal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final goals = await _databaseService.getGoals();
      setState(() {
        _goals = goals;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteGoal(int? id) async {
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal ID is missing, cannot delete.')),
      );
      return;
    }

    try {
      await _databaseService.deleteGoal(id);
      _loadGoals();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete goal')),
      );
    }
  }

  Future<void> _updateGoalProgress(Goal goal, double newProgress) async {
    try {
      final updatedGoal = goal.copyWith(
        current: newProgress * goal.target,
        completed: newProgress >= 1.0,
      );

      await _databaseService.updateGoal(updatedGoal);
      _loadGoals();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update goal progress')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _goals.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No goals set yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a new goal to track your progress',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showAddGoalDialog(context),
              child: const Text('Add New Goal'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _goals.length,
        itemBuilder: (context, index) {
          final goal = _goals[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          goal.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteGoal(goal.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    goal.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(goal.category),
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatCategory(goal.category),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target: ${goal.target.toStringAsFixed(1)} ${goal.unit}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Current: ${goal.current.toStringAsFixed(1)} ${goal.unit}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GoalTracker(
                    goal: goal,
                    progress: goal.progress,
                    isCompleted: goal.completed,
                    onProgressChanged: (newProgress) {
                      _updateGoalProgress(goal, newProgress);
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Start: ${DateFormat('MMM d').format(goal.startDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'End: ${DateFormat('MMM d').format(goal.endDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatCategory(String category) {
    return category.substring(0, 1).toUpperCase() + category.substring(1);
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'steps':
        return Icons.directions_walk;
      case 'weight':
        return Icons.fitness_center;
      case 'workout':
        return Icons.sports_gymnastics;
      case 'water':
        return Icons.water_drop;
      case 'calories':
        return Icons.local_fire_department;
      default:
        return Icons.emoji_events;
    }
  }

  Future<void> _showAddGoalDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';
    String category = 'steps';
    double target = 0;
    String unit = '';
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));

    // Set default unit based on category
    unit = _getDefaultUnit(category);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Goal'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    title = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    description = value!;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  value: category,
                  items: [
                    'steps',
                    'weight',
                    'workout',
                    'water',
                    'calories'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(_formatCategory(value)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      category = newValue!;
                      unit = _getDefaultUnit(category);
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Target ($unit)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a target value';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    target = double.parse(value!);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Start Date'),
                        subtitle: Text(DateFormat('MMM d, y').format(startDate)),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              startDate = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('End Date'),
                        subtitle: Text(DateFormat('MMM d, y').format(endDate)),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: startDate,
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              endDate = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                Navigator.pop(context);

                final goal = Goal(
                  title: title,
                  description: description,
                  category: category,
                  target: target,
                  current: 0,
                  unit: unit,
                  startDate: startDate,
                  endDate: endDate,
                );

                try {
                  await _databaseService.insertGoal(goal);
                  _loadGoals();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Goal added successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add goal')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _getDefaultUnit(String category) {
    switch (category) {
      case 'steps':
        return 'steps';
      case 'weight':
        return 'kg';
      case 'workout':
        return 'minutes';
      case 'water':
        return 'liters';
      case 'calories':
        return 'kcal';
      default:
        return '';
    }
  }
}
