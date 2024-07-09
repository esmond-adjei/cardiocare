import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cardiocare/services/models/signal_model.dart';
import 'package:cardiocare/utils/signal_generator.dart';

class MonitorState extends ChangeNotifier {
  // recording states: recording, pasued, resume, save, discard
  bool isRecording = false;
  bool isPaused = false;

  // create data: generator-to-subscriber, signal data type
  StreamSubscription<dynamic>? _subscription;
  final SignalGenerator _signalGenerator = SignalGenerator();
  final Stopwatch _stopwatch = Stopwatch();

  // save data: save-to-db method, signal data type
  final EcgModel _ecgSignal = EcgModel(userId: 1);
  final BpModel _bpSignal = BpModel(userId: 1);
  final BtempModel _btempSignal = BtempModel(userId: 1);

  // getters and setters
  EcgModel get ecgSignal => _ecgSignal;
  BpModel get bpSignal => _bpSignal;
  BtempModel get btempSignal => _btempSignal;

  Stopwatch get stopwatch => _stopwatch;

  // recording methods
  void startRecording(int tabIndex) {
    isRecording = true;
    isPaused = false;
    _stopwatch.start();
    notifyListeners();

    switch (tabIndex) {
      case 0:
        _subscription = _signalGenerator.generateECG().listen((value) {
          _ecgSignal.addEcgCache(value['ecg']);
          _ecgSignal.hrv = value['hrv'];
          _ecgSignal.hbpm = value['hbpm'];
          notifyListeners();
        });
        break;
      case 1:
        _subscription = _signalGenerator.generateBP().listen((value) {
          _bpSignal.bpData = value;
          notifyListeners();
        });
        break;
      case 2:
        _subscription = _signalGenerator.generateBtemp().listen((value) {
          _btempSignal.tempData = value;
          notifyListeners();
        });
        break;
    }
  }

  dynamic getCurrentSignal(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _ecgSignal;
      case 1:
        return _bpSignal;
      case 2:
        return _btempSignal;
    }
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

  void stopRecording() {
    isRecording = false;
    isPaused = false;
    _stopwatch.reset();
    _subscription?.cancel();
    _ecgSignal.clearEcg();
    notifyListeners();
  }
}
