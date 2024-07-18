import 'dart:developer' as dev;
import 'package:cardiocare/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:cardiocare/services/constants.dart';
import 'package:cardiocare/services/exceptions.dart';
import 'package:cardiocare/services/models/signal_model.dart';
import 'package:cardiocare/services/models/user_model.dart';

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
      dev.log('Opening database at path $path');
      _db = await openDatabase(
        path,
        version: _v,
        onCreate: (db, version) async {
          dev.log('>> Creating tables..');
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

    final userId = await db.insert(userTable, {
      emailColumn: user.email.toLowerCase(),
    });
    return user.copyWith(id: userId);
  }

  Future<List<CardioUser>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(userTable);
    return results.map((map) => CardioUser.fromMap(map)).toList();
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
    return CardioUser.fromMap(results.first);
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
    final signalId = await _db!.insert(signalTable, signal.toMap());
    dev.log(">> DB: saving signal (ID: $signalId)");
    notifyListeners();

    return signalId;
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
      case SignalType.ecg:
        table = ecgTable;
        break;
      case SignalType.bp:
        table = bpTable;
        break;
      case SignalType.btemp:
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
    dev.log(">> DB: saving ecg (SID: $signalId)");
    return await db.insert(ecgTable, {
      signalIdColumn: signalId,
      'ecg': ecgData.ecg,
      'hrv': ecgData.hrv,
      'hbpm': ecgData.hbpm,
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
    final db = _getDatabaseOrThrow();
    final signalId = await createSignal(bpModel);
    dev.log(">> DB: saving bp (SID: $signalId)");
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
    final db = _getDatabaseOrThrow();
    final signalId = await createSignal(btempModel);
    dev.log(">> DB: saving db (SID: $signalId)");
    return await db.insert(btempTable, {
      signalIdColumn: signalId,
      'body_temp': btempModel.avgTemp,
      'body_temp_max': btempModel.maxTemp,
      'body_temp_min': btempModel.minTemp,
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
  Future<Map<SignalType, List<Signal>>> getRecentRecords2(int userId,
      {int limit = 3}) async {
    final List<EcgModel> recentEcgRecords =
        await getEcgData(userId, limit: limit);
    final List<BpModel> recentBpRecords = await getBpData(userId, limit: limit);
    final List<BtempModel> recentBtempRecords =
        await getBtempData(userId, limit: limit);

    return {
      SignalType.ecg: recentEcgRecords,
      SignalType.bp: recentBpRecords,
      SignalType.btemp: recentBtempRecords,
    };
  }

  Future<Map<SignalType, List<Signal>>> getRecentRecords(int userId,
      {int limit = 3}) async {
    final db = await database;

    const String query = '''
    WITH RankedSignals AS (
      SELECT 
        s.$idColumn, 
        s.$userIdColumn, 
        s.$nameColumn,
        s.$startTimeColumn,
        s.$stopTimeColumn,
        s.$signalTypeColumn,
        s.$signalInfoColumn,
        e.ecg, e.hrv, e.hbpm,
        b.bp_systolic, b.bp_diastolic,
        t.body_temp, t.body_temp_min, t.body_temp_max,
        ROW_NUMBER() OVER (PARTITION BY s.$signalTypeColumn ORDER BY s.$startTimeColumn DESC) as rn
      FROM $signalTable s
      LEFT JOIN $ecgTable e ON s.$idColumn = e.$signalIdColumn AND s.$signalTypeColumn = 'ECG'
      LEFT JOIN $bpTable b ON s.$idColumn = b.$signalIdColumn AND s.$signalTypeColumn = 'BP'
      LEFT JOIN $btempTable t ON s.$idColumn = t.$signalIdColumn AND s.$signalTypeColumn = 'BTEMP'
      WHERE s.$userIdColumn = ?
      AND s.$signalTypeColumn IN ('ECG', 'BP', 'BTEMP')
    )
    SELECT * FROM RankedSignals
    WHERE rn <= ?
    ORDER BY $signalTypeColumn, $startTimeColumn DESC
  ''';

    final List<Map<String, dynamic>> results =
        await db.rawQuery(query, [userId, limit]);

    final Map<SignalType, List<Signal>> recentRecords = {
      SignalType.ecg: [],
      SignalType.bp: [],
      SignalType.btemp: [],
    };

    for (var row in results) {
      switch (row[signalTypeColumn]) {
        case 'ECG':
          final ecg = EcgModel.fromMap(row);
          recentRecords[SignalType.ecg]!.add(ecg);
          break;
        case 'BP':
          final bp = BpModel.fromMap(row);
          recentRecords[SignalType.bp]!.add(bp);
          break;
        case 'BTEMP':
          final btemp = BtempModel.fromMap(row);
          recentRecords[SignalType.btemp]!.add(btemp);
          break;
        default:
          throw ArgumentError('Unknown signal type: ${row[signalTypeColumn]}');
      }
    }

    return recentRecords;
  }

  Future<EcgModel> getLatestEcg(int userId) async {
    final List<EcgModel> recentEcgRecords = await getEcgData(userId, limit: 1);
    return recentEcgRecords.first;
  }
}
