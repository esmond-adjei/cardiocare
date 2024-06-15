import 'package:flutter/material.dart';
import 'package:xmonapp/services/constants.dart';
import 'package:xmonapp/services/models/db_helper.dart';
import 'package:xmonapp/services/models/db_model.dart';
import 'package:xmonapp/widgets/list_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  late DatabaseHelper _dbhelper;

  @override
  void initState() {
    super.initState();
    _dbhelper = DatabaseHelper();
  }

  Future<Map<String, List<Signal>>> _getRecent() async {
    return await _dbhelper.getRecentRecords(1, limit: 3);
    // log(results.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hi, Esmond!'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [Colors.redAccent, Colors.blueAccent],
                  stops: [0.1, 0.9],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 140,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 140,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),

            // LIST OF RECENT RECORDS
            FutureBuilder<Map<String, List<Signal>>>(
              future: _getRecent(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available'));
                } else {
                  Map<String, List<Signal>> results;
                  results = snapshot.data!;

                  return Column(
                    children: [
                      ...results.entries.map(
                        (entry) => ListContainer(
                          listHeading: entry.key == ecgType
                              ? 'ECG Signal'
                              : entry.key == bpType
                                  ? 'Blood Pressure'
                                  : entry.key == btempType
                                      ? 'Body Temperature'
                                      : 'Unknown',
                          listData: entry.value,
                          routeToHistoryScreen: () {
                            Navigator.pushNamed(
                              context,
                              '/history',
                              // arguments: entry.key,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/device');
        },
        child: const Icon(Icons.devices),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
