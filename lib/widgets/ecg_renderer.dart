import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ECGChart extends StatefulWidget {
  const ECGChart({super.key});

  @override
  State<ECGChart> createState() => _ECGChartState();
}

class _ECGChartState extends State<ECGChart> {
  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              showAvg ? avgData() : mainData(),
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'avg',
              style: TextStyle(
                fontSize: 12,
                color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData mainData() {
    return LineChartData(
        // Configure your line chart data here
        );
  }

  LineChartData avgData() {
    return LineChartData(
        // Configure your average line chart data here
        );
  }
}
