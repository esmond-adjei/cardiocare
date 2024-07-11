import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HeartRateChart extends StatelessWidget {
  final List<HeartRateData> heartRateData;

  const HeartRateChart({super.key, required this.heartRateData});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      curve: Curves.decelerate,
      duration: const Duration(seconds: 5),
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
          show: false,
          border: Border.all(color: const Color(0xff37434d)),
        ),
        minX: 0,
        maxX: heartRateData.length.toDouble() - 1,
        minY: 60,
        maxY: 100,
        backgroundColor: Colors.blue.withOpacity(0.1),
        lineBarsData: [
          LineChartBarData(
            spots: heartRateData
                .asMap()
                .entries
                .map((entry) => FlSpot(
                    entry.key.toDouble(), entry.value.heartRate.toDouble()))
                .toList(),
            isCurved: true,
            // color: Colors.redAccent,
            barWidth: 3,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.purpleAccent, Colors.blueAccent],
            ),
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
