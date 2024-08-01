import 'dart:developer' as dev;
import 'dart:async';
import 'dart:math';

import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

enum BluetoothConnectionState {
  disconnected,
  discovering,
  connecting,
  connected,
  error,
}

class CardioDevice {
  static const String _deviceName = 'CardioCare';
  static const String _deviceAddress = '00:22:12:01:62:6E';

  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothDevice? _targetDevice;
  BluetoothConnection? _connection;
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  StreamSubscription<Uint8List>? _inputStreamSubscription;

  BluetoothConnectionState _state = BluetoothConnectionState.disconnected;
  String _error = '';

  // Getters
  BluetoothConnectionState get state => _state;
  String get error => _error;
  bool get isConnected => _state == BluetoothConnectionState.connected;
  String get targetDeviceName => _deviceName;

  // Stream controller for state changes
  final _stateController =
      StreamController<BluetoothConnectionState>.broadcast();
  Stream<BluetoothConnectionState> get stateStream => _stateController.stream;

  // Stream controller for received data
  final _dataController = StreamController<Uint8List>.broadcast();
  Stream<Uint8List> get dataStream => _dataController.stream;

  void _setState(BluetoothConnectionState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  Future<void> startDiscovery() async {
    _setState(BluetoothConnectionState.discovering);

    try {
      bool isEnabled = await _bluetooth.requestEnable() ?? false;
      if (!isEnabled) {
        dev.log("Failed to enable Bluetooth");
        _error = "Failed to enable Bluetooth";
        _setState(BluetoothConnectionState.error);
        return;
      }

      _discoveryStreamSubscription = _bluetooth.startDiscovery().listen(
        (r) {
          dev.log("Discovered device: ${r.device.name}");
          if (r.device.address == _deviceAddress) {
            _targetDevice = r.device;
            dev.log("${r.device.name} @ ${r.device.address}");
            stopDiscovery();
            connectToDevice(r.device);
          }
        },
        onDone: () {
          dev.log("Discovery finished");
          if (_targetDevice == null) {
            _error = "Target device not found";
            _setState(BluetoothConnectionState.error);
          }
        },
        onError: (error) {
          dev.log("Error during discovery: $error");
          _error = "Error during device discovery";
          _setState(BluetoothConnectionState.error);
        },
      );
    } catch (e) {
      dev.log('Error during Bluetooth discovery: $e');
      _error = "An error occurred during Bluetooth operation";
      _setState(BluetoothConnectionState.error);
    }
  }

  Future<void> stopDiscovery() async {
    await _discoveryStreamSubscription?.cancel();
    _discoveryStreamSubscription = null;
    if (_state == BluetoothConnectionState.discovering) {
      _setState(BluetoothConnectionState.disconnected);
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (isConnected) return;

    _setState(BluetoothConnectionState.connecting);
    try {
      dev.log('Connecting to ${device.name}');
      _connection = await BluetoothConnection.toAddress(device.address);
      _setState(BluetoothConnectionState.connected);
      dev.log('Connected to ${device.name}');

      _inputStreamSubscription = _connection?.input?.listen(
        (data) {
          _dataController.add(data);
        },
        onDone: () {
          dev.log('Disconnected by remote device');
          disconnectFromDevice();
        },
        onError: (error) {
          dev.log('Error receiving data: $error');
          _error = "Error receiving data";
          _setState(BluetoothConnectionState.error);
        },
      );
    } catch (e) {
      dev.log('Error connecting to device: $e');
      _error = "Failed to connect to device";
      _setState(BluetoothConnectionState.error);
    }
  }

  Future<void> disconnectFromDevice() async {
    if (!isConnected) return;

    try {
      await _inputStreamSubscription?.cancel();
      await _connection?.close();
      dev.log('Disconnected from ${_targetDevice?.name}');
      _setState(BluetoothConnectionState.disconnected);
    } catch (e) {
      dev.log('Error disconnecting from device: $e');
      _error = "Failed to disconnect from device";
      _setState(BluetoothConnectionState.error);
    }
  }

  Future<void> sendData(Uint8List data) async {
    if (!isConnected) {
      dev.log('Cannot send data, device not connected');
      return;
    }
    try {
      _connection!.output.add(data);
      await _connection!.output.allSent;
      dev.log('Data sent: ${data.toString()}');
    } catch (e) {
      dev.log('Error sending data: $e');
      _error = "Failed to send data";
      _setState(BluetoothConnectionState.error);
    }
  }

  void dispose() {
    _stateController.close();
    _dataController.close();
    disconnectFromDevice();
  }
}

class VirtualDevice {
  final SignalGenerator _signalGenerator;
  StreamSubscription<dynamic>? _subscription;
  int _signalType = 1;
  bool _isRunning = false;

  VirtualDevice({SignalGenerator? signalGenerator})
      : _signalGenerator = signalGenerator ?? SignalGenerator();

  void selectSignalMode(int mode) {
    if (mode < 1 || mode > 3) {
      throw ArgumentError('Invalid signal mode. Must be 1, 2, or 3.');
    }
    _signalType = mode;
  }

  void listenToSignalStream(Function(dynamic) processData) {
    if (_isRunning) {
      dev.log(
          'Signal stream is already running. Stop it before starting a new one.');
      return;
    }

    Stream<dynamic> stream;
    switch (_signalType) {
      case 1:
        stream = _signalGenerator.generateECG();
        break;
      case 2:
        stream = _signalGenerator.generateBP();
        break;
      case 3:
        stream = _signalGenerator.generateBtemp();
        break;
      default:
        throw StateError('Invalid signal type: $_signalType');
    }

    _subscription = stream.listen(
      processData,
      onError: (error) => dev.log('Error in signal stream: $error'),
      onDone: () {
        _isRunning = false;
        dev.log('Signal stream completed');
      },
    );
    _isRunning = true;
  }

  void pauseListening() {
    _subscription?.pause();
    _isRunning = false;
  }

  void resumeListening() {
    _subscription?.resume();
    _isRunning = true;
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isRunning = false;
  }

  bool get isRunning => _isRunning;

  void dispose() {
    stopListening();
  }
}

class SignalGenerator {
  final int durationSeconds;
  final int samplingRate;

  SignalGenerator({
    this.durationSeconds = 60 * 60, // one hour
    this.samplingRate = 2,
  });

  Stream<Map<String, dynamic>> generateECG() async* {
    const int fs = 500;
    const double baseHeartRate = 60.0;
    final random = Random();
    List<double> rrIntervals = [];
    List<int> heartRates = [];

    double time = 0;
    while (time < durationSeconds) {
      double heartRate =
          baseHeartRate + random.nextDouble() * 20 - 10; // between 50-70 bpm
      double rrInterval = 60 / heartRate;
      rrIntervals.add(rrInterval);
      heartRates.add(heartRate.round());
      time += rrInterval;
    }

    List<double> t = [];
    List<double> ecg = [];

    for (int i = 0; i < rrIntervals.length; i++) {
      double beatTime = t.isEmpty ? 0 : t.last;
      List<double> beatT = List.generate(
          (rrIntervals[i] * fs).round(), (j) => beatTime + j / fs);
      t.addAll(beatT);

      for (double ti in beatT) {
        double pWave = exp(-pow((ti - beatTime - 0.1), 2) / (2 * pow(0.01, 2)));
        double qWave =
            -exp(-pow((ti - beatTime - 0.16), 2) / (2 * pow(0.02, 2)));
        double rWave =
            2 * exp(-pow((ti - beatTime - 0.2), 2) / (2 * pow(0.02, 2)));
        double sWave =
            -exp(-pow((ti - beatTime - 0.26), 2) / (2 * pow(0.02, 2)));
        double tWave =
            0.5 * exp(-pow((ti - beatTime - 0.4), 2) / (2 * pow(0.04, 2)));

        ecg.add(pWave + qWave + rWave + sWave + tWave);
      }
    }

    // Normalize the ecg values to be within 0-255 range
    double minValue = ecg.reduce(min);
    double maxValue = ecg.reduce(max);
    double range = maxValue - minValue;

    // Calculate HRV (SDNN - Standard Deviation of NN intervals)
    double meanRR = rrIntervals.reduce((a, b) => a + b) / rrIntervals.length;
    num sumSquaredDiff =
        rrIntervals.map((rr) => pow(rr - meanRR, 2)).reduce((a, b) => a + b);
    double sdnn = sqrt(sumSquaredDiff / (rrIntervals.length - 1));
    // ROOT(SUM((rr - rm)^2)) / (n - 1)

    int currentBeatIndex = 0;
    for (int i = 0; i < t.length; i++) {
      await Future.delayed(Duration(milliseconds: (100 / fs).round()));
      if (i / fs >=
          rrIntervals.take(currentBeatIndex + 1).reduce((a, b) => a + b)) {
        currentBeatIndex++;
      }
      dev.log("hbpm: ${heartRates[currentBeatIndex]}, hrv: $sdnn");
      yield {
        'ecg': ((ecg[i] - minValue) / range * 255).round(),
        'hbpm': heartRates[currentBeatIndex],
        'hrv': sdnn,
      };
    }
  }

  Stream<List<int>> generateBP() async* {
    const int bpNoiseAmplitude = 5;
    final numSamples = durationSeconds * samplingRate;
    var systolic = 120;
    var diastolic = 80;
    final random = Random();

    for (int i = 0; i < numSamples; i++) {
      systolic += random.nextInt(2 * bpNoiseAmplitude + 1) - bpNoiseAmplitude;
      diastolic += random.nextInt(2 * bpNoiseAmplitude + 1) - bpNoiseAmplitude;

      systolic = systolic.clamp(90, 180);
      diastolic = diastolic.clamp(60, 110);

      dev.log('Systolic: $systolic, Diastolic: $diastolic');

      yield [systolic, diastolic];
      await Future.delayed(
          Duration(milliseconds: (1000 / samplingRate).round()));
    }
  }

  Stream<Map<String, double>> generateBtemp() async* {
    const double tempNoiseAmplitude = 0.5;
    final numSamples = durationSeconds * samplingRate;
    var temp = 37.0;
    final random = Random();
    double minTemp = temp;
    double maxTemp = temp;
    double sumTemp = 0;

    for (int i = 0; i < numSamples; i++) {
      temp += random.nextDouble() * 2 * tempNoiseAmplitude - tempNoiseAmplitude;
      temp = temp.clamp(35.0, 40.0);

      minTemp = min(minTemp, temp);
      maxTemp = max(maxTemp, temp);
      sumTemp += temp;

      dev.log('Temperature: $temp');

      yield {
        // 'current': temp,
        'minTemp': minTemp,
        'maxTemp': maxTemp,
        'avgTemp': (sumTemp / (i + 1)),
      };
      await Future.delayed(
          Duration(milliseconds: (1000 / samplingRate).round()));
    }
  }
}
