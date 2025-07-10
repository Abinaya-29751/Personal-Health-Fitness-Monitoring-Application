// lib/services/health_service.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';

class HealthService {
  // Singleton pattern
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  // Step detection properties
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final double _stepThreshold = 12.0; // Acceleration threshold for step detection
  double _lastMagnitude = 0.0;
  bool _isStepUp = false;
  DateTime? _lastStepTime;

  // Step counting properties
  int _steps = 0;
  double _distanceKm = 0.0;
  int _caloriesBurned = 0;

  // Active time tracking
  DateTime? _appStartTime;
  Timer? _activeTimeTimer;
  int _activeMinutes = 0;

  // Callbacks
  Function(int)? onStepCountChanged;
  Function(double)? onDistanceChanged;
  Function(int)? onCaloriesBurnedChanged;
  Function(int)? onActiveMinutesChanged;

  // Initialize the service
  Future<void> initialize() async {
    await _loadSavedData();
    _startStepCounting();
    _startActiveTimeTracking();
  }

  // Load saved health data from local storage
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey = '${today.year}_${today.month}_${today.day}';

      // Load today's data if available
      _steps = prefs.getInt('steps_$todayKey') ?? 0;
      _distanceKm = prefs.getDouble('distance_$todayKey') ?? 0.0;
      _caloriesBurned = prefs.getInt('calories_$todayKey') ?? 0;
      _activeMinutes = prefs.getInt('active_$todayKey') ?? 0;
    } catch (e) {
      debugPrint('Error loading health data: $e');
    }
  }

  // Save current health data to local storage
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey = '${today.year}_${today.month}_${today.day}';

      await prefs.setInt('steps_$todayKey', _steps);
      await prefs.setDouble('distance_$todayKey', _distanceKm);
      await prefs.setInt('calories_$todayKey', _caloriesBurned);
      await prefs.setInt('active_$todayKey', _activeMinutes);
    } catch (e) {
      debugPrint('Error saving health data: $e');
    }
  }

  // Start step counting using the accelerometer
  void _startStepCounting() {
    try {
      _accelerometerSubscription?.cancel();
      _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
        _processAccelerometerData(event);
      });
    } catch (e) {
      debugPrint('Error starting step counting: $e');
    }
  }

  // Process accelerometer data for step detection
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

  // Process a detected step
  void _onStepDetected() {
    _steps++;

    // Calculate distance (using average stride length)
    const double averageStrideLengthInKm = 0.0007; // 0.7 meters in km
    _distanceKm = _steps * averageStrideLengthInKm;

    // Calculate calories (simple estimate)
    const double caloriesPerStep = 0.04;
    _caloriesBurned = (_steps * caloriesPerStep).toInt();

    // Save data and notify listeners
    _saveData();
    onStepCountChanged?.call(_steps);
    onDistanceChanged?.call(_distanceKm);
    onCaloriesBurnedChanged?.call(_caloriesBurned);
  }

  // Start tracking active time
  void _startActiveTimeTracking() {
    _appStartTime = DateTime.now();

    // Update active time every minute
    _activeTimeTimer?.cancel();
    _activeTimeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_appStartTime != null) {
        final elapsedMinutes = DateTime.now().difference(_appStartTime!).inMinutes;
        _activeMinutes = elapsedMinutes;

        _saveData();
        onActiveMinutesChanged?.call(_activeMinutes);
      }
    });
  }

  // Get current health data as an Activity model
  Activity getTodayActivity() {
    final now = DateTime.now();
    return Activity(
      id: 'activity_${now.year}_${now.month}_${now.day}',
      date: DateTime(now.year, now.month, now.day),
      steps: _steps,
      distanceKm: _distanceKm,
      caloriesBurned: _caloriesBurned,
      activeMinutes: _activeMinutes,
    );
  }

  // Manual step count update (for testing)
  void updateStepCount(int steps) {
    _steps = steps;

    // Recalculate related metrics
    const double averageStrideLengthInKm = 0.0007;
    _distanceKm = _steps * averageStrideLengthInKm;

    const double caloriesPerStep = 0.04;
    _caloriesBurned = (_steps * caloriesPerStep).toInt();

    _saveData();
    onStepCountChanged?.call(_steps);
    onDistanceChanged?.call(_distanceKm);
    onCaloriesBurnedChanged?.call(_caloriesBurned);
  }

  // Reset all data (for testing or new day)
  void reset() {
    _steps = 0;
    _distanceKm = 0.0;
    _caloriesBurned = 0;
    _activeMinutes = 0;
    _saveData();

    onStepCountChanged?.call(_steps);
    onDistanceChanged?.call(_distanceKm);
    onCaloriesBurnedChanged?.call(_caloriesBurned);
    onActiveMinutesChanged?.call(_activeMinutes);
  }

  // Clean up resources
  void dispose() {
    _accelerometerSubscription?.cancel();
    _activeTimeTimer?.cancel();
  }
}