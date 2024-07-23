import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StressCard extends StatefulWidget {
  const StressCard({super.key});

  @override
  State<StressCard> createState() => _StressCardState();
}

class _StressCardState extends State<StressCard> {
  String _stressAnimation = 'assets/animations/happy.json';

  void _updateStressAnimation(String newAnimation) {
    setState(() => _stressAnimation = newAnimation);
  }

  void _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StressLevelScreen()),
    );

    if (result != null) {
      _updateStressAnimation(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _navigateAndDisplaySelection(context),
        child: Container(
          height: 140,
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'Stress Level',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Lottie.asset(
                _stressAnimation,
                width: 80,
                height: 80,
              ),
              Text(
                'Tap to update your stressmoji',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StressLevelScreen extends StatelessWidget {
  static const List<String> animations = [
    'assets/animations/happy.json',
    'assets/animations/neutral.json',
    'assets/animations/sad.json',
    'assets/animations/angry.json',
  ];

  const StressLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Stress Level'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: animations.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context, animations[index]);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Lottie.asset(
                  animations[index],
                  width: 100,
                  height: 100,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
