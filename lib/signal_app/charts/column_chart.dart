import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ColumnChart extends StatelessWidget {
  final List<ColumnChartData> data;
  final bool showMultipleColumns;
  final Color primaryColor;
  final Color secondaryColor;

  const ColumnChart({
    super.key,
    required this.data,
    this.showMultipleColumns = true,
    this.primaryColor = Colors.blueAccent,
    this.secondaryColor = Colors.redAccent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: data
              .map((e) => e.primaryValue.toDouble())
              .reduce((a, b) => a > b ? a : b),
          titlesData: _getTitlesData(),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: _getBarGroups(context),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBorder: BorderSide(color: Colors.grey.shade200),
              getTooltipColor: (touchedSpot) => Colors.white,
              tooltipRoundedRadius: 8,
            ),
          ),
        ),
      ),
    );
  }

  FlTitlesData _getTitlesData() {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => Text(
            data[value.toInt()].label.substring(0, 3),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<BarChartGroupData> _getBarGroups(BuildContext context) {
    final dataLength = data.length;
    final barWidth = MediaQuery.of(context).size.width /
        (dataLength * 4) *
        (showMultipleColumns ? 1 : 2);
    return data.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.primaryValue.toDouble(),
            color: primaryColor,
            width: barWidth,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          if (showMultipleColumns)
            BarChartRodData(
              toY: entry.value.secondaryValue.toDouble(),
              color: secondaryColor,
              width: barWidth,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
        ],
      );
    }).toList();
  }
}

class ColumnChartData {
  final String label;
  final int primaryValue;
  final int secondaryValue;

  ColumnChartData({
    required this.label,
    required this.primaryValue,
    required this.secondaryValue,
  });
}
