import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cardiocare/services/models/signal_model.dart';
import 'package:cardiocare/utils/signal_generator.dart';

class MonitorState extends ChangeNotifier {
  bool isRecording = false;
  bool isPaused = false;

  final List<int> _ecgValues = [];
  List<int> _bpValues = [120, 80];
  double _btempValue = 36.1;

  StreamSubscription<dynamic>? _subscription;
  final SignalGenerator _signalGenerator = SignalGenerator();
  final Stopwatch _stopwatch = Stopwatch();

  dynamic _currentSignal;

  List<int> get ecgValues => _ecgValues;
  List<int> get bpValues => _bpValues;
  double get btempValue => _btempValue;
  Stopwatch get stopwatch => _stopwatch;

  get currentSignal => _currentSignal;

  void startRecording(int tabIndex) {
    _ecgValues.clear();
    isRecording = true;
    isPaused = false;
    _stopwatch.start();
    notifyListeners();

    switch (tabIndex) {
      case 0:
        _currentSignal = EcgModel(
          userId: 1,
          startTime: DateTime.now(),
          stopTime: DateTime.now(),
        );
        _subscription = _signalGenerator.generateECG().listen((value) {
          _ecgValues.add(value);
          notifyListeners();
        });
        break;
      case 1:
        _currentSignal = BpModel(
          userId: 1,
          startTime: DateTime.now(),
          stopTime: DateTime.now(),
        );
        _subscription = _signalGenerator.generateBP().listen((value) {
          _bpValues = value;
          notifyListeners();
        });
        break;
      case 2:
        _currentSignal = BtempModel(
          userId: 1,
          startTime: DateTime.now(),
          stopTime: DateTime.now(),
        );
        _subscription = _signalGenerator.generateBtemp().listen((value) {
          _btempValue = value;
          notifyListeners();
        });
        break;
    }
  }

  void stopRecording() {
    isRecording = false;
    isPaused = false;
    _ecgValues.clear();
    _btempValue = 36.1;
    _stopwatch.reset();
    _subscription?.cancel();
    notifyListeners();
  }

  void pauseRecording() {
    isPaused = true;
    _stopwatch.stop();
    _subscription?.pause();
    notifyListeners();
  }

  void resumeRecording() {
    isPaused = false;
    _stopwatch.start();
    _subscription?.resume();
    notifyListeners();
  }
}
