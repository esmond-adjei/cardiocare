import 'dart:math';

class DummyDataGenerator {
  final Random _random = Random();

  List<int> generateEcgData() {
    return List<int>.generate(100, (_) => _random.nextInt(256));
  }

  Map<String, int> generateBpData() {
    int systolic = 90 + _random.nextInt(51); // 90 to 140
    int diastolic = 60 + _random.nextInt(41); // 60 to 100
    return {'systolic': systolic, 'diastolic': diastolic};
  }

  double generateTemperatureData() {
    return 36.0 + _random.nextDouble() * 2.0; // 36.0 to 38.0
  }
}
