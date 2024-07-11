import 'dart:developer' as dev;
import 'package:cardiocare/services/models/db_helper.dart';
import 'package:cardiocare/services/models/signal_model.dart';
import 'package:cardiocare/widgets/charts/column_chart.dart';
import 'package:cardiocare/widgets/chart_card.dart';
import 'package:cardiocare/widgets/charts/pie_chart.dart';
import 'package:cardiocare/widgets/charts/trend_line_chart.dart';
import 'package:flutter/material.dart';

class HealthDashboard extends StatelessWidget {
  const HealthDashboard({super.key});

  void _loadSignalsTable() async {
    print(">> TIME: ${DateTime.now()}");
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
    final List<TrendLinePoint> heartRateData = [
      TrendLinePoint("Mon", 72),
      TrendLinePoint("Tue", 78),
      TrendLinePoint("Wed", 69),
      TrendLinePoint("Thu", 85),
      TrendLinePoint("Fri", 90),
      TrendLinePoint("Sat", 75),
      TrendLinePoint("Sun", 80),
    ];

    final Map<String, double> activityData = {
      'Resting': 40,
      'Moderate': 35,
      'Intense': 25,
    };

    final temperatureData = [
      ColumnChartData(label: 'Sun', primaryValue: 81, secondaryValue: 75),
      ColumnChartData(label: 'Mon', primaryValue: 77, secondaryValue: 70),
      ColumnChartData(label: 'Tue', primaryValue: 76, secondaryValue: 73),
      ColumnChartData(label: 'Wed', primaryValue: 81, secondaryValue: 76),
      ColumnChartData(label: 'Thu', primaryValue: 78, secondaryValue: 76),
      ColumnChartData(label: 'Fri', primaryValue: 72, secondaryValue: 70),
      ColumnChartData(label: 'Sat', primaryValue: 82, secondaryValue: 68),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("playground screen"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LOAD SIGNALS BUTTON
              ElevatedButton(
                onPressed: _loadSignalsTable,
                child: const Text('load signals'),
              ),
              const SizedBox(height: 20),
              // BAR CHART
              ChartCard(
                title: 'Max vs Min Temperatures ',
                summary: ChartSummary(
                  primaryValue: 82,
                  secondaryValue: 68,
                  primaryUnitLabel: '°F',
                  priamryNameLabel: 'Max',
                  secondaryNameLabel: 'Min',
                  periodValue: temperatureData.length,
                ),
                child: ColumnChart(
                  data: temperatureData,
                  showMultipleColumns: true,
                ),
              ),
              const SizedBox(height: 20),
              // TREND LINE CHART
              const Text(
                'Heart Rate Over Time',
                style: TextStyle(fontSize: 18),
              ),
              TrendLineChart(
                lines: [
                  TrendLine(data: heartRateData, color: Colors.red),
                ],
              ),
              const SizedBox(height: 20),
              // PIE CHART
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
