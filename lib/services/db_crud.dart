import 'package:xmonapp/services/db_schema.dart';
import 'package:xmonapp/services/db_helper.dart';

// ECG DATA
void saveEcgData(int userId, List<int> ecg) async {
  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.insertEcgData(userId, ecg);
  print("successfully inserted ECG data");
}

// BP DATA
void saveBpData(int userId, int systolic, int diastolic) async {
  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.insertBpData(userId, systolic, diastolic);
}

// BODY TEMPERATURE DATA
void saveTemperatureData(int userId, double temperature) async {
  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.insertTemperatureData(userId, temperature);
}

Future<List<EcgData>> getEcgData(int userId) async {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> result = await dbHelper.getEcgData(userId);
  return result.map((map) => EcgData.fromMap(map)).toList();
}

Future<List<BpData>> getBpData(int userId) async {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> result = await dbHelper.getBpData(userId);
  return result.map((map) => BpData.fromMap(map)).toList();
}

Future<List<TemperatureData>> getTemperatureData(int userId) async {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> result = await dbHelper.getTemperatureData(userId);
  return result.map((map) => TemperatureData.fromMap(map)).toList();
}
