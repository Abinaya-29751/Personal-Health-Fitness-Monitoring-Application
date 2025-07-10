// lib/widgets/progress_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/activity_model.dart';
import 'package:intl/intl.dart';

class ProgressChart extends StatelessWidget {
  final List<Activity> activities;
  final String dataType; // 'steps', 'distance', 'calories', 'minutes'

  const ProgressChart({
    super.key,
    required this.activities,
    required this.dataType,
  });

  @override
  Widget build(BuildContext context) {
    // Sort activities by date
    final sortedActivities = [...activities]
      ..sort((a, b) => a.date.compareTo(b.date));

    // Prepare data points
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedActivities.length; i++) {
      final activity = sortedActivities[i];
      double value;

      switch (dataType) {
        case 'steps':
          value = activity.steps.toDouble();
          break;
        case 'distance':
          value = activity.distanceKm;
          break;
        case 'calories':
          value = activity.caloriesBurned.toDouble();
          break;
        case 'minutes':
          value = activity.activeMinutes.toDouble();
          break;
        default:
          value = 0;
      }

      spots.add(FlSpot(i.toDouble(), value));
    }

    Color lineColor;
    String title;

    switch (dataType) {
      case 'steps':
        lineColor = Colors.blue;
        title = 'Steps';
        break;
      case 'distance':
        lineColor = Colors.green;
        title = 'Distance (km)';
        break;
      case 'calories':
        lineColor = Colors.orange;
        title = 'Calories Burned';
        break;
      case 'minutes':
        lineColor = Colors.purple;
        title = 'Active Minutes';
        break;
      default:
        lineColor = Colors.grey;
        title = '';
    }

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
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getInterval(),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < sortedActivities.length) {
                            final date = sortedActivities[value.toInt()].date;
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                DateFormat('dd/MM').format(date),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                      left: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  minX: 0,
                  maxX: sortedActivities.length - 1.0,
                  minY: 0,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: lineColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: lineColor.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getInterval() {
    switch (dataType) {
      case 'steps':
        final maxSteps = activities.fold<int>(
            0, (max, activity) => activity.steps > max ? activity.steps : max);
        return (maxSteps / 5).ceilToDouble();
      case 'distance':
        final maxDistance = activities.fold<double>(
            0, (max, activity) => activity.distanceKm > max ? activity.distanceKm : max);
        return (maxDistance / 5).ceilToDouble();
      case 'calories':
        final maxCalories = activities.fold<int>(
            0, (max, activity) => activity.caloriesBurned > max ? activity.caloriesBurned : max);
        return (maxCalories / 5).ceilToDouble();
      case 'minutes':
        final maxMinutes = activities.fold<int>(
            0, (max, activity) => activity.activeMinutes > max ? activity.activeMinutes : max);
        return (maxMinutes / 5).ceilToDouble();
      default:
        return 1000;
    }
  }
}
