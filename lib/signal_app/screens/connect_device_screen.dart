import 'dart:async';
// import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:cardiocare/signal_app/screens/monitoring_screen_state.dart';
import 'package:cardiocare/signal_app/screens/monitoring_screen.dart';
// import 'package:flutter_cube/flutter_cube.dart';

class ConnectDevice extends StatefulWidget {
  const ConnectDevice({super.key});

  @override
  State<ConnectDevice> createState() => _ConnectDeviceState();
}

class _ConnectDeviceState extends State<ConnectDevice> {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  final List<BluetoothDevice> _devicesList = [];
  bool _isDiscovering = false;
  Color colorTheme = Colors.blueAccent;
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  BluetoothConnection? _connection;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _discoveryStreamSubscription?.cancel();
    _connection?.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    // dev.log("Checking permissions...");
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (allGranted) {
      // dev.log("All permissions granted");
      _startDiscovery();
    } else {
      // dev.log("Some permissions were denied");
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
              'Please grant all required permissions to use this feature.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _startDiscovery() async {
    setState(() {
      _isDiscovering = true;
      _devicesList.clear();
      colorTheme = Colors.redAccent;
    });

    try {
      // dev.log("Requesting Bluetooth enable...");
      bool isEnabled = await _bluetooth.requestEnable() ?? false;
      if (!isEnabled) {
        // dev.log("Failed to enable Bluetooth");
        _showBluetoothErrorDialog("Failed to enable Bluetooth");
        return;
      }

      // dev.log("Getting bonded devices...");
      List<BluetoothDevice> bondedDevices = await _bluetooth.getBondedDevices();
      setState(() {
        _devicesList.addAll(bondedDevices);
      });

      // dev.log("Starting discovery...");
      _discoveryStreamSubscription = _bluetooth.startDiscovery().listen(
        (r) {
          setState(() {
            final existingIndex = _devicesList
                .indexWhere((element) => element.address == r.device.address);
            if (existingIndex >= 0) {
              _devicesList[existingIndex] = r.device;
            } else {
              _devicesList.add(r.device);
            }
          });
        },
        onDone: () {
          // dev.log("Discovery finished");
          setState(() {
            _isDiscovering = false;
            colorTheme = Colors.blueAccent;
          });
        },
        onError: (error) {
          // dev.log("Error during discovery: $error");
          setState(() {
            _isDiscovering = false;
            colorTheme = Colors.blueAccent;
          });
          _showBluetoothErrorDialog("Error during device discovery");
        },
      );
    } catch (e) {
      // dev.log('Error during Bluetooth discovery: $e');
      setState(() {
        _isDiscovering = false;
        colorTheme = Colors.blueAccent;
      });
      _showBluetoothErrorDialog("An error occurred during Bluetooth operation");
    }
  }

  void _showBluetoothErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      // dev.log('Connecting to ${device.name}');
      _connection = await BluetoothConnection.toAddress(device.address);
      // dev.log('Connected to ${device.name}');

      final monitorState = Provider.of<MonitorState>(context, listen: false);
      monitorState.setBluetoothConnected(true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SingleMonitorLayout(),
        ),
      );
    } catch (e) {
      // dev.log('Error connecting to device: $e');
      _showBluetoothErrorDialog("Failed to connect to device");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Connect Device'),
        backgroundColor: colorTheme,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorTheme,
              colorTheme.withBlue(10).withGreen(10).withRed(10)
            ],
          ),
        ),
        child: Column(
          children: [
            Device3DModel(height: MediaQuery.of(context).size.height * 0.4),
            const SizedBox(height: 16),
            Text(
              'Connect to CardioCare Device',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.white),
            ),
            Expanded(
              child: _devicesList.isEmpty
                  ? Center(
                      child: _isDiscovering
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'No devices found',
                              style: TextStyle(color: Colors.white),
                            ),
                    )
                  : ListView.builder(
                      itemCount: _devicesList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading:
                                const Icon(Icons.bluetooth, color: Colors.blue),
                            title: Text(
                                _devicesList[index].name ?? "Unknown device"),
                            subtitle: Text(_devicesList[index].address),
                            trailing: ElevatedButton(
                              child: const Text('Connect'),
                              onPressed: () =>
                                  _connectToDevice(_devicesList[index]),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(_isDiscovering ? 'Scanning...' : 'Scan for Devices'),
              onPressed: _isDiscovering ? null : _startDiscovery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// 3D WIDGET
class Device3DModel extends StatelessWidget {
  final double height;

  const Device3DModel({
    super.key,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Image.asset('assets/images/device.png'),
      // Cube(
      //   onSceneCreated: (Scene scene) {
      //     scene.world.add(
      //       Object(fileName: "assets/3D/headphone/headphone.obj"),
      //     );
      //     scene.camera.zoom = 10;
      //   },
      // ),
    );
  }
}
