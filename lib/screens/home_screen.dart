import 'package:flutter/material.dart';
// import 'package:xmonapp/screens/screen_with_header.dart';
import 'package:xmonapp/screens/signal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const VitalSignalsScreen(userId: 1);
  }
}
