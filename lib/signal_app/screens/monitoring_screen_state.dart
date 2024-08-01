import 'dart:developer' as dev;
import 'dart:async';
import 'package:cardiocare/services/preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:cardiocare/signal_app/model/signal_model.dart';
import 'package:cardiocare/signal_app/model/signal_device.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

enum DeviceType { real, virtual }

class SignalMonitorState extends ChangeNotifier {
  final SharedPreferencesManager _preferencesManager;
  late dynamic _device;

  final EcgModel _ecgSignal;
  final BpModel _bpSignal;
  final BtempModel _btempSignal;

  bool isRecording = false;
  bool isPaused = false;
  final Stopwatch _stopwatch = Stopwatch();
  int _currentMode = -1;
  late DateTime _startTime;

  SignalMonitorState(this._preferencesManager)
      : _ecgSignal = EcgModel(userId: 1),
        _bpSignal = BpModel(userId: 1),
        _btempSignal = BtempModel(userId: 1) {
    _initializeDevice();
    _preferencesManager.addListener(_onSettingsChanged);
  }

  void _initializeDevice() {
    if (_preferencesManager.appSettings.isDemoMode &&
        _preferencesManager.appSettings.isVirtualDevice) {
      _device = VirtualDevice();
    } else {
      _device = CardioDevice();
      _device.stateStream.listen((state) => notifyListeners());
      _device.dataStream.listen(_processRealDeviceData);
    }
  }

  void _onSettingsChanged() {
    _initializeDevice();
    notifyListeners();
  }

  // Getters
  BluetoothConnectionState get bluetoothState => _device is VirtualDevice
      ? BluetoothConnectionState.connected
      : _device.state;
  String get bluetoothError => _device.error;
  bool get isBluetoothConnected =>
      _device is VirtualDevice ? true : _device.isConnected;
  bool get isVirtualDevice => _device is VirtualDevice ? true : false;
  String get targetDeviceName => _device.targetDeviceName;
  EcgModel get ecgSignal => _ecgSignal;
  BpModel get bpSignal => _bpSignal;
  BtempModel get btempSignal => _btempSignal;
  Stopwatch get stopwatch => _stopwatch;

  Future<void> startDiscovery() async {
    if (_device is CardioDevice) {
      await _device.startDiscovery();
    }
  }

  Future<void> stopDiscovery() async {
    if (_device is CardioDevice) {
      await _device.stopDiscovery();
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_device is CardioDevice) {
      await _device.connectToDevice(device);
    }
  }

  Future<void> disconnectFromDevice() async {
    if (_device is CardioDevice) {
      await _device.sendData(Uint8List.fromList([0]));
      await _device.disconnectFromDevice();
    }
  }

  Future<void> startRecording(int mode) async {
    if (!isBluetoothConnected && _device is CardioDevice) {
      dev.log('Cannot send mode, device not connected');
      return;
    }
    if (mode < 0 || mode > 3) {
      dev.log('Invalid mode selected');
      return;
    }

    isRecording = true;
    isPaused = false;
    _stopwatch.start();
    _currentMode = mode;
    _startTime = DateTime.now();
    notifyListeners();

    if (_device is VirtualDevice) {
      Signal currentSignal = getCurrentSignal(mode);
      currentSignal.starttime = _startTime;
      _device.selectSignalMode(mode);
      _device.listenToSignalStream(_processVirtualDeviceData);
    } else {
      await _device.sendData(Uint8List.fromList([mode]));
    }
  }

  void pauseRecording() {
    isPaused = true;
    _stopwatch.stop();
    if (_device is VirtualDevice) {
      _device.pauseListening();
    }
    notifyListeners();
  }

  void resumeRecording() {
    isPaused = false;
    _stopwatch.start();
    if (_device is VirtualDevice) {
      _device.resumeListening();
    }
    notifyListeners();
  }

