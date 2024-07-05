import 'dart:async';
import 'dart:developer' as dev;
import 'package:cardiocare/utils/enums.dart';
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, initialIndex: 0, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('History'),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SingleMonitorLayout(
                        initialScreen: _tabController.index),
                  ),
                );
              },
              child: const FaIcon(FontAwesomeIcons.recordVinyl),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 200,
                    margin: const EdgeInsets.all(20),
                    // decoration: BoxDecoration(
                    //   color: Colors.grey.shade100,
                    //   borderRadius: BorderRadius.circular(10),
                    // ),
                    child: ScrollableLineChart(
                      maxY: 100,
                      lineColor: snapshot.data![0].signalType.color,
                      dataList: const [
                        52,
                        31,
                        4,
                        51,
                        6,
                        72,
                        8,
                        48,
                        9,
                        97,
                        9,
                        58,
                        6,
                        54,
                        4,
                        2,
                        48,
                        5,
                        60,
                        7,
                        87,
                        94,
                        9,
                        27
                      ],
                    ),
                  ),
                ),
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
}
