import 'package:flutter/material.dart';
import 'package:xmonapp/widgets/nav_drawer.dart';

class BaseScreen extends StatelessWidget {
  final Widget body;
  final String screenTitle;

  const BaseScreen(
      {super.key, this.screenTitle = 'XmonApp', required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          screenTitle,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: const AppDrawer(),
      body: body,
    );
  }
}
