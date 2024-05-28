import 'package:flutter/material.dart';
import 'package:xmonapp/screens/screen_with_header.dart';
import 'package:xmonapp/screens/signal_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      screenTitle: 'Home',
      body: VitalSignalsScreen(userId: 1),
    );
  }
}
