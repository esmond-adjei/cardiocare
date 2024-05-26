import 'package:flutter/material.dart';
import 'package:xmonapp/screens/screen_with_header.dart';
// import 'package:xmonapp/services/auth_service.dart';
// import 'package:xmonapp/widgets/custom_button.dart';
// import 'update_profile_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      screenTitle: 'Home',
      body: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print('Profile button pressed!');
          },
          backgroundColor: Colors.redAccent,
          child: const Icon(
            Icons.bluetooth_searching_sharp,
            color: Colors.white,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
