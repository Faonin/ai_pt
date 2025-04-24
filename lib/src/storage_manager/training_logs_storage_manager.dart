import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TrainingLogsStorageManager {
  static final TrainingLogsStorageManager _instance = TrainingLogsStorageManager._internal();

  factory TrainingLogsStorageManager() => _instance;

  TrainingLogsStorageManager._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'completed_exercises.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE completed_exercises (program TEXT, workoutType TEXT, date DATE, exercise TEXT, sets TEXT, amount TEXT, unit TEXT, dose TEXT, dose_unit TEXT, rpe TEXT)');
      },
    );
  }

  Future<int> addItem(String program, String workoutType, String date, String exercise, String set, String amount, String unit, String dose,
      String doseUnit, String rpe) async {
    final db = await database;
    return await db.insert(
      "completed_exercises",
      {
        "program": program,
        "workoutType": workoutType,
        "date": date,
        "exercise": exercise,
        "sets": set,
        "amount": amount,
        "unit": unit,
        "dose": dose,
        "dose_unit": doseUnit,
        "rpe": rpe
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> removeItem(String date, String mealType) async {
    final db = await database;
    return await db.delete(
      'completed_exercises',
      where: '',
      whereArgs: [],
    );
  }

  Future<List<Map<String, dynamic>>> fetchItems(int? daysAgo) async {
    final db = await database;
    if (daysAgo != null && daysAgo > 0) {
      return await db.query(
        'completed_exercises',
        where: "date >= date('now', '-$daysAgo days')",
      );
    }
    return await db.query('completed_exercises');
  }

  Future<List<Map<String, dynamic>>> fetchItem(String date, String mealType) async {
    final db = await database;
    return await db.query(
      'completed_exercises',
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

  //to be used to delete the database when changing thing the database structure
  Future<void> deleteMealsDatabase() async {
    String dbPath = await getDatabasesPath(); // Get the database directory path
    String path = join(dbPath, 'completed_exercises.db'); // Construct the full database file path
    await deleteDatabase(path); // Delete the database file
    // ignore: avoid_print
    print("Database deleted: $path");
  }
}
