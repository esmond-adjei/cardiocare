import 'package:flutter/material.dart';
import 'package:xmonapp/services/db_schema.dart';
import 'package:xmonapp/services/db_crud.dart';
import 'package:xmonapp/screens/screen_with_header.dart';

class VitalSignalsScreen extends StatefulWidget {
  final int userId;

  const VitalSignalsScreen({super.key, required this.userId});

  @override
  State<VitalSignalsScreen> createState() => _VitalSignalsScreenState();
}

class _VitalSignalsScreenState extends State<VitalSignalsScreen> {
  late Future<List<EcgData>> _ecgDataFuture;
  late Future<List<BpData>> _bpDataFuture;
  late Future<List<TemperatureData>> _temperatureDataFuture;

  @override
  void initState() {
    super.initState();
    _ecgDataFuture = getEcgData(widget.userId);
    _bpDataFuture = getBpData(widget.userId);
    _temperatureDataFuture = getTemperatureData(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<EcgData>>(
              future: _ecgDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading ECG data'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No ECG data available'));
                }

                List<EcgData> ecgData = snapshot.data!;
                return Column(
                  children: ecgData
                      .map((data) => ListTile(
                            title: const Text('ECG Data'),
                            subtitle: Text('Timestamp: ${data.timestamp}'),
                          ))
                      .toList(),
                );
              },
            ),
            FutureBuilder<List<BpData>>(
              future: _bpDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading BP data'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No BP data available'));
                }

                List<BpData> bpData = snapshot.data!;
                return Column(
                  children: bpData
                      .map((data) => ListTile(
                            title: Text(
                                'BP: ${data.bpSystolic}/${data.bpDiastolic} mmHg'),
                            subtitle: Text('Timestamp: ${data.timestamp}'),
                          ))
                      .toList(),
                );
              },
            ),
            FutureBuilder<List<TemperatureData>>(
              future: _temperatureDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error loading temperature data'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No temperature data available'));
                }

                List<TemperatureData> temperatureData = snapshot.data!;
                return Column(
                  children: temperatureData
                      .map((data) => ListTile(
                            title: Text('Temperature: ${data.bodyTemp}°C'),
                            subtitle: Text('Timestamp: ${data.timestamp}'),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
