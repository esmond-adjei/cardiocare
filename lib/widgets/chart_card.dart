import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChartCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Function? menuOptions;
  final Widget? summary;

  const ChartCard({
    super.key,
    this.title,
    this.menuOptions,
    this.summary,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // TITLE AND MENU OPTIONS
          if (title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title!, style: Theme.of(context).textTheme.titleSmall),
                if (menuOptions != null)
                  IconButton(
                    onPressed: () => menuOptions!(),
                    icon: const Icon(Icons.more_horiz,
                        color: Colors.grey, size: 20),
                  )
              ],
            ),
            const SizedBox(height: 8),
          ],

          // SUMMARY WIDGET
          if (summary != null) ...[
            summary!,
            const SizedBox(height: 16),
          ],

          // CHART WIDGET
          child,
        ],
      ),
    );
  }
}

class ChartSummary extends StatelessWidget {
  final bool showLegend;
  final bool showMultipleColumns;

  final String summaryLabel;
  final String periodLabel;
  final int periodValue;

  final num primaryValue;
  final num? secondaryValue;
  final String priamryNameLabel;
  final String? secondaryNameLabel;
  final String primaryUnitLabel;
  final String? secondaryUnitLabel;

  final Color primaryColor;
  final Color? secondaryColor;

  const ChartSummary({
    super.key,
    this.showLegend = true,
    this.showMultipleColumns = false,
    required this.primaryValue,
    this.secondaryValue,
    this.primaryUnitLabel = '',
    this.secondaryUnitLabel,
    this.priamryNameLabel = 'Add Label',
    this.secondaryNameLabel,
    this.primaryColor = Colors.redAccent,
    this.secondaryColor,
    required this.periodValue,
    this.summaryLabel = 'Average per day',
    this.periodLabel = 'Days',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summaryLabel,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            Row(
              children: [
                _buildValueRow(context, primaryValue, primaryUnitLabel),
                if (showMultipleColumns && secondaryValue != null) ...[
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
                    secondaryValue!,
                    secondaryUnitLabel ?? primaryUnitLabel,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$periodValue $periodLabel',
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
                  _LegendItem(color: primaryColor, label: priamryNameLabel),
                  if (showMultipleColumns) ...[
                    const SizedBox(width: 16),
                    _LegendItem(
                      color: secondaryColor ?? primaryColor.withOpacity(0.4),
                      label: secondaryNameLabel ?? 'Add Label',
                    ),
                  ],
                ],
              ),
            ],
          ],
        )
      ],
    );
  }

  Widget _buildValueRow(BuildContext context, num value, String unit) {
    final numberFormat = NumberFormat('#,###.#');
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
          unit,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
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