  void stopRecording() async {
    isRecording = false;
    isPaused = false;

    _ecgSignal.clearEcg();
    minTemp = 100.0;
    maxTemp = 0.0;
    parsedNumber = 0.0;
    ecgValue = 0;

    _stopwatch.stop();
    _stopwatch.reset();
    if (_device is VirtualDevice) {
      _device.stopListening();
    } else {
      await _device.sendData(Uint8List.fromList([0]));
    }
    notifyListeners();
  }

  // Utilities
  Signal getCurrentSignal(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _ecgSignal;
      case 1:
        return _bpSignal;
      case 2:
        return _btempSignal;
      default:
        return _ecgSignal;
    }
  }

  double minTemp = 100.0;
  double maxTemp = 0.0;
  double parsedNumber = 0.0;
  int ecgValue = 0;

  void _processRealDeviceData(Uint8List data) {
    String strData = String.fromCharCodes(data);
    switch (_currentMode) {
      case 1:
        try {
          ecgValue = int.parse(strData);
          _ecgSignal.addEcgCache(ecgValue);
        } catch (e) {
          dev.log("Error parsing ECG data: $e");
        }
        break;
      case 2:
        dev.log('Updating BP data: $strData');
        break;
      case 3:
        try {
          parsedNumber =
              double.parse(strData) + 3; // adjusting for body temperature
          if (parsedNumber > 0) {
            minTemp = parsedNumber < minTemp ? parsedNumber : minTemp;
            maxTemp = parsedNumber > maxTemp ? parsedNumber : maxTemp;
          }
          _btempSignal.avgTemp = parsedNumber;
          _btempSignal.minTemp = minTemp;
          _btempSignal.maxTemp = maxTemp;
          notifyListeners();
        } catch (e) {
          dev.log("Error parsing temperature data: $e");
        }
        break;
      default:
        dev.log('Invalid mode: $_currentMode');
    }
    notifyListeners();
  }

  void _processVirtualDeviceData(dynamic data) {
    switch (_currentMode) {
      case 1:
        _ecgSignal.addEcgCache(data['ecg']);
        _ecgSignal.hrv = data['hrv'];
        _ecgSignal.hbpm = data['hbpm'];
        break;
      case 2:
        _bpSignal.bpData = data as List<int>;
        break;
      case 3:
        _btempSignal.tempData = data as Map<String, double>;
        break;
      default:
        dev.log('Invalid mode: $_currentMode');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _preferencesManager.removeListener(_onSettingsChanged);
    _device.dispose();
    super.dispose();
  }
}
// class SignalMonitorState extends ChangeNotifier {
//   // Bluetooth states
//   BluetoothConnectionState _bluetoothState =
//       BluetoothConnectionState.disconnected;
//   String _bluetoothError = '';
//   BluetoothDevice? _targetDevice;
//   final String _targetDeviceName = 'CardioCare';
//   final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
//   BluetoothConnection? _connection;
//   StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
//   StreamSubscription<Uint8List>? _inputStreamSubscription;

//   // virtual device
//   final VirtualDevice _virtualDevice = VirtualDevice();

//   // Signal models
//   final EcgModel _ecgSignal = EcgModel(userId: 1);
//   final BpModel _bpSignal = BpModel(userId: 1);
//   final BtempModel _btempSignal = BtempModel(userId: 1);

//   // Recording states
//   bool isRecording = false;
//   bool isPaused = false;
//   final Stopwatch _stopwatch = Stopwatch();
//   int _currentMode = -1;
//   late DateTime _startTime; // = DateTime.now();

//   // Getters
//   BluetoothConnectionState get bluetoothState => _bluetoothState;
//   String get bluetoothError => _bluetoothError;
//   bool get isBluetoothConnected =>
//       _bluetoothState == BluetoothConnectionState.connected;
//   String get targetDeviceName => _targetDeviceName;
//   EcgModel get ecgSignal => _ecgSignal;
//   BpModel get bpSignal => _bpSignal;
//   BtempModel get btempSignal => _btempSignal;
//   Stopwatch get stopwatch => _stopwatch;

