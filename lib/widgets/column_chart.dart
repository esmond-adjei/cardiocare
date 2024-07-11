import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ColumnChart extends StatelessWidget {
  final List<ColumnChartData> data;
  final bool showLegend;
  final bool showMultipleColumns;

  final String primaryUnit;
  final String? secondaryUnit;
  final Color primaryColor;
  final Color secondaryColor;
  final String primaryLabel;
  final String secondaryLabel;

  const ColumnChart({
    super.key,
    required this.data,
    required this.primaryUnit,
    this.secondaryUnit,
    this.showLegend = true,
    this.showMultipleColumns = true,
    this.primaryColor = Colors.purple,
    this.secondaryColor = Colors.pink,
    this.primaryLabel = 'Max',
    this.secondaryLabel = 'Min',
  });

  @override
  Widget build(BuildContext context) {
    final dataLength = data.length;
    final primaryMean =
        data.map((e) => e.primaryValue).reduce((a, b) => a + b) ~/ dataLength;
    final secondaryMean = showMultipleColumns
        ? data.map((e) => e.secondaryValue).reduce((a, b) => a + b) ~/
            dataLength
        : 0;

    return Column(
      children: [
        // summary and legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average $primaryUnit per day',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                Row(
                  children: [
                    _buildValueRow(
                      context,
                      primaryMean,
                      primaryUnit,
                    ),
                    if (showMultipleColumns) ...[
                      Text(
                        ' | ',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.fontSize),
                      ),
                      _buildValueRow(
                        context,
                        secondaryMean,
                        secondaryUnit ?? primaryUnit,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$dataLength Days',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: primaryColor),
                  ),
                ),
                if (showLegend) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _LegendItem(color: primaryColor, label: primaryLabel),
                      const SizedBox(width: 16),
                      if (showMultipleColumns)
                        _LegendItem(
                            color: secondaryColor, label: secondaryLabel),
                    ],
                  ),
                ],
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        // chart
        SizedBox(
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueRow(BuildContext context, int value, String unit) {
    final numberFormat = NumberFormat('#,###');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          numberFormat.format(value),
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          primaryUnit,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.grey),
        ),
      ],
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

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
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
