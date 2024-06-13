import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ECGChart extends StatefulWidget {
  final Uint8List ecgData;

  const ECGChart({
    super.key,
    required this.ecgData,
  });

  @override
  State<ECGChart> createState() => _ECGChartState();
}

class _ECGChartState extends State<ECGChart> {
  final List<FlSpot> _ecgSpots = [];

  @override
  void initState() {
    super.initState();
    _processData();
  }

  void _processData() {
    // Normalize data to a suitable range for the chart (e.g., -1 to 1)
    final double maxVal = widget.ecgData.reduce(max) * 1.0;
    final double minVal = widget.ecgData.reduce(min) * 1.0;
    final double normalizationFactor = maxVal - minVal;

    for (int i = 0; i < widget.ecgData.length; i++) {
      final double normalizedValue =
          (widget.ecgData[i] - minVal) / normalizationFactor * 2 - 1;
      _ecgSpots.add(FlSpot(i.toDouble(), normalizedValue));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        backgroundColor: Colors.grey[200],
        borderData: FlBorderData(border: Border.all(width: 0)),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: 1,
          checkToShowHorizontalLine: (value) => true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey[400],
            strokeWidth: 0.5,
          ),
        ),
        titlesData: const FlTitlesData(
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
              axisNameWidget: Text('Time (s)')),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
            axisNameWidget: Text('Voltage (mV)'),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _ecgSpots,
            isCurved: true,
            color: Colors.red,
            barWidth: 2,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
