import 'dart:developer' as dev;
import 'package:cardiocare/user_app/models/demo_user.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:cardiocare/services/db_helper.dart';
import 'package:cardiocare/user_app/models/user_model.dart';

class Playground extends StatefulWidget {
  const Playground({super.key});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  late CardioUser _currentUser;

  void _createDemoUser() async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    final user = await dbHelper.createUser(user: demoUser); // create first
    await dbHelper.createUserProfile(demoProfile);
    await dbHelper.createMedicalInfo(demoMedicalInfo);
    for (var contact in demoEmergencyContacts) {
      await dbHelper.createEmergencyContact(contact);
    }

    setState(() => _currentUser = user);
  }

  void _getUser() async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    _currentUser = await dbHelper.getUser(email: 'john@cardiocare.com');
    dev.log(_currentUser.toString());
  }

  @override
  Widget build(BuildContext context) {
    final dbHelper = Provider.of<DatabaseHelper>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () => _createDemoUser(),
              child: const Text('Create Demo User')),
          ElevatedButton(
            onPressed: _getUser,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Get Demo User'),
          ),
          FutureBuilder<CardioUser>(
              future: dbHelper.getUser(email: 'john@cardiocare.com'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No data available'));
                } else {
                  _currentUser = snapshot.data!;
                  return Column(
                    children: [
                      Text(
                          'First Name: ${_currentUser.profileInfo?.firstName}'),
                      Text('Last Name: ${_currentUser.profileInfo?.lastName}'),
                      Text('DOB: ${_currentUser.profileInfo?.dateOfBirth}'),
                    ],
                  );
                }
              }),
        ],
      ),
    );
  }
}