//   void _setBluetoothState(BluetoothConnectionState status) {
//     _bluetoothState = status;
//     notifyListeners();
//   }

//   // ============== DISCOVERY AND CONNECTION STATES =================
//   // Start discovery
//   Future<void> startDiscovery() async {
//     if (DEVICE_TYPE == DeviceType.virtual) {
//       _setBluetoothState(BluetoothConnectionState.connected);
//       return;
//     }

//     _setBluetoothState(BluetoothConnectionState.discovering);

//     try {
//       bool isEnabled = await _bluetooth.requestEnable() ?? false;
//       if (!isEnabled) {
//         dev.log("Failed to enable Bluetooth");
//         _bluetoothError = "Failed to enable Bluetooth";
//       }

//       _discoveryStreamSubscription = _bluetooth.startDiscovery().listen(
//         (r) {
//           dev.log("Discovered device: ${r.device.name}");
//           if (r.device.name == _targetDeviceName) {
//             _targetDevice = r.device;
//             stopDiscovery();
//             connectToDevice(_targetDevice!);
//           }
//         },
//         onDone: () {
//           dev.log("Discovery finished");
//           if (_targetDevice == null) {
//             _bluetoothError = "Target device not found";
//             _setBluetoothState(BluetoothConnectionState.error);
//           }
//         },
//         onError: (error) {
//           dev.log("Error during discovery: $error");
//           _bluetoothError = "Error during device discovery";
//           _setBluetoothState(BluetoothConnectionState.error);
//         },
//       );
//     } catch (e) {
//       dev.log('Error during Bluetooth discovery: $e');
//       _bluetoothError = "An error occurred during Bluetooth operation";
//       _setBluetoothState(BluetoothConnectionState.error);
//     }
//   }

//   // Stop discovery
//   Future<void> stopDiscovery() async {
//     await _discoveryStreamSubscription?.cancel();
//     _discoveryStreamSubscription = null;
//     _setBluetoothState(BluetoothConnectionState.disconnected);
//   }

//   // Connect to device
//   Future<void> connectToDevice(BluetoothDevice device) async {
//     if (isBluetoothConnected) {
//       return;
//     }

//     _setBluetoothState(BluetoothConnectionState.connecting);
//     try {
//       dev.log('Connecting to ${device.name}');
//       _connection = await BluetoothConnection.toAddress(device.address);
//       _setBluetoothState(BluetoothConnectionState.connected);
//       dev.log('Connected to ${device.name}');

//       // stream from bluetooth device
//       _inputStreamSubscription =
//           _connection?.input?.listen(_onDataReceived, onDone: () {
//         dev.log('Disconnected by remote device');
//         disconnectFromDevice();
//       }, onError: (error) {
//         dev.log('Error receiving data: $error');
//         _bluetoothError = "Error receiving data";
//         _setBluetoothState(BluetoothConnectionState.error);
//       });
//     } catch (e) {
//       dev.log('Error connecting to device: $e');
//       _bluetoothError = "Failed to connect to device";
//       _setBluetoothState(BluetoothConnectionState.error);
//     }
//   }

//   // Disconnect from device
//   Future<void> disconnectFromDevice() async {
//     if (!isBluetoothConnected) {
//       return;
//     }

//     try {
//       await _inputStreamSubscription?.cancel();
//       await _connection?.close();
//       dev.log('Disconnected from ${_targetDevice?.name}');
//       _setBluetoothState(BluetoothConnectionState.disconnected);
//     } catch (e) {
//       dev.log('Error disconnecting from device: $e');
//       _bluetoothError = "Failed to disconnect from device";
//       _setBluetoothState(BluetoothConnectionState.error);
//     }
//   }

//   // ================== RECEIVE & DATA PROCESSING ==================
//   void _onDataReceived(Uint8List data) {
//     dev.log('Data received: ${String.fromCharCodes(data)}');

