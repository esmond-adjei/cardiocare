import 'package:flutter/material.dart';
import 'package:xmonapp/widgets/timer.dart';

class ECGScreen extends StatelessWidget {
  const ECGScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: TimerWidget(),
          ),
        ),
        Center(
          child: ECGGraph(),
        ),
        Positioned(
          bottom: 80,
          right: 20,
          child: Text(
            'HRV 82bpm',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class ECGGraph extends StatelessWidget {
  const ECGGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(260, 260),
      painter: ECGGraphPainter(),
    );
  }
}

class ECGGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint gridPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    Paint linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    // Draw the grid
    for (double i = 0; i <= size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i <= size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Draw the ECG line (sample data)
    Path path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width * 0.1, size.height / 2 - 30);
    path.lineTo(size.width * 0.2, size.height / 2);
    path.lineTo(size.width * 0.3, size.height / 2 + 30);
    path.lineTo(size.width * 0.4, size.height / 2);
    path.lineTo(size.width * 0.5, size.height / 2 - 30);
    path.lineTo(size.width * 0.6, size.height / 2);
    path.lineTo(size.width * 0.7, size.height / 2 + 30);
    path.lineTo(size.width * 0.8, size.height / 2);
    path.lineTo(size.width * 0.9, size.height / 2 - 30);
    path.lineTo(size.width, size.height / 2);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
