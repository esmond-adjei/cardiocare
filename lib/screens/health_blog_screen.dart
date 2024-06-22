import 'package:flutter/material.dart';

class HealthBlogScreen extends StatelessWidget {
  const HealthBlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 20,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Text(
                'Learn more about keeping your heart fit',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView(
              padding: const EdgeInsets.all(10.0),
              children: [
                _buildBlogCard(
                  context,
                  title: 'Benefits of working out, daily!',
                  color: Colors.red.shade100,
                  onTap: () {
                    // Navigate to detailed view or perform any action
                  },
                ),
                const SizedBox(height: 16.0),
                _buildBlogCard(
                  context,
                  title: 'Healthy eating habits for a healthy heart',
                  color: Colors.red.shade200,
                  onTap: () {
                    // Navigate to detailed view or perform any action
                  },
                ),
                const SizedBox(height: 16.0),
                _buildBlogCard(
                  context,
                  title: 'Understanding your heart rate',
                  color: Colors.red.shade300,
                  onTap: () {
                    // Navigate to detailed view or perform any action
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'cardiobot',
        onPressed: () {
          // Navigate to chat bot screen
        },
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context,
      {required String title,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(Icons.share, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}
