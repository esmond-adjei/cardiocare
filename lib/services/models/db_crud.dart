import 'package:xmonapp/services/models/db_model.dart';
import 'package:xmonapp/services/models/db_helper.dart';

// ECG DATA
void saveEcgData(int userId, List<int> ecg) async {
  // DatabaseHelper dbHelper = DatabaseHelper();
  // await dbHelper.createEcgData(userId, ecg);
}

// BP DATA
void saveBpData(int userId, int systolic, int diastolic) async {
  // DatabaseHelper dbHelper = DatabaseHelper();
  // await dbHelper.createBpData(userId, systolic, diastolic);
}

// BODY TEMPERATURE DATA
void saveBtempData(int userId, double temperature) async {
  // DatabaseHelper dbHelper = DatabaseHelper();
  // await dbHelper.getBtempData(userId, temperature);
}

Future<List<EcgModel>> getEcgData(int userId) async {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<EcgModel> result = await dbHelper.getEcgData(userId);
  return result;
}

Future<List<BpModel>> getBpData(int userId) async {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<BpModel> result = await dbHelper.getBpData(userId);
  return result;
}

Future<List<BtempModel>> getBtempData(int userId) async {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<BtempModel> result = await dbHelper.getBtempData(userId);
  return result;
}
