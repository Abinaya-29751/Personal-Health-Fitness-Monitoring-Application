import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';
import 'providers/user_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/activity_provider.dart';
import 'services/health_service.dart'; // make sure path is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final healthService = HealthService();
  await healthService.initialize();

  runApp(const MyApp());

  // Wait until after widgets are built to access providers
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);

      // Connect HealthService to ActivityProvider
      healthService.onStepCountChanged = (steps) {
        activityProvider.updateSteps(steps);
      };
      healthService.onDistanceChanged = (distance) {
        activityProvider.updateDistance(distance);
      };
      healthService.onCaloriesBurnedChanged = (calories) {
        activityProvider.updateCalories(calories);
      };
      healthService.onActiveMinutesChanged = (minutes) {
        activityProvider.updateActiveMinutes(minutes);
      };
    }
  });
}

// A global key is required to access context after runApp
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => WorkoutProvider()),
        ChangeNotifierProvider(create: (context) => ActivityProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey, // ✅ Add this
        title: 'Fitness Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
      ),
    );
  }
}