//     String strData = String.fromCharCodes(data);
//     // Assuming the data format is known and can be parsed
//     // Example: Parse the data and update the appropriate signal model
//     switch (_currentMode) {
//       case 1:
//         dev.log('Updating ECG data: $strData');
//         break;
//       case 2:
//         dev.log('Updating BP data: $strData');
//         break;
//       case 3:
//         dev.log('Updating Body Temperature data: $strData');
//         break;
//       default:
//         dev.log('Invalid mode: $_currentMode');
//     }
//     notifyListeners();
//   }

//   void _onDemoDataReceived(dynamic data) {
//     switch (_currentMode) {
//       case 1:
//         _ecgSignal.addEcgCache(data['ecg']);
//         _ecgSignal.hrv = data['hrv'];
//         _ecgSignal.hbpm = data['hbpm'];
//         notifyListeners();
//         break;
//       case 2:
//         _bpSignal.bpData = data;
//         notifyListeners();
//         break;
//       case 3:
//         _btempSignal.tempData = data;
//         notifyListeners();
//         break;
//       default:
//         dev.log('Invalid mode: $_currentMode');
//     }
//     notifyListeners();
//   }

//   // ============= RECORDING STATES =============
//   // Send data to device aka signal to start recording
//   Future<void> startRecording(int mode) async {
//     if (!isBluetoothConnected) {
//       dev.log('Cannot send mode, device not connected');
//       return;
//     }
//     if (mode < 0 || mode > 3) {
//       // 0: idle, 1: ECG, 2: BP, 3: Body Temp
//       dev.log('Invalid mode selected');
//       return;
//     }

//     isRecording = true;
//     isPaused = false;
//     _stopwatch.start();
//     _currentMode = mode;
//     _startTime = DateTime.now();
//     notifyListeners();

//     // start[set deviceType] -> stream [virtual|real] -> process [virtual|real]
//     if (DEVICE_TYPE == DeviceType.virtual) {
//       Signal currentSignal = getCurrentSignal(mode);
//       currentSignal.starttime = _startTime;
//       _virtualDevice.selectSignalMode(mode);
//       _virtualDevice.listenToSignalStream(_onDemoDataReceived);
//     } else {
//       try {
//         _connection!.output.add(Uint8List.fromList([mode]));
//         await _connection!.output.allSent;
//         dev.log('Data sent: ${mode.toString()}');
//       } catch (e) {
//         dev.log('Error sending data: $e');
//         _bluetoothError = "Failed to send data";
//         _setBluetoothState(BluetoothConnectionState.error);
//       }
//     }
//   }

//   void pauseRecording() {
//     isPaused = true;
//     _stopwatch.stop();
//     if (DEVICE_TYPE == DeviceType.virtual) {
//       _virtualDevice.pauseListening();
//     }
//     notifyListeners();
//   }

//   void resumeRecording() {
//     isPaused = false;
//     _stopwatch.start();
//     if (DEVICE_TYPE == DeviceType.virtual) {
//       _virtualDevice.resumeListening();
//     }
//     notifyListeners();
//   }

//   void stopRecording() {
//     isRecording = false;
//     isPaused = false;
//     _stopwatch.reset();
//     if (DEVICE_TYPE == DeviceType.virtual) {
//       _virtualDevice.stopListening();
//     }
//     notifyListeners();
//   }

//   // ============== signal management ==============
//   // get signal
//   Signal getCurrentSignal(int tabIndex) {
//     switch (tabIndex) {
//       case 0:
//         return _ecgSignal;
//       case 1:
//         return _bpSignal;
//       case 2:
//         return _btempSignal;
//       default:
//         return _ecgSignal;
//     }
//   }
// }

