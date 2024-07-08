import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ActivityPieChart extends StatelessWidget {
  final Map<String, double> dataMap;

  const ActivityPieChart({super.key, required this.dataMap});

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> sections = dataMap.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.key}: ${entry.value}%',
        color: _getColorForActivity(entry.key),
        radius: 100,
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Color _getColorForActivity(String activity) {
    switch (activity) {
      case 'Resting':
        return Colors.blue;
      case 'Moderate':
        return Colors.green;
      case 'Intense':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Sample usage in a Scaffold
class PieChartExample extends StatelessWidget {
  const PieChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> activityData = {
      'Resting': 40,
      'Moderate': 35,
      'Intense': 25,
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Pie Chart Example")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text('Activity Distribution', style: TextStyle(fontSize: 18)),
            SizedBox(
                height: 200, child: ActivityPieChart(dataMap: activityData)),
          ],
        ),
      ),
    );
  }
}
