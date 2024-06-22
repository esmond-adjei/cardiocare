import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:xmonapp/screens/drawers/monitoring_screen.dart';
import 'package:xmonapp/services/constants.dart';
import 'package:xmonapp/services/models/db_helper.dart';
import 'package:xmonapp/services/models/db_model.dart';
import 'package:xmonapp/widgets/list_container.dart';

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
            DataTab(dataType: ecgType),
            DataTab(dataType: bpType),
            DataTab(dataType: btempType),
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
  final String dataType;

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
        case ecgType:
          tabTitle = 'Ecg History';
          return await dbhelper.getEcgData(1);
        case bpType:
          tabTitle = 'Blood Pressure History';
          return await dbhelper.getBpData(1);
        case btempType:
          tabTitle = 'Body Temperature History';
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
                Container(
                  height: 180,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // HISTORY DATA VIEW
                ListContainer(
                  listHeading: tabTitle,
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