// class BluetoothConnectState extends ChangeNotifier {
//   // Bluetooth states
//   BluetoothConnectionState _bluetoothState =
//       BluetoothConnectionState.disconnected;
//   String _bluetoothError = '';
//   BluetoothDevice? _targetDevice;
//   final String _targetDeviceName = 'CardioCare';
//   final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
//   BluetoothConnection? _connection;
//   StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
//   StreamSubscription<Uint8List>? _inputStreamSubscription;

//   // getters and setters
//   BluetoothConnectionState get bluetoothState => _bluetoothState;
//   String get bluetoothError => _bluetoothError;
//   bool get isBluetoothConnected =>
//       _bluetoothState == BluetoothConnectionState.connected;
//   String get targetDeviceName => _targetDeviceName;

//   void _setBluetoothState(BluetoothConnectionState status) {
//     _bluetoothState = status;
//     notifyListeners();
//   }

//   // start discovery
//   Future<void> startDiscovery() async {
//     _setBluetoothState(BluetoothConnectionState.discovering);

//     try {
//       bool isEnabled = await _bluetooth.requestEnable() ?? false;
//       if (!isEnabled) {
//         dev.log("Failed to enable Bluetooth");
//         _bluetoothError = "Failed to enable Bluetooth";
//       }

//       _discoveryStreamSubscription = _bluetooth.startDiscovery().listen(
//         (r) {
//           dev.log("Discovered device: ${r.device.name}");
//           if (r.device.name == _targetDeviceName) {
//             _targetDevice = r.device;
//             stopDiscovery();
//             connectToDevice(_targetDevice!);
//           }
//         },
//         onDone: () {
//           dev.log("Discovery finished");
//           if (_targetDevice == null) {
//             _bluetoothError = "Target device not found";
//             _setBluetoothState(BluetoothConnectionState.error);
//           }
//         },
//         onError: (error) {
//           dev.log("Error during discovery: $error");
//           _bluetoothError = "Error during device discovery";
//           _setBluetoothState(BluetoothConnectionState.error);
//         },
//       );
//     } catch (e) {
//       dev.log('Error during Bluetooth discovery: $e');
//       _bluetoothError = "An error occurred during Bluetooth operation";
//       _setBluetoothState(BluetoothConnectionState.error);
//     }
//   }

//   // stop discovery
//   Future<void> stopDiscovery() async {
//     await _discoveryStreamSubscription?.cancel();
//     _discoveryStreamSubscription = null;
//     _setBluetoothState(BluetoothConnectionState.disconnected);
//   }

//   // connect to device
//   Future<void> connectToDevice(BluetoothDevice device) async {
//     if (isBluetoothConnected) {
//       return;
//     }

//     _setBluetoothState(BluetoothConnectionState.connecting);
//     try {
//       dev.log('Connecting to ${device.name}');
//       _connection = await BluetoothConnection.toAddress(device.address);
//       dev.log('Connected to ${device.name}');

//       _setBluetoothState(BluetoothConnectionState.connected);

//       _inputStreamSubscription =
//           _connection?.input?.listen(_onDataReceived, onDone: () {
//         dev.log('Disconnected by remote device');

//         disconnectFromDevice();
//       }, onError: (error) {
//         dev.log('Error receiving data: $error');
//         _bluetoothError = "Error receiving data";
//         _setBluetoothState(BluetoothConnectionState.error);
//       });
//     } catch (e) {
//       dev.log('Error connecting to device: $e');
//       _bluetoothError = "Failed to connect to device";
//       _setBluetoothState(BluetoothConnectionState.error);
//     }
//   }

//   // handle incoming data
//   void _onDataReceived(Uint8List data) {
//     dev.log('Data received: ${String.fromCharCodes(data)}');
//     // Process data here
//   }

//   // disconnect from device
//   Future<void> disconnectFromDevice() async {
//     if (!isBluetoothConnected) {
//       return;
//     }
//     try {
//       await _inputStreamSubscription?.cancel();
//       await _connection?.close();
//       dev.log('Disconnected from ${_targetDevice?.name}');
//       _setBluetoothState(BluetoothConnectionState.disconnected);
//     } catch (e) {
//       dev.log('Error disconnecting from device: $e');
//       _bluetoothError = "Failed to disconnect from device";
//       _setBluetoothState(BluetoothConnectionState.error);
//     }
//   }

