import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:xmonapp/services/models/db_model.dart';
import 'package:xmonapp/services/constants.dart';
import 'package:xmonapp/services/exceptions.dart';

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

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(createUserTable);
    await db.execute(createSignalTable);
    await db.execute(createECGTable);
    await db.execute(createBPTable);
    await db.execute(createBTempTable);
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

  // ======== MANAGE SIGNAL TABLE ===========
  // manage signal table
  Future<int> createSignal(Signal signal) async {
    final db = _getDatabaseOrThrow();
    final signalId = await db.insert(signalTable, {
      userIdColumn: signal.userId,
      startTimeColumn: signal.startTime.toIso8601String(),
      stopTimeColumn: signal.stopTime.toIso8601String(),
      signalTypeColumn: signal.signalType,
    });
    return signalId;
  }

  // manage ecg table
  Future<int> createEcgData(EcgModel ecgData) async {
    final signalId = await createSignal(ecgData);
    final db = _getDatabaseOrThrow();
    return await db.insert(ecgTable, {
      signalIdColumn: signalId,
      'ecg': ecgData.ecg,
    });
  }

  Future<List<EcgModel>> getEcgData(int userId) async {
    final db = _getDatabaseOrThrow();
    final List<Map<String, dynamic>> results = await db.query(
      '$signalTable INNER JOIN $ecgTable ON $signalTable.$idColumn = $ecgTable.$signalIdColumn',
      where:
          '$signalTable.$userIdColumn = ? AND $signalTable.$signalTypeColumn = ?',
      whereArgs: [userId, 'ECG'],
      orderBy: '$signalTable.$createdAtColumn DESC',
    );
    return results.map((map) => EcgModel.fromMap(map)).toList();
  }

  // manage bp table
  Future<int> createBpData(BpModel bpModel) async {
    final signalId = await createSignal(bpModel);
    final db = _getDatabaseOrThrow();
    return await db.insert(bpTable, {
      signalIdColumn: signalId,
      'bp_systolic': bpModel.bpSystolic,
      'bp_diastolic': bpModel.bpDiastolic,
    });
  }

  Future<List<BpModel>> getBpData(int userId) async {
    final db = _getDatabaseOrThrow();
    final List<Map<String, dynamic>> results = await db.query(
      '$signalTable INNER JOIN $bpTable ON $signalTable.$idColumn = $bpTable.$signalIdColumn',
      where:
          '$signalTable.$userIdColumn = ? AND $signalTable.$signalTypeColumn = ?',
      whereArgs: [userId, 'BP'],
      orderBy: '$signalTable.$createdAtColumn DESC',
    );
    return results.map((map) => BpModel.fromMap(map)).toList();
  }

  // manage btemp table
  Future<int> createBtempData(BtempModel btempModel) async {
    final signalId = await createSignal(btempModel);
    final db = _getDatabaseOrThrow();
    return await db.insert(btempTable, {
      signalIdColumn: signalId,
      'body_temp': btempModel.bodyTemp,
    });
  }

  Future<List<BtempModel>> getBtempData(int userId) async {
    final db = _getDatabaseOrThrow();
    final List<Map<String, dynamic>> results = await db.query(
      '$signalTable INNER JOIN $btempTable ON $signalTable.$idColumn = $btempTable.$signalIdColumn',
      where:
          '$signalTable.$userIdColumn = ? AND $signalTable.$signalTypeColumn = ?',
      whereArgs: [userId, 'BTEMP'],
      orderBy: '$signalTable.$createdAtColumn DESC',
    );
    return results.map((map) => BtempModel.fromMap(map)).toList();
  }
}
