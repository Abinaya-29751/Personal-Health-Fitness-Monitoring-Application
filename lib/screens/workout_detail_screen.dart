import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/workout_model.dart';
import '../providers/workout_provider.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout? workout;

  const WorkoutDetailScreen({super.key, this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  late TextEditingController _caloriesController;
  late DateTime _selectedDate;
  late String _selectedCategory;
  List<Exercise> _exercises = [];
  final List<String> _categories = ['Strength', 'Cardio', 'Flexibility', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workout?.name);
    _descriptionController = TextEditingController(text: widget.workout?.description);
    _durationController = TextEditingController(
      text: widget.workout?.durationMinutes.toString() ?? '',
    );
    _caloriesController = TextEditingController(
      text: widget.workout?.caloriesBurned.toString() ?? '',
    );
    _selectedDate = widget.workout?.date ?? DateTime.now();
    _selectedCategory = widget.workout?.category ?? _categories[0];
    _exercises = widget.workout?.exercises.toList() ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout == null ? 'Add Workout' : 'Edit Workout'),
        actions: [
          if (widget.workout != null)
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a workout name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter duration';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _caloriesController,
                      decoration: const InputDecoration(
                        labelText: 'Calories Burned',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter calories';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Exercises',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addExercise,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Exercise'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildExerciseList(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveWorkout,
                  child: const Text('Save Workout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    if (_exercises.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No exercises added yet.'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _exercises.length,
      itemBuilder: (context, index) {
        final exercise = _exercises[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(exercise.name),
            subtitle: Text('${exercise.sets} sets x ${exercise.reps} reps${exercise.weight != null ? ' - ${exercise.weight}kg' : ''}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _exercises.removeAt(index);
                });
              },
            ),
            onTap: () => _editExercise(index),
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text('Are you sure you want to delete this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteWorkout();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteWorkout() {
    if (widget.workout?.id != null) {
      Provider.of<WorkoutProvider>(context, listen: false)
          .deleteWorkout(widget.workout!.id!);
    }
    Navigator.pop(context);
  }

  void _addExercise() {
    _showExerciseDialog();
  }

  void _editExercise(int index) {
    _showExerciseDialog(exercise: _exercises[index], index: index);
  }

  void _showExerciseDialog({Exercise? exercise, int? index}) {
    final nameController = TextEditingController(text: exercise?.name);
    final descriptionController = TextEditingController(text: exercise?.description);
    final setsController = TextEditingController(text: exercise?.sets.toString() ?? '');
    final repsController = TextEditingController(text: exercise?.reps.toString() ?? '');
    final weightController = TextEditingController(text: exercise?.weight?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise == null ? 'Add Exercise' : 'Edit Exercise'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Exercise Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter exercise name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: setsController,
                        decoration: const InputDecoration(labelText: 'Sets'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: repsController,
                        decoration: const InputDecoration(labelText: 'Reps'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: weightController,
                  decoration: const InputDecoration(labelText: 'Weight (kg, optional)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Invalid weight';
                      }
                    }
                    return null;
                  },
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
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newExercise = Exercise(
                  id: exercise?.id,
                  name: nameController.text,
                  description: descriptionController.text,
                  sets: int.parse(setsController.text),
                  reps: int.parse(repsController.text),
                  weight: weightController.text.isNotEmpty
                      ? double.parse(weightController.text)
                      : null,
                );

                setState(() {
                  if (index != null) {
                    _exercises[index] = newExercise;
                  } else {
                    _exercises.add(newExercise);
                  }
                });

                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveWorkout() {
    if (_formKey.currentState!.validate()) {
      if (_exercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one exercise')),
        );
        return;
      }

      final workout = Workout(
        id: widget.workout?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        durationMinutes: int.parse(_durationController.text),
        caloriesBurned: int.parse(_caloriesController.text),
        date: _selectedDate,
        exercises: _exercises,
      );

      final provider = Provider.of<WorkoutProvider>(context, listen: false);

      if (widget.workout == null) {
        provider.addWorkout(workout);
      } else {
        provider.updateWorkout(workout);
      }

      Navigator.pop(context);
    }
  }
}