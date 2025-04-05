import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteManager {
  static final SQLiteManager _instance = SQLiteManager._internal();

  factory SQLiteManager() => _instance;

  SQLiteManager._internal();

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
        await db.execute('CREATE TABLE completed_exercises (program TEXT, date DATE, name TEXT)');
      },
    );
  }

  Future<int> addItem() async {
    final db = await database;
    return await db.insert(
      "completed_exercises",
      {},
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

  Future<List<Map<String, dynamic>>> fetchItems() async {
    final db = await database;
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
/*
  to be used to delete the database when chaning thing the database structure
  Future<void> deleteMealsDatabase() async {
    String dbPath = await getDatabasesPath(); // Get the database directory path
    String path = join(dbPath, 'completed_exercises.db'); // Construct the full database file path
    await deleteDatabase(path); // Delete the database file
    print("Database deleted: $path");
  }
*/
}
