import 'dart:developer' as dev;
import 'package:cardiocare/chatbot_app/chat_model.dart';
import 'package:cardiocare/signal_app/model/signal_enums.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:cardiocare/services/constants.dart';
import 'package:cardiocare/services/exceptions.dart';
import 'package:cardiocare/signal_app/model/signal_model.dart';
import 'package:cardiocare/user_app/models/user_model.dart';

class DatabaseHelper extends ChangeNotifier {
  static Database? _db;
  static const int _v = 2;
  static const List dbTables = [
    createUserTable,
    createMedicalInfoTable,
    createEmergencyContactTable,
    createUserProfileTable,
    createSignalTable,
    createECGTable,
    createBPTable,
    createBTempTable,
    createChatHistoryTable,
  ];

  DatabaseHelper._internal();
  factory DatabaseHelper() => DatabaseHelper._internal();

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
          for (var database in dbTables) {
            await db.execute(database);
            dev.log('>> Created table: $database');
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

  // User CRUD operations
  Future<CardioUser> createUser({required CardioUser user}) async {
    final db = await database;
    final results = await db.query(
      userTable,
      limit: 1,
      where: '$emailColumn = ?',
      whereArgs: [user.email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, user.toMap());
    return user.copyWith(id: userId);
  }

  Future<List<CardioUser>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(userTable);
    return results.map((map) => CardioUser.fromMap(map)).toList();
  }

  Future<CardioUser> getUser({required String email}) async {
    final db = await database;
    final results = await db.query(
      userTable,
      limit: 1,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw UserDoesNotExist();
    }
    return CardioUser.fromMap(results.first);
  }

  Future<int> updateUser(CardioUser user) async {
    await getUser(email: user.email);
    final db = await database;
    return db.update(
      userTable,
      user.toMap(),
      where: '$emailColumn = ?',
      whereArgs: [user.email],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteUser({required String email}) async {
    final db = await database;
    final response = await db.delete(
      userTable,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (response != 1) {
      throw UserDoesNotExist();
    }
    return response;
  }

  // UserProfile CRUD operations
  Future<int> createUserProfile(UserProfile profile) async {
    final db = await database;
    return await db.insert(userProfileTable, profile.toMap());
  }

  Future<UserProfile?> getUserProfile(int userId) async {
    final db = await database;
    final results = await db.query(
      userProfileTable,
      where: '$userIdColumn = ?',
      whereArgs: [userId],
    );
    if (results.isEmpty) {
      return null;
    }
    return UserProfile.fromMap(results.first);
  }

  Future<int> updateUserProfile(UserProfile profile, int userId) async {
    final db = await database;
    return await db.update(
      userProfileTable,
      profile.toMap(),
      where: '$userIdColumn = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteUserProfile(int userId) async {
    final db = await database;
    return await db.delete(
      userProfileTable,
      where: '$userIdColumn = ?',
      whereArgs: [userId],
    );
  }

  // MedicalInfo CRUD operations
  Future<int> createMedicalInfo(MedicalInfo medicalInfo) async {
    final db = _getDatabaseOrThrow();
    return await db.insert(medicalInfoTable, medicalInfo.toMap());
  }

  Future<List<MedicalInfo>> getMedicalInfo(int userId) async {
    final db = await database;
    final results = await db.query(
      medicalInfoTable,
      where: '$userIdColumn = ?',
      whereArgs: [userId],
    );
    return results.map((map) => MedicalInfo.fromMap(map)).toList();
  }

  Future<int> updateMedicalInfo(MedicalInfo medicalInfo, int userId) async {
    final db = await database;
    return await db.update(
      medicalInfoTable,
      medicalInfo.toMap(),
      where: '$userIdColumn = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteMedicalInfo(int userId) async {
    final db = await database;
    return await db.delete(
      medicalInfoTable,
      where: '$userIdColumn = ?',
      whereArgs: [userId],
    );
  }

  // EmergencyContact CRUD operations
  Future<int> createEmergencyContact(EmergencyContact contact) async {
    final db = _getDatabaseOrThrow();
    return await db.insert(emergencyContactTable, contact.toMap());
  }

  Future<List<EmergencyContact>> getEmergencyContacts(int userId) async {
    final db = await database;
    final results = await db.query(
      emergencyContactTable,
      where: '$userIdColumn = ?',
      whereArgs: [userId],
    );
    return results.map((map) => EmergencyContact.fromMap(map)).toList();
  }

  Future<int> updateEmergencyContact(
      EmergencyContact contact, int userId) async {
    final db = await database;
    return await db.update(
      emergencyContactTable,
      contact.toMap(),
      where: '$userIdColumn = ? AND $contactNameColumn = ?',
      whereArgs: [userId, contact.name],
    );
  }

  Future<int> deleteEmergencyContact(int userId, String name) async {
    final db = await database;
    return await db.delete(
      emergencyContactTable,
      where: '$userIdColumn = ? AND $contactNameColumn = ?',
      whereArgs: [userId, name],
    );
  }

  // =========== MANAGE CHAT HISTORY ===========
  Future<int> createChatMessage(int userId, ChatMessage message) async {
    final db = await database;
    final map = message.toMap();
    map[userIdColumn] = userId;
    return await db.insert(chatHistoryTable, map);
  }

  Future<List<ChatMessage>> getChatHistory(int userId, {int? limit}) async {
    final db = await database;
    final results = await db.query(
      chatHistoryTable,
      where: '$userIdColumn = ?',
      whereArgs: [userId],
      orderBy: timestampColumn,
      limit: limit,
    );

    return results.map((map) => ChatMessage.fromMap(map)).toList();
  }

  Future<int> updateChatMessageStatus(
      DateTime timestamp, MessageStatus newStatus) async {
    final db = await database;
    return await db.update(
      chatHistoryTable,
      {'status': newStatus.index},
      where: '$timestampColumn = ?',
      whereArgs: [timestamp.toIso8601String()],
    );
  }

  Future<int> deleteChatMessage(DateTime timestamp) async {
    final db = await database;
    return await db.delete(
      chatHistoryTable,
      where: '$timestampColumn = ?',
      whereArgs: [timestamp.toIso8601String()],
    );
  }

  Future<int> clearChatHistory(int userId) async {
    final db = await database;
    return await db.delete(
      chatHistoryTable,
      where: '$userIdColumn = ?',
      whereArgs: [userId],
    );
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
      where: '$idColumn =?',
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

    dev.log(">> deleting ${signal.signalId} from $table");

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

  // ==================== DASHBOARD ====================
  Future<List<Signal>> getRecentRecords(int userId, {int limit = 3}) async {
    // get top 3 ecg records
    final List<EcgModel> recentEcgRecords = await getEcgData(userId, limit: 3);
    // get top 3 bp records
    final List<BpModel> recentBpRecords = await getBpData(userId, limit: 3);
    // get top 3 btemp records
    final List<BtempModel> recentBtempRecords =
        await getBtempData(userId, limit: 3);

    // combine all records and order by createdAt and send top 3
    final List<Signal> allRecords = [
      ...recentEcgRecords,
      ...recentBpRecords,
      ...recentBtempRecords
    ];
    allRecords.sort((a, b) => b.stopTime.compareTo(a.stopTime));

    return allRecords.take(limit).toList();
  }

  Future<EcgModel?> getLatestEcg(int userId) async {
    final List<EcgModel> recentEcgRecords = await getEcgData(userId, limit: 1);
    return recentEcgRecords.isNotEmpty ? recentEcgRecords.first : null;
  }

  // =========== ADDITIONAL UTILITY METHODS ===========
  Future<void> deleteAllUserData(int userId) async {
    final db = await database;
    await db.transaction((txn) async {
      // Delete user's medical info
      await txn.delete(medicalInfoTable,
          where: '$userIdColumn = ?', whereArgs: [userId]);

      // Delete user's chat history
      await txn.delete(chatHistoryTable,
          where: '$userIdColumn = ?', whereArgs: [userId]);

      // Delete user's signals and related data
      final signalIds = await txn.query(signalTable,
          columns: [idColumn], where: '$userIdColumn = ?', whereArgs: [userId]);

      for (var signal in signalIds) {
        int signalId = signal[idColumn] as int;
        await txn.delete(ecgTable,
            where: '$signalIdColumn = ?', whereArgs: [signalId]);
        await txn.delete(bpTable,
            where: '$signalIdColumn = ?', whereArgs: [signalId]);
        await txn.delete(btempTable,
            where: '$signalIdColumn = ?', whereArgs: [signalId]);
      }

      await txn
          .delete(signalTable, where: '$userIdColumn = ?', whereArgs: [userId]);

      // Finally, delete the user
      await txn.delete(userTable, where: '$idColumn = ?', whereArgs: [userId]);
    });
    notifyListeners();
  }
}
