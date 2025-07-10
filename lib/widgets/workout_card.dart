// lib/widgets/workout_card.dart
import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import 'package:intl/intl.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;

  const WorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    workout.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  _getCategoryChip(workout.category),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                workout.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    context,
                    Icons.timer,
                    '${workout.durationMinutes} min',
                  ),
                  _buildInfoItem(
                    context,
                    Icons.local_fire_department,
                    '${workout.caloriesBurned} cal',
                  ),
                  _buildInfoItem(
                    context,
                    Icons.fitness_center,
                    '${workout.exercises.length} exercises',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${DateFormat('MMM dd, yyyy').format(workout.date)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _getCategoryChip(String category) {
    Color chipColor;
    IconData chipIcon;

    switch (category.toLowerCase()) {
      case 'strength':
        chipColor = Colors.blue;
        chipIcon = Icons.fitness_center;
        break;
      case 'cardio':
        chipColor = Colors.red;
        chipIcon = Icons.directions_run;
        break;
      case 'flexibility':
        chipColor = Colors.green;
        chipIcon = Icons.accessibility_new;
        break;
      default:
        chipColor = Colors.purple;
        chipIcon = Icons.sports;
    }

    return Chip(
      avatar: Icon(
        chipIcon,
        size: 16,
        color: Colors.white,
      ),
      label: Text(
        category,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}