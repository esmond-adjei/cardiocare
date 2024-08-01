import 'dart:developer' as dev;
import 'package:cardiocare/services/db_helper.dart';
import 'package:cardiocare/services/preferences.dart';
import 'package:cardiocare/signal_app/charts/chart_card.dart';
import 'package:cardiocare/signal_app/charts/column_chart.dart';
import 'package:cardiocare/signal_app/charts/trend_line_chart.dart';
import 'package:cardiocare/signal_app/model/signal_model.dart';
import 'package:cardiocare/utils/format_datetime.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cardiocare/services/analysis_provider.dart';
import 'package:cardiocare/signal_app/model/signal_enums.dart';
import 'package:cardiocare/signal_app/widgets/list_container.dart';

class HistoryTabView extends StatefulWidget {
  final SignalType dataType;

  const HistoryTabView({super.key, required this.dataType});

  @override
  State<HistoryTabView> createState() => _HistoryTabViewState();
}

class _HistoryTabViewState extends State<HistoryTabView> {
  late Future<List<Signal>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
    _updatePreferences(); // Update preferences here
  }

  Future<List<Signal>> _fetchData() async {
    final dbhelper = Provider.of<DatabaseHelper>(context, listen: false);
    try {
      switch (widget.dataType) {
        case SignalType.ecg:
          return await dbhelper.getEcgData(1);
        case SignalType.bp:
          return await dbhelper.getBpData(1);
        case SignalType.btemp:
          return await dbhelper.getBtempData(1);
      }
    } catch (e) {
      dev.log(">> error: $e");
    }
    return [];
  }

  Future<void> _refreshData() async {
    setState(() => _dataFuture = _fetchData());
  }

  Future<void> _updatePreferences() async {
    final prefsManager =
        Provider.of<SharedPreferencesManager>(context, listen: false);
    final data = await _dataFuture;

    if (data.isEmpty) return;

    final provider = AnalysisProvider(data, prefsManager);

    // Update preferences based on the SignalType
    switch (widget.dataType) {
      case SignalType.ecg:
        provider.updateHeartRateMetric();
        break;
      case SignalType.bp:
        provider.updateBloodPressureMetric();
        break;
      case SignalType.btemp:
        provider.updateTemperatureMetric();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      // color: ,
      child: FutureBuilder<List<Signal>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error: something went wrong'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildChartSummary(context, snapshot.data!),
                  ListContainer(
                    listHeading: '${widget.dataType.description} History',
                    listData: snapshot.data!,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildChartSummary(BuildContext context, List<Signal> data) {
    final prefsManager =
        Provider.of<SharedPreferencesManager>(context, listen: false);
    final provider = AnalysisProvider(data, prefsManager);

    switch (widget.dataType) {
      case SignalType.ecg:
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: ChartCard(
            title: 'Heart Rate Summary',
            summary: ChartSummary(
              showLegend: true,
              showMultipleColumns: false,
              summaryLabel: 'Avg. Heart Rate (bpm)',
              periodValue: provider.dataLength,
              periodLabel: 'records',
              primaryUnitLabel: 'bpm',
              primaryValue: provider.getAverageHeartRate(),
              primaryColor: SignalType.ecg.color,
            ),
            legend:
                LegendItem(color: SignalType.ecg.color, label: 'heart rate'),
            child: TrendLineChart(
              height: 160,
              lines: [
                TrendLine(
                  data: _parseHBPMTrendLineData(provider.data),
                  color: SignalType.ecg.color,
                ),
              ],
            ),
          ),
        );

      case SignalType.bp:
        final avgBp = provider.getAverageBP();
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: ChartCard(
            title: 'Blood Pressure Summary',
            menuOptions: () {},
            summary: ChartSummary(
              showLegend: true,
              showMultipleColumns: true,
              summaryLabel: 'Average Blood Pressure (mmHg/day)',
              periodValue: provider.dataLength,
              periodLabel: 'days',
              primaryUnitLabel: 'mmHg',
              primaryValue: avgBp[0],
              primaryColor: SignalType.bp.color,
              secondaryValue: avgBp[1],
              secondaryColor: SignalType.bp.color.withOpacity(0.4),
            ),
            legend: Row(
              children: [
                LegendItem(color: SignalType.bp.color, label: 'systolic'),
                const SizedBox(width: 8),
                LegendItem(
                  color: SignalType.bp.color.withOpacity(0.4),
                  label: 'diastolic',
                ),
              ],
            ),
            child: ColumnChart(
              data: _parseColumnChartData(provider.data),
              primaryColor: SignalType.bp.color,
              secondaryColor: SignalType.bp.color.withOpacity(0.4),
            ),
          ),
        );

      case SignalType.btemp:
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: ChartCard(
            title: 'Body Temperature',
            summary: ChartSummary(
              showLegend: true,
              showMultipleColumns: false,
              summaryLabel: 'Max Avg. Body Temperature (°C)',
              periodValue: provider.dataLength,
              periodLabel: 'records',
              primaryUnitLabel: '°C',
              primaryValue: provider.getMaxTemperature(),
              primaryColor: SignalType.btemp.color,
            ),
            legend: Row(
              children: [
                LegendItem(
                  color: SignalType.btemp.color,
                  label: 'avg. body temp.',
                ),
                const SizedBox(width: 8),
                const LegendItem(
                  color: Colors.blueAccent,
                  label: 'min body temp.',
                ),
                const SizedBox(width: 8),
                const LegendItem(
                  color: Colors.redAccent,
                  label: 'max body temp.',
                ),
              ],
            ),
            child: TrendLineChart(
              height: 160,
              lines: [
                TrendLine(
                  data: _parseTrendLineData(provider.data),
                  color: SignalType.btemp.color,
                  beautify: true,
                ),
                TrendLine(
                  data: _parseMinTrendLineData(provider.data),
                  color: Colors.blueAccent,
                  // beautify: true,
                ),
                TrendLine(
                  data: _parseMaxTrendLineData(provider.data),
                  color: Colors.redAccent,
                  // beautify: true,
                ),
              ],
            ),
          ),
        );
      default:
        return const Padding(
          padding: EdgeInsets.all(12.0),
          child: ChartCard(
            child: Placeholder(),
          ),
        );
    }
  }

  List<ColumnChartData> _parseColumnChartData(List<dynamic> data) {
    return data
        .map(
          (e) => ColumnChartData(
            label: formatWeekday(e.startTime.toString()).substring(0, 3),
            primaryValue: e.systolic,
            secondaryValue: e.diastolic,
          ),
        )
        .toList();
  }

  List<TrendLinePoint> _parseTrendLineData(List<dynamic> data) {
    return data
        .map(
          (e) => TrendLinePoint(
            formatWeekday(e.startTime.toString()).substring(0, 3),
            e.avgTemp,
          ),
        )
        .toList();
  }

  List<TrendLinePoint> _parseMinTrendLineData(List<dynamic> data) {
    return data
        .map(
          (e) => TrendLinePoint(
            formatWeekday(e.startTime.toString()).substring(0, 3),
            e.minTemp,
          ),
        )
        .toList();
  }

  List<TrendLinePoint> _parseMaxTrendLineData(List<dynamic> data) {
    return data
        .map(
          (e) => TrendLinePoint(
            formatWeekday(e.startTime.toString()).substring(0, 3),
            e.maxTemp,
          ),
        )
        .toList();
  }

  List<TrendLinePoint> _parseHBPMTrendLineData(List<dynamic> data) {
    return data
        .map(
          (e) => TrendLinePoint(
            formatWeekday(e.startTime.toString()).substring(0, 3),
            e.hbpm.toDouble(),
          ),
        )
        .toList();
  }
}
