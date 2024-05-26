import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'vital_signals.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ecg_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        ecg BLOB NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE bp_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        bp_systolic INTEGER NOT NULL,
        bp_diastolic INTEGER NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE temperature_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        body_temp REAL NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<int> insertEcgData(int userId, List<int> ecg) async {
    Database db = await database;
    return await db.insert(
        'ecg_data', {'user_id': userId, 'ecg': Uint8List.fromList(ecg)});
  }

  Future<int> insertBpData(int userId, int systolic, int diastolic) async {
    Database db = await database;
    return await db.insert('bp_data', {
      'user_id': userId,
      'bp_systolic': systolic,
      'bp_diastolic': diastolic
    });
  }

  Future<int> insertTemperatureData(int userId, double temperature) async {
    Database db = await database;
    return await db.insert(
        'temperature_data', {'user_id': userId, 'body_temp': temperature});
  }

  Future<List<Map<String, dynamic>>> getEcgData(int userId) async {
    Database db = await database;
    return await db.query('ecg_data',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'timestamp DESC');
  }

  Future<List<Map<String, dynamic>>> getBpData(int userId) async {
    Database db = await database;
    return await db.query('bp_data',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'timestamp DESC');
  }

  Future<List<Map<String, dynamic>>> getTemperatureData(int userId) async {
    Database db = await database;
    return await db.query('temperature_data',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'timestamp DESC');
  }
}
