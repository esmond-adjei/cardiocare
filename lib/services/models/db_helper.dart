import 'dart:developer';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xmonapp/services/models/db_model.dart';
import 'package:xmonapp/services/constants.dart';

// exceptions
class DatabaseRunningException implements Exception {}

class UnableToGetDocumentsDirectory implements Exception {}

class DatabaseNotRunningException implements Exception {}

class DatabaseIsNotOpen implements Exception {}

class UserAlreadyExists implements Exception {}

class UserDoesNotExist implements Exception {}

// databseService
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _db;
  static const int _v = 1;
  static const List dbs = [
    createECGTable,
    createBPTable,
    createBTempTable,
    createUserTable
  ];

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  // ======== MANAGE DATABASE ===========
  // get db or open if closed
  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await _open();
    return _db!;
  }

  // get db or throw error
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  // version 1: open db
  Future<Database> _open() async {
    try {
      String path = join(await getDatabasesPath(), dbName);
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  // version 2: open db
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseRunningException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final String dbPath = join(docsPath.path, dbName);
      _db = await openDatabase(dbPath);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  // close db
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotRunningException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(createUserTable);
    await db.execute(createECGTable);
    await db.execute(createBPTable);
    await db.execute(createBTempTable);
  }

//Initialize all databases at once.
  Future<void> onInitCreate() async {
    if (_db != null) {
      return;
    }
    try {
      String dbPath = "${await getDatabasesPath()}$dbName";

      _db = await openDatabase(
        dbPath,
        version: _v,
        onCreate: (db, version) {
          for (var database in dbs) {
            db.execute(database);
          }
        },
      );
    } on Exception catch (e) {
      log('db:  ${e.toString()}');
    }
  }
//

  // ======== MANAGE USER TABLES ===========
  // manage user table
  Future<CardioUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    // create and return a new cardio user object
    return CardioUser(id: userId, email: email);
  }

  Future<CardioUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw UserDoesNotExist();
    }
    // return a new cardio user object
    return CardioUser.fromRow(results.first);
  }

  Future<int> updateUser({required String email}) async {
    // yet to implement
    return 0;
  }

  Future<int> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final response = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (response != 1) {
      throw UserDoesNotExist();
    }
    return response;
  }

  // ======== MANAGE USER TABLES ===========
  // manage signal table
  // ...

  // manage ecg table
  Future<int> createEcgData(
    int userId,
    DateTime startTime,
    DateTime stopTime,
    List<int> ecg,
  ) async {
    Database db = await database;
    return await db.insert(ecgTable, {
      userIdColumn: userId,
      startTimeColumn: startTime,
      stopTimeColumn: stopTime,
      'ecg': Uint8List.fromList(ecg),
    });
  }

  Future<List<Map<String, dynamic>>> getEcgData(int userId) async {
    Database db = await database;
    return await db.query(
      ecgTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
  }

  // manage bp table
  Future<int> insertBpData(int userId, int systolic, int diastolic) async {
    Database db = await database;
    return await db.insert('bp_data', {
      'user_id': userId,
      'bp_systolic': systolic,
      'bp_diastolic': diastolic
    });
  }

  // manage btemp table
  Future<int> insertTemperatureData(int userId, double temperature) async {
    Database db = await database;
    return await db.insert('temperature_data', {
      'user_id': userId,
      'body_temp': temperature,
    });
  }

  Future<List<Map<String, dynamic>>> getBpData(int userId) async {
    Database db = await database;
    return await db.query(
      'bp_data',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getTemperatureData(int userId) async {
    Database db = await database;
    return await db.query(
      'temperature_data',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
  }
}
