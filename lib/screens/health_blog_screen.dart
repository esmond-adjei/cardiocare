import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final List<Map<String, dynamic>> blogData = [
  {
    'title': 'Benefits of working out, daily!',
    'description':
        'Regular exercise has numerous benefits for your overall health and well-being.',
  },
  {
    'title': 'Healthy eating habits for a healthy heart',
    'description':
        'Maintaining a balanced diet is essential for a healthy heart and body.',
  },
  {
    'title': 'Understanding your heart rate',
    'description':
        'Knowing your heart rate can help you monitor your fitness level and overall health.',
  },
  {
    'title': 'The importance of sleep for a healthy heart',
    'description':
        'Getting enough sleep is crucial for maintaining a healthy heart and body.',
  },
  {
    'title': 'Stress management for a healthy heart',
    'description':
        'Managing stress is essential for maintaining a healthy heart and overall well-being.',
  },
  {
    'title': 'The benefits of staying hydrated',
    'description':
        'Drinking enough water is essential for maintaining a healthy heart and body.',
  },
  {
    'title': 'The importance of regular check-ups',
    'description':
        'Regular check-ups are essential for monitoring your heart health and overall well-being.',
  },
  {
    'title': 'The benefits of quitting smoking',
    'description':
        'Quitting smoking has numerous benefits for your heart health and overall well-being.',
  },
  {
    'title': 'The importance of staying active',
    'description':
        'Staying active is essential for maintaining a healthy heart and body.',
  },
  {
    'title': 'The benefits of maintaining a healthy weight',
    'description':
        'Maintaining a healthy weight is essential for a healthy heart and overall well-being.',
  },
];

class HealthBlogScreen extends StatelessWidget {
  const HealthBlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 20,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: const Text(
                'Learn more about keeping your heart fit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // add carousel here
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

            // post lists
            ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blogData.length,
              itemBuilder: (context, index) {
                final data = blogData[index];
                return _buildBlogCard(
                  context,
                  title: data['title'],
                  description: data['description'],
                  onTap: () {
                    // Navigate to blog details screen
                    Navigator.pushNamed(context, '/blog');
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'cardiobot',
        onPressed: () {
          // Navigate to chat bot screen
          Navigator.pushNamed(context, '/chat');
        },
        child: const FaIcon(FontAwesomeIcons.userDoctor),
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context,
      {required String title,
      required String description,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
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
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
