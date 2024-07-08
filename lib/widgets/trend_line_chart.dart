import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HeartRateChart extends StatelessWidget {
  final List<HeartRateData> heartRateData;

  const HeartRateChart({super.key, required this.heartRateData});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(heartRateData[value.toInt()].day, style: style),
                );
              },
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ));
              },
              reservedSize: 28,
              interval: 10,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d)),
        ),
        minX: 0,
        maxX: heartRateData.length.toDouble() - 1,
        minY: 0,
        maxY: 150,
        lineBarsData: [
          LineChartBarData(
            spots: heartRateData
                .asMap()
                .entries
                .map((entry) => FlSpot(
                    entry.key.toDouble(), entry.value.heartRate.toDouble()))
                .toList(),
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

class HeartRateData {
  final String day;
  final int heartRate;

  HeartRateData(this.day, this.heartRate);
}

// === example ===
class HeartRateTrend extends StatelessWidget {
  const HeartRateTrend({super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Heart Rate Over Time"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: HeartRateChart(heartRateData: heartRateData),
      ),
    );
  }
}
