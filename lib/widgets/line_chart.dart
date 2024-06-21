import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ScrollableLineChart extends StatefulWidget {
  final List<int> ecgValues;
  final Color lineColor;
  final double stretchFactor;
  final double maxY;

  static const sampleData = [1, 2, 3, 4, 5, 5, 6, 5, 7, 8, 7, 6, 5, 4, 3, 3, 3];

  const ScrollableLineChart({
    super.key,
    this.ecgValues = sampleData,
    this.lineColor = Colors.blueAccent,
    this.stretchFactor = 1.0,
    this.maxY = 300.0,
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
    if (widget.ecgValues.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
  }

  List<FlSpot> ecgData() {
    return widget.ecgValues.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble() * 0.01, entry.value.toDouble());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
      color: Colors.grey.withOpacity(0.2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: widget.ecgValues.length * widget.stretchFactor >
                  MediaQuery.of(context).size.width
              ? widget.ecgValues.length * widget.stretchFactor
              : MediaQuery.of(context).size.width,
          height: 300,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return LineChart(mainData());
            },
          ),
        ),
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: ecgData(),
          color: widget.lineColor,
          show: true,
          isCurved: true,
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
      titlesData: const FlTitlesData(
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
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
    );
  }
}
