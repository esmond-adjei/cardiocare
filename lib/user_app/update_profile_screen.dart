import 'package:flutter/material.dart';
import 'package:cardiocare/user_app/dummy_user_data.dart';
// import 'package:cardiocare/widgets/custom_button.dart';
import '../signal_app/home_screen.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late Future<Map<String, String>> _userProfile;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _userProfile = _authService.getUserProfile();
    _userProfile.then((profile) {
      _nameController.text = profile['name'] ?? '';
      _emailController.text = profile['email'] ?? '';
    });
  }

  void _updateProfile() async {
    final name = _nameController.text;
    final email = _emailController.text;

    final success = await _authService.updateUserProfile(name, email);
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'User Profile',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _updateProfile,
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
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
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 56.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'e.g., Jane Doe',
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'e.g., user@example.com',
                        ),
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
