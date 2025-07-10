import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/activity_provider.dart';
import '../models/activity_model.dart';
import '../services/health_service.dart';
import '../widgets/activity_card.dart';
import '../widgets/metric_card.dart'; // adjust the path based on your project


class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final HealthService _healthService = HealthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final activity = await _healthService.getTodayActivity();
      if (activity != null) {
        final provider = Provider.of<ActivityProvider>(context, listen: false);
        provider.addActivity(activity);
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          final todayActivity = provider.todayActivity;
          final weeklyActivities = provider.getActivitiesForWeek();

          if (todayActivity == null) {
            return const Center(
              child: Text('No activity data available for today'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Activity',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActivitySummary(todayActivity),
                const SizedBox(height: 32),
                const Text(
                  'Weekly Progress',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildWeeklyChart(weeklyActivities),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivitySummary(Activity activity) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.directions_walk,
                title: 'Steps',
                value: activity.steps.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                icon: Icons.local_fire_department,
                title: 'Calories',
                value: '${activity.caloriesBurned} cal',
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.straighten,
                title: 'Distance',
                value: '${activity.distanceKm.toStringAsFixed(2)} km',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                icon: Icons.timer,
                title: 'Active Minutes',
                value: '${activity.activeMinutes} min',
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildWeeklyChart(List<Activity> activities) {
    if (activities.isEmpty) {
      return const Center(
        child: Text('No activity data available for this week'),
      );
    }

    // Ensure we have data for all days of the week
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(
      Duration(days: now.weekday - 1),
    );

    final weekData = List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      final dayActivity = activities.firstWhere(
            (activity) =>
        activity.date.year == date.year &&
            activity.date.month == date.month &&
            activity.date.day == date.day,
        orElse: () => Activity(
          date: date,
          steps: 0,
          distanceKm: 0,
          caloriesBurned: 0,
          activeMinutes: 0, id: '',
        ),
      );
      return dayActivity;
    });

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: weekData.fold(0, (max, activity) =>
          activity.steps > max ? activity.steps : max).toDouble() * 1.2,
          barGroups: weekData.asMap().entries.map((entry) {
            final index = entry.key;
            final activity = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: activity.steps.toDouble(),
                  color: Colors.blue,
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final weekday = weekStart.add(Duration(days: value.toInt()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('E').format(weekday),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1000,
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Colors.black12, width: 1),
              left: BorderSide(color: Colors.black12, width: 1),
            ),
          ),
        ),
      ),
    );
  }
}