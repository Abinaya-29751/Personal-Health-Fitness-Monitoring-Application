import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../models/activity_model.dart';
import '../models/goal_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'fitness_tracker.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // User table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        profilePicture TEXT,
        height INTEGER NOT NULL,
        weight REAL NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL
      )
    ''');

    // Workout table
    await db.execute('''
      CREATE TABLE workouts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        durationMinutes INTEGER NOT NULL,
        caloriesBurned INTEGER NOT NULL,
        date TEXT NOT NULL,
        exercises TEXT NOT NULL
      )
    ''');

    // Activity table
    await db.execute('''
      CREATE TABLE activities(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL,
        distanceKm REAL NOT NULL,
        caloriesBurned INTEGER NOT NULL,
        activeMinutes INTEGER NOT NULL
      )
    ''');

    // Goal table
    await db.execute('''
      CREATE TABLE goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        target REAL NOT NULL,
        current REAL NOT NULL,
        unit TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        completed INTEGER NOT NULL
      )
    ''');
  }

  // User CRUD operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toJson());
  }

  Future<User?> getUser(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Workout CRUD operations
  Future<int> insertWorkout(Workout workout) async {
    final db = await database;
    final workoutMap = workout.toJson();
    workoutMap['exercises'] = jsonEncode(workoutMap['exercises']);
    return await db.insert('workouts', workoutMap);
  }

  Future<List<Workout>> getWorkouts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('workouts');

    return List.generate(maps.length, (i) {
      final map = maps[i];
      map['exercises'] = jsonDecode(map['exercises']);
      return Workout.fromJson(map);
    });
  }

  Future<int> updateWorkout(Workout workout) async {
    final db = await database;
    final workoutMap = workout.toJson();
    workoutMap['exercises'] = jsonEncode(workoutMap['exercises']);
    return await db.update(
      'workouts',
      workoutMap,
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<int> deleteWorkout(int id) async {
    final db = await database;
    return await db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Activity CRUD operations
  Future<int> insertActivity(Activity activity) async {
    final db = await database;
    return await db.insert('activities', activity.toMap());
  }

  Future<List<Activity>> getActivities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('activities');

    return List.generate(maps.length, (i) {
      return Activity.fromMap(maps[i]);
    });
  }

  Future<int> updateActivity(Activity activity) async {
    final db = await database;
    return await db.update(
      'activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  // Goal CRUD operations
  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    final goalMap = goal.toJson();
    goalMap['completed'] = goalMap['completed'] ? 1 : 0;
    return await db.insert('goals', goalMap);
  }

  Future<List<Goal>> getGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('goals');

    return List.generate(maps.length, (i) {
      final map = maps[i];
      map['completed'] = map['completed'] == 1;
      return Goal.fromJson(map);
    });
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    final goalMap = goal.toJson();
    goalMap['completed'] = goalMap['completed'] ? 1 : 0;
    return await db.update(
      'goals',
      goalMap,
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}