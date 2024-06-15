import 'package:flutter/material.dart';
import 'package:xmonapp/services/models/db_model.dart';

class VitalSignalsScreen extends StatefulWidget {
  final int userId;

  const VitalSignalsScreen({super.key, required this.userId});

  @override
  State<VitalSignalsScreen> createState() => _VitalSignalsScreenState();
}

class _VitalSignalsScreenState extends State<VitalSignalsScreen> {
  late Future<List<EcgModel>> _ecgDataFuture;
  late Future<List<BpModel>> _bpDataFuture;
  late Future<List<BtempModel>> _btempFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {});
  }

  void _insertDummyData() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<EcgModel>>(
              future: _ecgDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading ECG data'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No ECG data available'));
                }

                List<EcgModel> ecgData = snapshot.data!;
                return Column(
                  children: ecgData
                      .map((data) => ListTile(
                            title: const Text('ECG Data'),
                            subtitle: Text('Timestamp: ${data.startTime}'),
                          ))
                      .toList(),
                );
              },
            ),
            FutureBuilder<List<BpModel>>(
              future: _bpDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading BP data'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No BP data available'));
                }

                List<BpModel> bpData = snapshot.data!;
                return Column(
                  children: bpData
                      .map((data) => ListTile(
                            title: Text(
                                'BP: ${data.bpSystolic}/${data.bpDiastolic} mmHg'),
                            subtitle: Text('Timestamp: ${data.startTime}'),
                          ))
                      .toList(),
                );
              },
            ),
            FutureBuilder<List<BtempModel>>(
              future: _btempFuture,
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

                List<BtempModel> btemp = snapshot.data!;
                return Column(
                  children: btemp
                      .map((data) => ListTile(
                            title: Text('Temperature: ${data.bodyTemp}°C'),
                            subtitle: Text('Timestamp: ${data.startTime}'),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _insertDummyData,
        backgroundColor: Colors.redAccent,
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
    );
  }
}
