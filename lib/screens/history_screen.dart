import 'dart:async';
import 'dart:developer' as dev;
import 'package:cardiocare/utils/enums.dart';
import 'package:cardiocare/utils/format_datetime.dart';
import 'package:cardiocare/widgets/charts/column_chart.dart';
import 'package:cardiocare/widgets/chart_card.dart';
import 'package:cardiocare/widgets/charts/trend_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cardiocare/screens/drawers/monitoring_screen.dart';
import 'package:cardiocare/services/models/db_helper.dart';
import 'package:cardiocare/services/models/signal_model.dart';
import 'package:cardiocare/widgets/list_container.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  List<Color> tabColors = [
    SignalType.ecg.color,
    SignalType.bp.color,
    SignalType.btemp.color
  ];
  late TabController _tabController;
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, initialIndex: 0, vsync: this);
    _tabController.addListener(_handleTabChange);
    _currentColor = SignalType.ecg.color;
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() => _currentColor = tabColors[_tabController.index]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 48),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 600,
            decoration: BoxDecoration(
              color: _currentColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: AppBar(
              scrolledUnderElevation: 10,
              title: const Text('History'),
              backgroundColor: Colors.transparent,
              actions: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/profile.jpg'),
                  ),
                ),
              ],
              bottom: TabBar(
                dividerHeight: 0,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                controller: _tabController,
                tabs: const [
                  Tab(text: 'ECG'),
                  Tab(text: 'Blood Pressure'),
                  Tab(text: 'Body Temperature'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            DataTab(dataType: SignalType.ecg),
            DataTab(dataType: SignalType.bp),
            DataTab(dataType: SignalType.btemp),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            return FloatingActionButton(
              heroTag: 'fab-${tabController.index}',
              backgroundColor: _currentColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SingleMonitorLayout(
                        initialScreen: _tabController.index),
                  ),
                );
              },
              child: const FaIcon(FontAwesomeIcons.plus),
            );
          },
        ),
      ),
    );
  }
}

class DataTab extends StatefulWidget {
  final SignalType dataType;

  const DataTab({
    super.key,
    required this.dataType,
  });

  @override
  State<DataTab> createState() => _DataTabState();
}

class _DataTabState extends State<DataTab> {
  late String tabTitle;

  Future<List<Signal>> _fetchData(DatabaseHelper dbhelper) async {
    try {
      switch (widget.dataType) {
        case SignalType.ecg:
          tabTitle = widget.dataType.description;
          return await dbhelper.getEcgData(1);
        case SignalType.bp:
          tabTitle = widget.dataType.description;
          return await dbhelper.getBpData(1);
        case SignalType.btemp:
          tabTitle = widget.dataType.description;
          return await dbhelper.getBtempData(1);
        default:
          return [];
      }
    } catch (e) {
      dev.log(e.toString());
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseHelper>(context);

    return FutureBuilder<List<Signal>>(
      future: _fetchData(db),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          return SingleChildScrollView(
            child: Column(
              children: [
                // HISTORY SNAPSHOT VIEW
                _buildChartSummary(context, snapshot.data!),
                // HISTORY DATA VIEW
                ListContainer(
                  listHeading: '$tabTitle History',
                  listData: snapshot.data!,
                ),
              ],
            ),
          );
        }
      },
    );
  }

  List<ColumnChartData> _parseColumnChartData(List<dynamic> data) {
    // average over each day so that you can chart by days
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

  Widget _buildChartSummary(BuildContext context, List<dynamic> signalData) {
    final signaldata = signalData.reversed.toList();
    final datalength = signaldata.length;

    switch (signaldata[0].signalType) {
      case SignalType.ecg:
        final avgHBPM = signaldata.fold(0, (sum, e) => sum + e.hbpm as int) /
            signaldata.length;
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: ChartCard(
            title: 'Heart Rate Summary',
            menuOptions: () {},
            summary: ChartSummary(
              showLegend: true,
              showMultipleColumns: false,
              summaryLabel: 'Avg. Heart Rate (bpm)',
              periodValue: datalength,
              periodLabel: 'records',
              primaryUnitLabel: 'bpm',
              primaryValue: avgHBPM,
              primaryColor: SignalType.ecg.color,
            ),
            legend:
                LegendItem(color: SignalType.ecg.color, label: 'heart rate'),
            child: TrendLineChart(
              height: 160,
              lines: [
                TrendLine(
                  data: _parseHBPMTrendLineData(signaldata),
                  color: SignalType.ecg.color,
                ),
              ],
            ),
          ),
        );

      case SignalType.bp:
        final avgSystolic =
            signaldata.fold(0, (sum, e) => sum + e.systolic as int) /
                datalength;
        final avgDiastolic =
            signaldata.fold(0, (sum, e) => sum + e.diastolic as int) /
                datalength;
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: ChartCard(
            title: 'Blood Pressure Summary',
            menuOptions: () {},
            summary: ChartSummary(
              showLegend: true,
              showMultipleColumns: true,
              summaryLabel: 'Average Blood Pressure (mmHg/day)',
              periodValue: signaldata.length,
              periodLabel: 'days',
              primaryUnitLabel: 'mmHg',
              primaryValue: avgSystolic.toInt(),
              primaryColor: SignalType.bp.color,
              secondaryValue: avgDiastolic.toInt(),
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
              data: _parseColumnChartData(signaldata),
              primaryColor: SignalType.bp.color,
              secondaryColor: SignalType.bp.color.withOpacity(0.4),
            ),
          ),
        );

      case SignalType.btemp:
        final maxTemp =
            signaldata.map((e) => e.avgTemp).reduce((a, b) => a > b ? a : b);
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: ChartCard(
            title: 'Body Temprature',
            summary: ChartSummary(
              showLegend: true,
              showMultipleColumns: false,
              summaryLabel: 'Max Avg. Body Temperature (°C)',
              periodValue: datalength,
              periodLabel: 'records',
              primaryUnitLabel: '°C',
              primaryValue: maxTemp,
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
                  data: _parseTrendLineData(signaldata),
                  color: SignalType.btemp.color,
                  beautify: true,
                ),
                TrendLine(
                  data: _parseMinTrendLineData(signaldata),
                  color: Colors.blueAccent,
                  // beautify: true,
                ),
                TrendLine(
                  data: _parseMaxTrendLineData(signaldata),
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
}
