import 'package:flutter/material.dart';
import 'package:xmonapp/widgets/list_container.dart';
import 'package:xmonapp/screens/pages/signal_screen.dart';
import 'package:xmonapp/services/dummy_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
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
            Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                children: [
                  ListContainer(
                    listHeading: 'ECG | last 3 days',
                    listData: getECGData().sublist(0, 3),
                  ),
                  const SizedBox(height: 40),
                  ListContainer(
                    listHeading: 'PPPG | last 3 days',
                    listData: getBloodPressureData().sublist(0, 3),
                  ),
                  const SizedBox(height: 40),
                  ListContainer(
                    listHeading: 'Body Temperature | last 3 days',
                    listData: getBodyTemperatureData().sublist(0, 3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const VitalSignalsScreen(userId: 1)),
          );
        },
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.devices),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
