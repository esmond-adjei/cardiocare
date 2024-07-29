import 'package:cardiocare/services/constants.dart';
import 'package:cardiocare/services/db_helper.dart';
import 'package:cardiocare/services/exceptions.dart';
import 'package:cardiocare/user_app/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class UserProvider {
  final DatabaseHelper dbHelper;

  UserProvider({required this.dbHelper});

  Future<Database> get database => dbHelper.database;

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
}
