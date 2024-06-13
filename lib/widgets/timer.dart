import 'dart:async';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({
    super.key,
    required this.isRecording,
    required this.isPaused,
    required this.stopwatch,
  });

  final bool isRecording;
  final bool isPaused;
  final Stopwatch stopwatch;

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.isRecording && !widget.isPaused) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _startTimer();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _stopTimer();
    } else if (widget.isPaused && !oldWidget.isPaused) {
      _pauseTimer();
    } else if (!widget.isPaused && oldWidget.isPaused) {
      _resumeTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    widget.stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    widget.stopwatch.reset();
    setState(() {});
  }

  void _pauseTimer() {
    widget.stopwatch.stop();
    setState(() {});
  }

  void _resumeTimer() {
    widget.stopwatch.start();
    setState(() {});
  }

  String _formatTime(int milliseconds) {
    final int seconds = milliseconds ~/ 1000;
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTime(widget.stopwatch.elapsedMilliseconds),
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
