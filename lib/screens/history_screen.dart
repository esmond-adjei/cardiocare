import 'package:flutter/material.dart';
import 'package:xmonapp/screens/pages/create_signal.dart';
import 'package:xmonapp/services/enums.dart';
import 'package:xmonapp/services/models/db_helper.dart';
import 'package:xmonapp/services/models/db_model.dart';
import 'package:xmonapp/widgets/list_container.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'ECG'),
              Tab(text: 'Blood Pressure'),
              Tab(text: 'Body Temperature'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DataTab(dataType: DataType.ECG),
            DataTab(dataType: DataType.BloodPressure),
            DataTab(dataType: DataType.BodyTemperature),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            return FloatingActionButton(
              onPressed: () {
                final currentIndex = tabController.index;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddSignalScreen(
                      dataType: DataType.values[currentIndex],
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}

class DataTab extends StatefulWidget {
  final DataType dataType;

  const DataTab({
    super.key,
    required this.dataType,
  });

  @override
  State<DataTab> createState() => _DataTabState();
}

class _DataTabState extends State<DataTab> {
  late Future<List<Signal>> _dataFuture;
  static final DatabaseHelper _dbhelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  Future<List<Signal>> _fetchData() async {
    try {
      switch (widget.dataType) {
        case DataType.ECG:
          return await _dbhelper.getEcgData(1);
        case DataType.BloodPressure:
          return await _dbhelper.getBpData(1);
        case DataType.BodyTemperature:
          return await _dbhelper.getBtempData(1);
        default:
          return [];
      }
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Signal>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  height: 180,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                ListContainer(
                  listHeading:
                      '${widget.dataType.toString().split('.').last} Data',
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
