import 'dart:async';
import 'dart:developer' as dev;
import 'package:cardiocare/signal_app/model/signal_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:cardiocare/signal_app/screens/monitoring_screen_state.dart';
import 'package:cardiocare/signal_app/screens/monitoring_screen.dart';

class ConnectDevice extends StatefulWidget {
  const ConnectDevice({super.key});

  @override
  State<ConnectDevice> createState() => _ConnectDeviceState();
}

class _ConnectDeviceState extends State<ConnectDevice> {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    dev.log("Checking permissions...");
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    if (!allGranted) {
      dev.log("Some permissions were denied");
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

  void _showPairedDevices() async {
    final blueState = Provider.of<SignalMonitorState>(context, listen: false);
    final bondedDevices = await _bluetooth.getBondedDevices();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Paired Devices'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: bondedDevices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    bondedDevices[index].name ?? "Unknown device",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  subtitle: Text(
                    bondedDevices[index].address,
                    style: TextStyle(
                      color: Colors.grey.withOpacity(0.8),
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    blueState.connectToDevice(bondedDevices[index]);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _gotoMonitoringScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SingleMonitorLayout(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignalMonitorState>(
      builder: (context, blueState, child) {
        Color colorTheme = _getColorTheme(blueState.bluetoothState);

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
            actions: [
              IconButton(
                icon: const Icon(Icons.devices),
                onPressed: _showPairedDevices,
              ),
            ],
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Device3DModel(height: MediaQuery.of(context).size.height * 0.4),
                const SizedBox(height: 16),
                Text(
                  '${blueState.targetDeviceName} Device ${_getStatusText(blueState.bluetoothState)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 16),
                if (blueState.bluetoothState == BluetoothConnectionState.error)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      blueState.bluetoothError,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: Icon(
                    blueState.isBluetoothConnected
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth,
                  ),
                  label: Text(_getButtonText(blueState.bluetoothState)),
                  onPressed: _getButtonAction(blueState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                if (blueState.isBluetoothConnected)
                  TextButton(
                    onPressed: blueState.disconnectFromDevice,
                    child: const Text('Disconnect Device'),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  VoidCallback? _getButtonAction(SignalMonitorState blueState) {
    switch (blueState.bluetoothState) {
      case BluetoothConnectionState.disconnected:
      case BluetoothConnectionState.error:
        return blueState.startDiscovery;
      case BluetoothConnectionState.connected:
        return _gotoMonitoringScreen;
      case BluetoothConnectionState.discovering:
        return blueState.stopDiscovery;
      case BluetoothConnectionState.connecting:
      default:
        return null;
    }
  }

  Color _getColorTheme(BluetoothConnectionState state) {
    switch (state) {
      case BluetoothConnectionState.disconnected:
        return Colors.redAccent;
      case BluetoothConnectionState.discovering:
        return Colors.orangeAccent;
      case BluetoothConnectionState.connecting:
        return Colors.blueAccent;
      case BluetoothConnectionState.connected:
        return Colors.greenAccent;
      case BluetoothConnectionState.error:
        return Colors.redAccent;
      default:
        return Colors.blueAccent;
    }
  }

  String _getButtonText(BluetoothConnectionState state) {
    switch (state) {
      case BluetoothConnectionState.disconnected:
        return 'Connect';
      case BluetoothConnectionState.discovering:
        return 'Searching...';
      case BluetoothConnectionState.connecting:
        return 'Connecting...';
      case BluetoothConnectionState.connected:
        return 'Start Monitoring';
      case BluetoothConnectionState.error:
      default:
        return 'Retry';
    }
  }

  String _getStatusText(BluetoothConnectionState state) {
    switch (state) {
      case BluetoothConnectionState.disconnected:
        return 'is disconnected';
      case BluetoothConnectionState.discovering:
        return 'is trying to connect';
      case BluetoothConnectionState.connecting:
        return 'is connecting...';
      case BluetoothConnectionState.connected:
        return 'is connected';
      case BluetoothConnectionState.error:
      default:
        return 'failed to connect';
    }
  }
}

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
    );
  }
}
