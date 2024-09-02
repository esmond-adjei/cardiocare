import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TrendLineChart extends StatelessWidget {
  final List<TrendLine> lines;
  final double height;
  final bool? showLeftTitles;

  const TrendLineChart({
    super.key,
    required this.lines,
    this.height = 200,
    this.showLeftTitles,
  });

  @override
  Widget build(BuildContext context) {
    final allData = lines.expand((line) => line.data).toList();
    final maxY = allData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final minY = allData.map((e) => e.y).reduce((a, b) => a < b ? a : b);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          lineBarsData: _getLineBarsData(),
          minY: minY * 0.98,
          maxY: maxY * 1.02,
          titlesData: _getTitlesData(showLeftTitles: showLeftTitles ?? true),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.5),
              strokeWidth: 2.0,
              dashArray: [8, 4],
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBorder: BorderSide(color: Colors.grey.shade200),
              getTooltipColor: (touchedSpot) => Colors.white,
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  return LineTooltipItem(
                    flSpot.y.toStringAsFixed(2),
                    TextStyle(
                      color: barSpot.bar.color,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  List<LineChartBarData> _getLineBarsData() {
    return lines.map((line) {
      return LineChartBarData(
        spots: line.data
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.y))
            .toList(),
        isCurved: line.beautify,
        color: line.color,
        isStrokeCapRound: true,
        dotData: FlDotData(show: !line.beautify),
        belowBarData: BarAreaData(
          show: line.beautify,
          gradient: LinearGradient(
            colors: [
              line.color.withOpacity(0.6),
              line.color.withOpacity(0.01),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }).toList();
  }

  FlTitlesData _getTitlesData({bool showLeftTitles = true}) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showLeftTitles,
          reservedSize: 30,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            axisSide: meta.axisSide,
            child: Text(
              value.toInt().toString(),
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
        ),
      ),
      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}

class TrendLine {
  final List<TrendLinePoint> data;
  final Color color;
  final String? name;
  final bool beautify;

  TrendLine({
    required this.data,
    required this.color,
    this.name,
    this.beautify = false,
  });
}

class TrendLinePoint {
  final dynamic x;
  final double y;

  TrendLinePoint(this.x, this.y);
}
