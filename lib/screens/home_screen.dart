import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:xmonapp/services/models/db_helper.dart';
import 'package:xmonapp/services/models/db_model.dart';
import 'package:xmonapp/widgets/list_container.dart';
import 'package:xmonapp/screens/pages/signal_screen.dart';
import 'package:xmonapp/services/dummy_data.dart';
// import 'package:xmonapp/services/models/db.dart';

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

  void _create() async {
    // final ecgData = Uint8List.fromList([0, 1, 2, 3, 4, 5]);
    // final ecgSignal = EcgModel(
    //   userId: 1,
    //   startTime: DateTime.now(),
    //   stopTime: DateTime.now().add(const Duration(minutes: 5)),
    //   ecg: ecgData,
    // );

    // var ecg = await _dbhelper.createEcgData(ecgSignal);
    // log('ecg data: $ecg');

    final signal = BpModel(
      userId: 1,
      startTime: DateTime.now(),
      stopTime: DateTime.now().add(const Duration(minutes: 3)),
      bpDiastolic: 120,
      bpSystolic: 60,
    );

    var id = await _dbhelper.createBpData(signal);
    log('data id: $id');

    // var user = const CardioUser(email: 'esmond@cardioplus.com');
    // var user2 = const CardioUser(email: 'adjei@cardioplus.com');
    // var user3 = const CardioUser(email: 'xmon@cardioplus.com');
    // await _dbhelper.createUser(user: user);
    // await _dbhelper.createUser(user: user2);
    // await _dbhelper.createUser(user: user3);
  }

  void _get() async {
    // TO BE IMPLEMENTED
    // List<EcgModel> ecgSignals = await _dbhelper.getEcgData(1);
    // for (var ecg in ecgSignals) {
    //   log('ecg: $ecg');
    // }
    // List<BpModel> bpSignals = await _dbhelper.getBpData(1);
    // for (var bp in bpSignals) {
    //   log('bp: $bp data: ${bp.bpSystolic}/${bp.bpDiastolic}');
    // }

    // var users = await _dbhelper.getAllUsers();
    // for (var user in users) {
    //   log('user: $user');
    // }
  }

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
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _create();
                      },
                      child: const Text('Create'),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _get();
                      },
                      child: const Text('Get'),
                    ),
                  ),
                  // ListContainer(
                  //   listHeading: 'ECG | last 3 days',
                  //   listData: getECGData().sublist(0, 3),
                  // ),
                  // const SizedBox(height: 40),
                  // ListContainer(
                  //   listHeading: 'PPPG | last 3 days',
                  //   listData: getBloodPressureData().sublist(0, 3),
                  // ),
                  // const SizedBox(height: 40),
                  // ListContainer(
                  //   listHeading: 'Body Temperature | last 3 days',
                  //   listData: getBodyTemperatureData().sublist(0, 3),
                  // ),
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
        child: const Icon(Icons.devices),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
