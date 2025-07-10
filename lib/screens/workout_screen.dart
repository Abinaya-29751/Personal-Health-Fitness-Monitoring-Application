import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout_model.dart';
import '../widgets/workout_card.dart';
import 'workout_detail_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['All', 'Strength', 'Cardio', 'Flexibility', 'Other'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((category) => Tab(text: category)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((category) {
          return _buildWorkoutList(category);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToWorkoutDetail(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWorkoutList(String category) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        List<Workout> workouts = provider.workouts;

        if (category != 'All') {
          workouts = workouts.where((workout) =>
          workout.category.toLowerCase() == category.toLowerCase()
          ).toList();
        }

        if (workouts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No workouts found',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                if (category == 'All')
                  ElevatedButton(
                    onPressed: () => _navigateToWorkoutDetail(context),
                    child: const Text('Add Your First Workout'),
                  ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: WorkoutCard(
                workout: workout,
                onTap: () => _navigateToWorkoutDetail(context, workout: workout),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToWorkoutDetail(BuildContext context, {Workout? workout}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailScreen(workout: workout),
      ),
    );
  }
}