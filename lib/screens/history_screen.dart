import 'dart:async';
import 'dart:developer' as dev;
import 'package:cardiocare/utils/enums.dart';
import 'package:cardiocare/widgets/column_chart.dart';
import 'package:cardiocare/widgets/chart_card.dart';
import 'package:cardiocare/widgets/line_chart.dart';
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
            color: _currentColor,
            child: AppBar(
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
            label: '${e.id}00',
            primaryValue: e.systolic,
            secondaryValue: e.diastolic,
          ),
        )
        .toList();
  }

  Widget _buildChartSummary(BuildContext context, List<dynamic> signalData) {
    final List<int> sampleData = [
      52,
      31,
      4,
      51,
      6,
      72,
      8,
      48,
      9,
      48,
      5,
      60,
      7,
      87,
      94,
      9,
      27
    ];

    switch (signalData[0].signalType) {
      case SignalType.bp:
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: ChartCard(
            title: 'Blood Pressure Summary',
            menuOptions: () {},
            child: ColumnChart(
              data: _parseColumnChartData(signalData),
              primaryUnit: 'mmHg',
              primaryLabel: 'sys',
              secondaryLabel: 'dia',
              primaryColor: signalData[0].signalType.color,
              secondaryColor: signalData[0].signalType.color.withOpacity(0.4),
            ),
          ),
        );
      default:
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: ChartCard(
            child: ScrollableLineChart(
              maxY: 100,
              height: 200,
              rounded: true,
              width: MediaQuery.of(context).size.width,
              lineColor: signalData[0].signalType.color,
              dataList: sampleData,
            ),
          ),
        );
    }
  }
}
