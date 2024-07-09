import 'package:cardiocare/screens/_playground.dart';
import 'package:flutter/material.dart';
import 'package:cardiocare/utils/enums.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cardiocare/services/models/db_helper.dart';
import 'package:cardiocare/services/models/signal_model.dart';
import 'package:cardiocare/widgets/list_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  Future<Map<SignalType, List<Signal>>> _getRecent(
      DatabaseHelper dbhelper) async {
    return await dbhelper.getRecentRecords(1, limit: 3);
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper dbhelper = Provider.of<DatabaseHelper>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 20,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hi, Esmond!',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                  ),
                ],
              ),
            ),

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
            FutureBuilder<Map<SignalType, List<Signal>>>(
              future: _getRecent(dbhelper),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available'));
                } else {
                  Map<SignalType, List<Signal>> results;
                  results = snapshot.data!;

                  return Column(
                    children: [
                      ...results.entries.map(
                        (entry) => ListContainer(
                          listHeading: entry.key.description,
                          listData: entry.value,
                          routeToHistoryScreen: () {
                            Navigator.pushNamed(
                              context,
                              '/history',
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
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 80.0,
            right: 14.0,
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.greenAccent,
                    Colors.blueAccent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FloatingActionButton(
                heroTag: 'cardiobot-mobile',
                backgroundColor: Colors.transparent,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HealthDashboard(),
                    ),
                  );
                },
                child: const FaIcon(FontAwesomeIcons.userDoctor, size: 20),
              ),
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: FloatingActionButton(
              heroTag: 'connect-device',
              onPressed: () => Navigator.pushNamed(context, '/device'),
              child: const FaIcon(FontAwesomeIcons.personRays),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
