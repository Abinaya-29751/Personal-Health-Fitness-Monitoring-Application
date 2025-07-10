import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project/screens/workout_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart'; // Add this package for step counting
import '../providers/user_provider.dart';
import '../providers/activity_provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/activity_card.dart';
import '../widgets/workout_card.dart';
import '../utils/constants.dart';
import '../services/health_service.dart'; // Import health service
import 'activity_screen.dart';
import 'workout_screen.dart';
import 'goals_screen.dart';
import 'profile_screen.dart';
import 'package:sensors_plus/sensors_plus.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _screens = [
    DashboardHomeScreen(onTabSelected: (index) {}),
    const ActivityScreen(),
    const WorkoutScreen(),
    const GoalsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          _onTabSelected(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardHomeScreen extends StatefulWidget {
  final void Function(int) onTabSelected;

  const DashboardHomeScreen({Key? key, required this.onTabSelected}) : super(key: key);

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  int _selectedIndex = 0;
  DateTime? _appStartTime;
  Timer? _activeTimeTimer;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _isStepDetectionActive = false;

  // Step detection variables
  final double _stepThreshold = 12.0; // Adjust based on testing
  double _lastMagnitude = 0.0;
  bool _isStepUp = false;
  DateTime? _lastStepTime;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _appStartTime = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start tracking active time
      _startActiveTimeTracking();

      // Initialize step detection
      _initializeStepCounting();

      // Initialize activity data if needed
      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
      activityProvider.initTodayActivity();
    });
  }

  void _startActiveTimeTracking() {
    // Update active time every minute
    _activeTimeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted) return;

      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
      final elapsedMinutes = DateTime.now().difference(_appStartTime!).inMinutes;

      // Update active minutes in today's activity
      activityProvider.updateActiveMinutes(elapsedMinutes);
    });
  }

  void _initializeStepCounting() {
    // Check if step detection is already active
    if (_isStepDetectionActive) return;

    try {
      _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
        _processAccelerometerData(event);
      });

      _isStepDetectionActive = true;
    } catch (e) {
      debugPrint('Error initializing step detection: $e');
    }
  }

  void _processAccelerometerData(AccelerometerEvent event) {
    // Calculate the magnitude of the acceleration vector
    final double magnitude = _calculateMagnitude(event);

    // Simple peak detection algorithm for steps
    if (!_isStepUp && magnitude > _stepThreshold && _lastMagnitude <= _stepThreshold) {
      _isStepUp = true;
    } else if (_isStepUp && magnitude < _stepThreshold && _lastMagnitude >= _stepThreshold) {
      _isStepUp = false;

      // Check if enough time has passed since the last step (to avoid counting bounces)
      final now = DateTime.now();
      if (_lastStepTime == null || now.difference(_lastStepTime!).inMilliseconds > 250) {
        _lastStepTime = now;
        _onStepDetected();
      }
    }

    _lastMagnitude = magnitude;
  }

  double _calculateMagnitude(AccelerometerEvent event) {
    return sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
  }

  void _onStepDetected() {
    if (!mounted) return;

    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);

    // Increment step count
    activityProvider.incrementSteps();

    // Calculate and update distance based on steps
    // Average stride length is about 0.76 m for men and 0.67 m for women
    // Using 0.7 meters as a general average
    const double averageStrideLengthInKm = 0.0007; // 0.7 meters in km
    final int currentSteps = activityProvider.todayActivity?.steps ?? 0;
    final double distanceInKm = currentSteps * averageStrideLengthInKm;

    // Update distance
    activityProvider.updateDistance(distanceInKm);

    // Calculate and update calories (simple estimate)
    // Average calorie burn is about 0.04 calories per step
    const double caloriesPerStep = 0.04;
    final double caloriesBurned = currentSteps * caloriesPerStep;

    // Update calories
    activityProvider.updateCalories(caloriesBurned.toInt());
  }

  @override
  void dispose() {
    _activeTimeTimer?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    final todayActivity = activityProvider.todayActivity;
    final weekActivities = activityProvider.getActivitiesForWeek();
    final recentWorkouts = workoutProvider.workouts.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hi, ${userProvider.user?.name.split(' ')[0] ?? 'User'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh data from health service
          await activityProvider.refreshActivityData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today's Summary Card
                _buildTodaySummaryCard(context, todayActivity),

                const SizedBox(height: 24),

                // Weekly Progress Chart
                _buildWeeklyProgressChart(context, weekActivities),

                const SizedBox(height: 24),

                // Recent Workouts Section
                _buildRecentWorkoutsSection(
                  context,
                  recentWorkouts,
                  widget.onTabSelected, // Pass down the onTabSelected here
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySummaryCard(BuildContext context, activity) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Activity",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMM d').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActivityMetric(
                  context,
                  Icons.directions_walk,
                  '${activity?.steps ?? 0}',
                  'Steps',
                  Colors.blue,
                ),
                _buildActivityMetric(
                  context,
                  Icons.local_fire_department,
                  '${activity?.caloriesBurned ?? 0}',
                  'Calories',
                  Colors.orange,
                ),
                _buildActivityMetric(
                  context,
                  Icons.straighten,
                  '${activity?.distanceKm?.toStringAsFixed(2) ?? '0.00'} km',
                  'Distance',
                  Colors.green,
                ),
                _buildActivityMetric(
                  context,
                  Icons.timer,
                  '${activity?.activeMinutes ?? 0} min',
                  'Active',
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityMetric(
      BuildContext context,
      IconData icon,
      String value,
      String label,
      Color color,
      ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressChart(BuildContext context, List weekActivities) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: weekActivities.isEmpty
                  ? const Center(
                child: Text('No activity data available for this week'),
              )
                  : LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 2000 == 0) {
                            return Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < weekDays.length) {
                            return Text(
                              weekDays[value.toInt()],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getWeeklyStepsData(weekActivities),
                      isCurved: true,
                      barWidth: 3,
                      color: Theme.of(context).primaryColor,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChartLegend(context, 'Steps', Theme.of(context).primaryColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getWeeklyStepsData(List activities) {
    final List<FlSpot> spots = [];

    // If no data, return empty spots
    if (activities.isEmpty) {
      return spots;
    }

    // Get the current week day numbers
    final now = DateTime.now();
    final weekDay = now.weekday - 1; // 0 for Monday, 6 for Sunday

    // Create a map of weekday to steps for available data
    final Map<int, int> dayToSteps = {};
    for (final activity in activities) {
      final day = activity.date.weekday - 1; // 0 for Monday, 6 for Sunday
      dayToSteps[day] = activity.steps;
    }

    // Create spots for each day of the week
    for (int i = 0; i <= 6; i++) {
      final steps = dayToSteps[i] ?? 0;
      spots.add(FlSpot(i.toDouble(), steps.toDouble()));
    }

    return spots;
  }

  Widget _buildChartLegend(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentWorkoutsSection(
      BuildContext context, List recentWorkouts, void Function(int) onTabSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Workouts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                onTabSelected(2); // 👈 Notify parent to change tab
              },
              child: const Text('See All'),
            ),
          ],
        ),
        recentWorkouts.isEmpty
            ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Center(
            child: Text('No workouts logged yet.'),
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentWorkouts.length,
          itemBuilder: (context, index) {
            return WorkoutCard(
              workout: recentWorkouts[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutDetailScreen(
                      workout: recentWorkouts[index],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}