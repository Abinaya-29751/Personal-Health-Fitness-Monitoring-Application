import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _databaseService = DatabaseService();

  // Key for storing login status
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';

  // Register a new user
  Future<bool> register(User user) async {
    try {
      // Check if user already exists
      final existingUser = await _databaseService.getUser(user.email);
      if (existingUser != null) {
        return false;
      }

      // Insert new user
      final userId = await _databaseService.insertUser(user);
      if (userId > 0) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Login user
  Future<User?> login(String email, String password) async {
    try {
      // In a real app, you would check the password here
      // For this demo, we'll just check if the user exists
      final user = await _databaseService.getUser(email);
      if (user != null) {
        // Save login status
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_isLoggedInKey, true);
        await prefs.setString(_userEmailKey, email);
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      if (isLoggedIn) {
        final email = prefs.getString(_userEmailKey);
        if (email != null) {
          return await _databaseService.getUser(email);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, false);
      await prefs.remove(_userEmailKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile(User user) async {
    try {
      final result = await _databaseService.updateUser(user);
      return result > 0;
    } catch (e) {
      return false;
    }
  }
}