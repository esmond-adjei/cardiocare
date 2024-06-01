import 'package:xmonapp/services/models/db_model.dart';
import 'package:xmonapp/services/models/db_helper.dart';

// ECG DATA
void saveEcgData(int userId, List<int> ecg) async {
  // DatabaseHelper dbHelper = DatabaseHelper();
  // await dbHelper.insertEcgData(userId, ecg);
}

// BP DATA
void saveBpData(int userId, int systolic, int diastolic) async {
  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.insertBpData(userId, systolic, diastolic);
}

// BODY TEMPERATURE DATA
void saveBtempData(int userId, double temperature) async {
  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.insertTemperatureData(userId, temperature);
}

Future<List<EcgModel>> getEcgData(int userId) async {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> result = await dbHelper.getEcgData(userId);
  return result.map((map) => EcgModel.fromMap(map)).toList();
}

Future<List<BpModel>> getBpData(int userId) async {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> result = await dbHelper.getBpData(userId);
  return result.map((map) => BpModel.fromMap(map)).toList();
}

Future<List<BtempModel>> getBtempData(int userId) async {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> result = await dbHelper.getBpData(userId);
  return result.map((map) => BtempModel.fromMap(map)).toList();
}
