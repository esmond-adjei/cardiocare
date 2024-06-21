import 'package:flutter/material.dart';
import 'package:xmonapp/screens/drawers/monitoring_screen.dart';

class ConnectDevice extends StatelessWidget {
  const ConnectDevice({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [Colors.redAccent, Colors.blueAccent],
            stops: [0.1, 0.9],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Ensure you are connected to the cardiocare device with bluetooth',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SingleMonitorLayout(),
                  ),
                );
              },
              child: const Text('Start Monitoring'),
            ),
          ],
        ),
      ),
    );
  }
}
