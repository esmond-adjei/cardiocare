import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:cardiocare/signal_app/screens/monitoring_screen_state.dart';

class Playground extends StatefulWidget {
  const Playground({super.key});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  final List<BluetoothDevice> _devicesList = [];
  bool _isDiscovering = false;

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
      Permission.location,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (allGranted) {
      dev.log("All permissions granted");
      _startDiscovery();
    } else {
      dev.log("Some permissions were denied:");
      statuses.forEach((permission, status) {
        if (!status.isGranted) {
          dev.log("${permission.toString()}: ${status.toString()}");
        }
      });
    }
  }

  void _startDiscovery() async {
    setState(() {
      _isDiscovering = true;
      _devicesList.clear();
    });

    try {
      dev.log("Requesting Bluetooth enable...");
      bool isEnabled = await _bluetooth.requestEnable() ?? false;
      if (!isEnabled) {
        dev.log("Failed to enable Bluetooth");
        return;
      }

      dev.log("Getting bonded devices...");
      List<BluetoothDevice> bondedDevices = await _bluetooth.getBondedDevices();
      dev.log("Found ${bondedDevices.length} bonded devices");
      setState(() {
        _devicesList.addAll(bondedDevices);
      });

      dev.log("Starting discovery...");
      _bluetooth.startDiscovery().listen(
        (r) {
          dev.log(
              "Discovered device: ${r.device.name ?? 'Unknown'} (${r.device.address})");
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
          dev.log("Discovery finished");
          dev.log(
              "Discovery finished\nFound ${bondedDevices.length} bonded devices");
          setState(() {
            _isDiscovering = false;
          });
        },
        onError: (error) {
          dev.log("Error during discovery: $error");
          setState(() {
            _isDiscovering = false;
          });
        },
      );
    } catch (e) {
      dev.log('Error during Bluetooth discovery: $e');
      setState(() {
        _isDiscovering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final monitorState = Provider.of<MonitorState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _devicesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_devicesList[index].name ?? "Unknown device"),
                  subtitle: Text(_devicesList[index].address),
                  trailing: ElevatedButton(
                    child: const Text('Connect'),
                    onPressed: () {
                      dev.log('Connecting to ${_devicesList[index].name}');
                      // connect to bluetooth device
                      bool connected = true;
                      if (connected) {
                        monitorState.setBluetoothConnected(true);
                        Navigator.pop(context);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _isDiscovering ? null : _startDiscovery,
              child:
                  Text(_isDiscovering ? 'Discovering...' : 'Start Discovery'),
            ),
          ),
        ],
      ),
    );
  }
}
