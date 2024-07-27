import 'package:cardiocare/services/preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:cardiocare/_playground.dart';
import 'package:cardiocare/services/db_helper.dart';
import 'package:cardiocare/utils/format_datetime.dart';
import 'package:cardiocare/signal_app/charts/trend_line_chart.dart';
import 'package:cardiocare/signal_app/widgets/stressmogi.dart';
import 'package:cardiocare/signal_app/widgets/list_container.dart';
import 'package:cardiocare/signal_app/model/signal_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final DatabaseHelper dbhelper = Provider.of<DatabaseHelper>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

            _DashBoard(),

            const Row(
              children: [
                Expanded(
                  child: DashSignalView(),
                ),
                StressCard(),
              ],
            ),

            // LIST OF RECENT RECORDS
            FutureBuilder<List<Signal>>(
              future: dbhelper.getRecentRecords(1, limit: 6),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error: something went wrong'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available'));
                } else {
                  return ListContainer(
                    listHeading: 'Recent Records',
                    listData: snapshot.data!,
                    expandable: true,
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
            bottom: 70.0,
            right: 7.0,
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
                      builder: (context) =>
                          // const ChatScreen(),
                          const Playground(),
                    ),
                  );
                },
                child: const FaIcon(FontAwesomeIcons.userDoctor, size: 20),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            right: 0.0,
            child: FloatingActionButton(
              heroTag: 'connect-device',
              onPressed: () => Navigator.pushNamed(context, '/record'),
              child: const FaIcon(FontAwesomeIcons.personRays),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class DashSignalView extends StatelessWidget {
  const DashSignalView({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper dbhelper = Provider.of<DatabaseHelper>(context);

    return Container(
      height: 140,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: FutureBuilder<EcgModel?>(
        future: dbhelper.getLatestEcg(1),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            final ecgData = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatRelativeDate(ecgData.stopTime.toString()),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.heartPulse,
                      color: Theme.of(context).primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${ecgData.hbpm} bpm',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TrendLineChart(
                  height: 70,
                  showLeftTitles: false,
                  lines: [
                    TrendLine(
                      data: ecgData.ecgList
                          .map(
                            (e) => TrendLinePoint(
                              e.toDouble(),
                              e.toDouble(),
                            ),
                          )
                          .toList(),
                      color: Theme.of(context).primaryColor,
                      beautify: true,
                    )
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class _DashBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 209, 69, 69),
            Color.fromARGB(255, 255, 143, 88),
            Color.fromARGB(255, 255, 216, 107),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              FaIcon(
                FontAwesomeIcons.chartLine,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 9),
              Text(
                'Daily Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Expanded(
            child: Consumer<SharedPreferencesManager>(
              builder: (context, prefsManager, child) {
                final metrics = prefsManager.getAllMetrics();
                return metrics.isEmpty
                    ? const Center(child: Text('No data available'))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: metrics
                            .map((m) =>
                                _buildMetricColumn(m.text, m.value, m.unit))
                            .toList(),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, String unit) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
