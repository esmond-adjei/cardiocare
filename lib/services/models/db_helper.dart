import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:xmonapp/services/models/db_model.dart';
import 'package:xmonapp/services/constants.dart';
import 'package:xmonapp/services/exceptions.dart';

// databseService
class DatabaseHelper extends ChangeNotifier {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _db;
  static const int _v = 1;
  static const List dbs = [
    createUserTable,
    createSignalTable,
    createECGTable,
    createBPTable,
    createBTempTable,
  ];

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  // =========== MANAGE DATABASE: create tables, open db, close db ===========
  Future<void> onInitCreate() async {
    if (_db != null) {
      return;
    }
    await _open();
  }

  Future<void> _open() async {
    try {
      String path = join(await getDatabasesPath(), dbName);
      log('Opening database at path $path');
      _db = await openDatabase(
        path,
        version: _v,
        onCreate: (db, version) async {
          log('>> Creating tables..');
          db.execute('PRAGMA foreign_keys = ON;');
          for (var database in dbs) {
            await db.execute(database);
          }
        },
      );
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotRunningException();
    } else {
      await db.close();
      _db = null;
    }
  }

  // =========== DB UTILS ===========
  // get db or open if closed
  Future<Database> get database async {
    if (_db != null) return _db!;
    await _open();
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

  // =========== MANAGE USER TABLES ===========
  // manage user table
  Future<CardioUser> createUser({required CardioUser user}) async {
    final db = await database;
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [user.email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(
      userTable,
      {
        emailColumn: user.email.toLowerCase(),
      },
    );
    return user.copyWith(id: userId);
  }

  Future<List<CardioUser>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(userTable);
    return results.map((map) => CardioUser.fromRow(map)).toList();
  }

  Future<CardioUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email],
    );
    if (results.isEmpty) {
      throw UserDoesNotExist();
    }
    return CardioUser.fromRow(results.first);
  }

  Future<int> updateUser(CardioUser user) async {
    // yet to implement
    await getUser(email: user.email);
    final db = await database;
    return db.update(
      userTable,
      user.toMap(),
      where: 'email = ?',
      whereArgs: [user.email],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  // =========== MANAGE SIGNAL TABLE ===========
  // manage signal table
  Future<int> createSignal(Signal signal) async {
    final status = await _db!.insert(signalTable, {
      userIdColumn: signal.userId,
      nameColumn: signal.name,
      startTimeColumn: signal.startTime.toIso8601String(),
      stopTimeColumn: signal.stopTime.toIso8601String(),
      signalTypeColumn: signal.signalType,
    });

    notifyListeners();

    return status;
  }

  Future<List<Map<String, dynamic>>> getAllSignals() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(signalTable);
    return results;
  }

  Future<Map<String, dynamic>> getSignal(int id) async {
    final db = await database;
    final results = await db.query(
      signalTable,
      limit: 1,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      throw SignalDoesNotExist();
    }
    return results.first;
  }

  Future<int> updateSignal(Signal signal) async {
    final db = await database;
    final result = await db.update(
      signalTable,
      {nameColumn: signal.name},
      where: 'id=?',
      whereArgs: [signal.signalId],
    );
    notifyListeners();
    return result;
  }

  Future<int> deleteSignal(Signal signal) async {
    final db = await database;
    String table;

    switch (signal.signalType) {
      case ecgType:
        table = ecgTable;
        break;
      case bpType:
        table = bpTable;
        break;
      case btempType:
        table = btempTable;
        break;
      default:
        throw UnknownSignalType;
    }

    final signalId =
        await db.delete(table, where: '$idColumn=?', whereArgs: [signal.id]);
    await db.delete(signalTable,
        where: '$idColumn=?', whereArgs: [signal.signalId]);

    notifyListeners();
    return signalId;
  }

  // manage ecg table
  Future<int> createEcgData(EcgModel ecgData) async {
    final db = _getDatabaseOrThrow();
    final signalId = await createSignal(ecgData);
    return await db.insert(ecgTable, {
      signalIdColumn: signalId,
      'ecg': ecgData.ecg,
    });
  }

  Future<List<EcgModel>> getEcgData(int userId, {int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      '$signalTable INNER JOIN $ecgTable ON $signalTable.$idColumn = $ecgTable.$signalIdColumn',
      where:
          '$signalTable.$userIdColumn = ? AND $signalTable.$signalTypeColumn = ?',
      whereArgs: [userId, 'ECG'],
      orderBy: '$signalTable.$createdAtColumn DESC',
      limit: limit,
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

  Future<List<BpModel>> getBpData(int userId, {int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      '$signalTable INNER JOIN $bpTable ON $signalTable.$idColumn = $bpTable.$signalIdColumn',
      where:
          '$signalTable.$userIdColumn = ? AND $signalTable.$signalTypeColumn = ?',
      whereArgs: [userId, 'BP'],
      orderBy: '$signalTable.$createdAtColumn DESC',
      limit: limit,
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

  Future<List<BtempModel>> getBtempData(int userId, {int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      '$signalTable INNER JOIN $btempTable ON $signalTable.$idColumn = $btempTable.$signalIdColumn',
      where:
          '$signalTable.$userIdColumn = ? AND $signalTable.$signalTypeColumn = ?',
      whereArgs: [userId, 'BTEMP'],
      orderBy: '$signalTable.$createdAtColumn DESC',
      limit: limit,
    );
    return results.map((map) => BtempModel.fromMap(map)).toList();
  }

  // DASHBOARD
  Future<Map<String, List<Signal>>> getRecentRecords(int userId,
      {int limit = 3}) async {
    final List<EcgModel> recentEcgRecords =
        await getEcgData(userId, limit: limit);
    final List<BpModel> recentBpRecords = await getBpData(userId, limit: limit);
    final List<BtempModel> recentBtempRecords =
        await getBtempData(userId, limit: limit);

    return {
      ecgType: recentEcgRecords,
      bpType: recentBpRecords,
      btempType: recentBtempRecords,
    };
  }
}
