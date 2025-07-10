// lib/widgets/activity_card.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/activity_model.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              context,
              FontAwesomeIcons.personWalking,
              '${activity.steps}',
              'Steps',
              Colors.blue,
            ),
            const Divider(),
            _buildActivityItem(
              context,
              FontAwesomeIcons.road,
              '${activity.distanceKm.toStringAsFixed(2)} km',
              'Distance',
              Colors.green,
            ),
            const Divider(),
            _buildActivityItem(
              context,
              FontAwesomeIcons.fire,
              '${activity.caloriesBurned}',
              'Calories',
              Colors.orange,
            ),
            const Divider(),
            _buildActivityItem(
              context,
              FontAwesomeIcons.clock,
              '${activity.activeMinutes} min',
              'Active Time',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      BuildContext context,
      IconData icon,
      String value,
      String label,
      Color color,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FaIcon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}