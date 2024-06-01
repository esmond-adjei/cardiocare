import 'dart:math';

class DummyDataGenerator {
  final Random _random = Random();

  List<int> generateEcgData() {
    return List<int>.generate(100, (_) => _random.nextInt(256));
  }

  Map<String, int> generateBpData() {
    int systolic = 90 + _random.nextInt(51);
    int diastolic = 60 + _random.nextInt(41);
    return {'systolic': systolic, 'diastolic': diastolic};
  }

  double generateBtempData() {
    return 36.0 + _random.nextDouble() * 2.0;
  }
}
