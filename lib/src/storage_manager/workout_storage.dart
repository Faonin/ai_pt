import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class WorkoutStorageManager {
  static final WorkoutStorageManager _instance = WorkoutStorageManager._internal();

  factory WorkoutStorageManager() => _instance;

  WorkoutStorageManager._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'workout_plans.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE workout_plans (name TEXT key, description Text, questions TEXT)');
      },
    );
  }

  Future<int> addWorkoutPlan(String name, String description, String questions) async {
    final db = await database;
    return await db.insert(
      "workout_plans",
      {'name': name, 'description': description, 'questions': questions},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateWorkoutPlan(String name, String description, String questions) async {
    final db = await database;
    return await db.update(
      'workout_plans',
      {'description': description, 'questions': questions},
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<int> removeItem() async {
    final db = await database;
    return await db.delete(
      'workout_plans',
      where: '',
      whereArgs: [],
    );
  }

  Future<List<String>> fetchItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('workout_plans', columns: ['name']);
    return maps.map((item) => item['name'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> fetchItem() async {
    final db = await database;
    return await db.query(
      'workout_plans',
      where: '',
      whereArgs: [],
    );
  }

  // Close the database
  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }

  //to be used to delete the database when chaning thing the database structure
  Future<void> deleteWorkoutDatabase() async {
    String dbPath = await getDatabasesPath(); // Get the database directory path
    String path = join(dbPath, 'workout_plans.db'); // Construct the full database file path
    await deleteDatabase(path); // Delete the database file
  }
}
