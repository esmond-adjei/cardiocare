import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ScrollableLineChart extends StatefulWidget {
  final List<int> dataList;
  final Color lineColor;
  final double height;
  final double? width;
  final double stretchFactor;
  final double maxY;
  final bool rounded;

  const ScrollableLineChart({
    super.key,
    required this.dataList,
    this.lineColor = Colors.blueAccent,
    this.height = 260,
    this.width,
    this.stretchFactor = 1.0,
    this.maxY = 300.0,
    this.rounded = false,
  });

  @override
  State<ScrollableLineChart> createState() => _ScrollableLineChartState();
}

class _ScrollableLineChartState extends State<ScrollableLineChart> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  void didUpdateWidget(covariant ScrollableLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // scroll to the end
    if (widget.dataList.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
  }

  List<FlSpot> _ecgDataSpots() {
    const samplingRate = 500;
    return widget.dataList.asMap().entries.map((entry) {
      return FlSpot(
          entry.key.toDouble() * 12 / samplingRate, entry.value.toDouble());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: widget.lineColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(widget.rounded ? 12 : 0),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: widget.width ?? widget.dataList.length * widget.stretchFactor,
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return LineChart(_buildChart());
            },
          ),
        ),
      ),
    );
  }

  LineChartData _buildChart() {
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: _ecgDataSpots(),
          color: widget.lineColor,
          isCurved: true,
          curveSmoothness: 0.3,
          preventCurveOverShooting: true,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                widget.lineColor.withOpacity(0.6),
                widget.lineColor.withOpacity(0.01),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          dotData: const FlDotData(show: false),
        ),
      ],
      maxY: widget.maxY,
      minY: widget.maxY * -0.1,
      titlesData: FlTitlesData(
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1.0,
            getTitlesWidget: (value, meta) => SideTitleWidget(
              axisSide: meta.axisSide,
              child: Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: false,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 2.0,
            dashArray: [8, 4],
          );
        },
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
    );
  }
}