//   // send data to device
//   Future<void> sendData(Uint8List data) async {
//     if (!isBluetoothConnected || _connection == null) {
//       dev.log('Cannot send data, device not connected');
//       return;
//     }
//     try {
//       _connection!.output.add(data);
//       await _connection!.output.allSent;
//       dev.log('Data sent: ${data.toString()}');
//     } catch (e) {
//       dev.log('Error sending data: $e');
//       _bluetoothError = "Failed to send data";
//       _setBluetoothState(BluetoothConnectionState.error);
//     }
//   }

// // select mode
//   Future<void> selectMode(int mode) async {
//     if (!isBluetoothConnected) {
//       dev.log('Device not connected');
//       return;
//     }
//     if (mode < 0 || mode > 3) {
//       dev.log('Invalid mode selected');
//       return;
//     }
//     await sendData(Uint8List.fromList([mode]));
//   }
// }

// class MonitorState extends ChangeNotifier {
//   // recording states: recording, paused, resume, save, discard
//   bool isRecording = false;
//   bool isPaused = false;

//   // create data: generator-to-subscriber, signal data type
//   StreamSubscription<dynamic>? _subscription;
//   final SignalGenerator _signalGenerator = SignalGenerator();
//   final Stopwatch _stopwatch = Stopwatch();

//   // save data: save-to-db method, signal data type
//   final EcgModel _ecgSignal = EcgModel(userId: 1);
//   final BpModel _bpSignal = BpModel(userId: 1);
//   final BtempModel _btempSignal = BtempModel(userId: 1);

//   // getters and setters
//   EcgModel get ecgSignal => _ecgSignal;
//   BpModel get bpSignal => _bpSignal;
//   BtempModel get btempSignal => _btempSignal;

//   Stopwatch get stopwatch => _stopwatch;

//   dynamic getCurrentSignal(int tabIndex) {
//     switch (tabIndex) {
//       case 0:
//         return _ecgSignal;
//       case 1:
//         return _bpSignal;
//       case 2:
//         return _btempSignal;
//     }
//   }

//   // recording methods
//   void startRecording(int tabIndex) {
//     isRecording = true;
//     isPaused = false;
//     _stopwatch.start();
//     notifyListeners();

//     switch (tabIndex) {
//       case 0:
//         _ecgSignal.starttime = DateTime.now();
//         _subscription = _signalGenerator.generateECG().listen((value) {
//           _ecgSignal.addEcgCache(value['ecg']);
//           _ecgSignal.hrv = value['hrv'];
//           _ecgSignal.hbpm = value['hbpm'];
//           notifyListeners();
//         });
//         break;
//       case 1:
//         _bpSignal.starttime = DateTime.now();
//         _subscription = _signalGenerator.generateBP().listen((value) {
//           _bpSignal.bpData = value;
//           notifyListeners();
//         });
//         break;
//       case 2:
//         _btempSignal.starttime = DateTime.now();
//         _subscription = _signalGenerator.generateBtemp().listen((value) {
//           _btempSignal.tempData = value;
//           notifyListeners();
//         });
//         break;
//     }
//   }

//   void pauseRecording() {
//     isPaused = true;
//     _stopwatch.stop();
//     _subscription?.pause();
//     notifyListeners();
//   }

//   void resumeRecording() {
//     isPaused = false;
//     _stopwatch.start();
//     _subscription?.resume();
//     notifyListeners();
//   }

//   void stopRecording() {
//     isRecording = false;
//     isPaused = false;
//     _stopwatch.reset();
//     _subscription?.cancel();
//     _ecgSignal.clearEcg();
//     notifyListeners();
//   }
// }
