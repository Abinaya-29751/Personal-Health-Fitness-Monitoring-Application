// lib/widgets/goal_tracker.dart
import 'package:flutter/material.dart';
import '../models/goal_model.dart';

class GoalTracker extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;

  const GoalTracker({
    super.key,
    required this.goal,
    this.onTap, required Null Function(dynamic newProgress) onProgressChanged, required double progress, required bool isCompleted,
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
                    goal.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _getCategoryChip(goal.category),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                goal.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: goal.progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                color: _getProgressColor(goal.progress),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(goal.progress * 100).toInt()}% Complete',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${goal.current.toInt()} / ${goal.target.toInt()} ${goal.unit}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCategoryChip(String category) {
    Color chipColor;
    IconData chipIcon;

    switch (category.toLowerCase()) {
      case 'steps':
        chipColor = Colors.blue;
        chipIcon = Icons.directions_walk;
        break;
      case 'weight':
        chipColor = Colors.green;
        chipIcon = Icons.monitor_weight;
        break;
      case 'workout':
        chipColor = Colors.orange;
        chipIcon = Icons.fitness_center;
        break;
      default:
        chipColor = Colors.purple;
        chipIcon = Icons.star;
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

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) {
      return const Color(0xFF4CAF50); // Green
    } else if (progress >= 0.7) {
      return const Color(0xFF8BC34A); // Light Green
    } else if (progress >= 0.4) {
      return const Color(0xFFFFC107); // Amber
    } else {
      return const Color(0xFFFF9800); // Orange
    }
  }
}