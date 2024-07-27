import 'dart:developer' as dev;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cardiocare/signal_app/model/signal_model.dart';
import 'package:cardiocare/utils/signal_generator.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

enum BluetoothConnectionState {
  disconnected,
  discovering,
  connecting,
  connected,
  error,
}

class BluetoothConnectState extends ChangeNotifier {
  // Bluetooth states
  BluetoothConnectionState _bluetoothState =
      BluetoothConnectionState.disconnected;
  String _bluetoothError = '';
  BluetoothDevice? _targetDevice;
  final String _targetDeviceName = 'CardioCare';
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;

  // getters and setters
  BluetoothConnectionState get bluetoothState => _bluetoothState;
  String get bluetoothError => _bluetoothError;
  bool get isBluetoothConnected =>
      _bluetoothState == BluetoothConnectionState.connected;
  String get targetDeviceName => _targetDeviceName;

  void _setBluetoothState(BluetoothConnectionState status) {
    _bluetoothState = status;
    notifyListeners();
  }

  // start discovery
  Future<void> startDiscovery() async {
    _setBluetoothState(BluetoothConnectionState.discovering);

    try {
      bool isEnabled = await _bluetooth.requestEnable() ?? false;
      if (!isEnabled) {
        dev.log("Failed to enable Bluetooth");
        _bluetoothError = "Failed to enable Bluetooth";
      }

      _discoveryStreamSubscription = _bluetooth.startDiscovery().listen(
        (r) {
          dev.log("Discovered device: ${r.device.name}");
          if (r.device.name == _targetDeviceName) {
            _targetDevice = r.device;
            stopDiscovery();
            connectToDevice(_targetDevice!);
          }
        },
        onDone: () {
          dev.log("Discovery finished");
          if (_targetDevice == null) {
            _bluetoothError = "Target device not found";
            _setBluetoothState(BluetoothConnectionState.connected);
          }
        },
        onError: (error) {
          dev.log("Error during discovery: $error");
          _bluetoothError = "Error during device discovery";
          _setBluetoothState(BluetoothConnectionState.error);
        },
      );
    } catch (e) {
      dev.log('Error during Bluetooth discovery: $e');
      _bluetoothError = "An error occurred during Bluetooth operation";
      _setBluetoothState(BluetoothConnectionState.error);
    }
  }

  // stop discovery
  Future<void> stopDiscovery() async {
    _discoveryStreamSubscription?.cancel();
    _setBluetoothState(BluetoothConnectionState.disconnected);
  }

  // connect to device
  Future<void> connectToDevice(BluetoothDevice device) async {
    if (isBluetoothConnected) {
      return;
    }

    _setBluetoothState(BluetoothConnectionState.connecting);
    try {
      dev.log('Connecting to ${device.name}');
      _connection = await BluetoothConnection.toAddress(device.address);
      dev.log('Connected to ${device.name}');

      _setBluetoothState(BluetoothConnectionState.connected);

      // _connection.input.
    } catch (e) {
      dev.log('Error connecting to device: $e');
      _bluetoothError = "Failed to connect to device";
      _setBluetoothState(BluetoothConnectionState.error);
    }
  }

// disconnect from device
  Future<void> disconnectFromDevice() async {
    if (!isBluetoothConnected) {
      return;
    }
    try {
      await _connection?.close();
      dev.log('Disconnected from ${_targetDevice?.name}');
      _setBluetoothState(BluetoothConnectionState.disconnected);
    } catch (e) {
      dev.log('Error disconnecting from device: $e');
      _bluetoothError = "Failed to disconnect from device";
      _setBluetoothState(BluetoothConnectionState.error);
    }
  }
}

class MonitorState extends ChangeNotifier {
  // recording states: recording, paused, resume, save, discard
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
