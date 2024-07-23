import 'dart:async';
// import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:cardiocare/signal_app/model/signal_model.dart';
import 'package:cardiocare/utils/signal_generator.dart';

class MonitorState extends ChangeNotifier {
  // recording states: recording, pasued, resume, save, discard
  bool isRecording = false;
  bool isPaused = false;
  bool _isBluetoothConnected = false;

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
  bool get isBluetoothConnected => _isBluetoothConnected;

  Stopwatch get stopwatch => _stopwatch;

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

  void setBluetoothConnected(bool isConnected) {
    _isBluetoothConnected = isConnected;
    notifyListeners();
  }

  // recording methods
  void startRecording(int tabIndex) {
    isRecording = true;
    isPaused = false;
    _stopwatch.start();
    notifyListeners();

    switch (tabIndex) {
      case 0:
        _ecgSignal.starttime = DateTime.now();
        _subscription = _signalGenerator.generateECG().listen((value) {
          _ecgSignal.addEcgCache(value['ecg']);
          _ecgSignal.hrv = value['hrv'];
          _ecgSignal.hbpm = value['hbpm'];
          notifyListeners();
        });
        break;
      case 1:
        _bpSignal.starttime = DateTime.now();
        _subscription = _signalGenerator.generateBP().listen((value) {
          _bpSignal.bpData = value;
          notifyListeners();
        });
        break;
      case 2:
        _btempSignal.starttime = DateTime.now();
        _subscription = _signalGenerator.generateBtemp().listen((value) {
          _btempSignal.tempData = value;
          notifyListeners();
        });
        break;
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
