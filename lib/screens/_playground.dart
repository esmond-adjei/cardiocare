import 'dart:developer' as dev;
import 'package:cardiocare/services/models/db_helper.dart';
import 'package:cardiocare/services/models/signal_model.dart';
import 'package:cardiocare/widgets/pie_chart.dart';
import 'package:cardiocare/widgets/trend_line_chart.dart';
import 'package:flutter/material.dart';

class HealthDashboard extends StatelessWidget {
  const HealthDashboard({super.key});

  void _loadSignalsTable() async {
    DatabaseHelper dbhelper = DatabaseHelper();
    List<Map<String, dynamic>> signals = await dbhelper.getAllSignals();
    dev.log('\n>> ALL SIGNALS (length): ${signals.length}');
    for (var s in signals) {
      dev.log('>> DATA: $s');
    }
    List<EcgModel> ecg = await dbhelper.getEcgData(1);
    dev.log('\n>> ALL ECG (length): ${ecg.length}');
    for (var s in ecg) {
      dev.log('>> DATA: ${s.toMap()}');
    }
    List<BpModel> bp = await dbhelper.getBpData(1);
    dev.log('\n>> ALL BP (length): ${bp.length}');
    for (var s in bp) {
      dev.log('>> DATA: ${s.toMap()}');
    }
    List<BtempModel> btemp = await dbhelper.getBtempData(1);
    dev.log('\n>> ALL BTEMP (length): ${btemp.length}');
    for (var s in btemp) {
      dev.log('>> DATA: ${s.toMap()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<HeartRateData> heartRateData = [
      HeartRateData("Mon", 72),
      HeartRateData("Tue", 78),
      HeartRateData("Wed", 69),
      HeartRateData("Thu", 85),
      HeartRateData("Fri", 90),
      HeartRateData("Sat", 75),
      HeartRateData("Sun", 80),
    ];

    final Map<String, double> activityData = {
      'Resting': 40,
      'Moderate': 35,
      'Intense': 25,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Dashboard"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Heart Rate Over Time',
                style: TextStyle(fontSize: 18),
              ),

              // ElevatedButton(
              //   onPressed: _loadSignalsTable,
              //   child: const Text('load signals'),
              // ),

              SizedBox(
                height: 300,
                child: HeartRateChart(heartRateData: heartRateData),
              ),
              const SizedBox(height: 20),
              const Text(
                'Activity Distribution',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                height: 300,
                child: ActivityPieChart(dataMap: activityData),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
