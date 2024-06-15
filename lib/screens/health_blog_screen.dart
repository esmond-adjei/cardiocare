import 'package:flutter/material.dart';

class HealthBlogScreen extends StatelessWidget {
  const HealthBlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record'),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Record Screen',
            style: TextStyle(fontSize: 24),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/device');
              },
              child: const Text('Record'),
            ),
          ),
        ],
      ),
    );
  }
}
