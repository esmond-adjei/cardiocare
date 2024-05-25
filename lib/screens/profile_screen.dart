// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:xmonapp/services/auth_service.dart';
import 'package:xmonapp/widgets/custom_button.dart';
import 'update_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  late Future<Map<String, String>> _userProfile;

  @override
  void initState() {
    super.initState();
    _userProfile = _authService.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _userProfile,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading profile'));
              } else if (snapshot.hasData) {
                final profile = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Name: ${profile['name']}'),
                      const SizedBox(height: 16.0),
                      Text('Email: ${profile['email']}'),
                      const SizedBox(height: 16.0),
                      CustomButton(
                        text: 'Update Profile',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UpdateProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('No profile data'));
              }
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
