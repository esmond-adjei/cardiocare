import 'package:cardiocare/user_app/widgets/demo_setup.dart';
import 'package:cardiocare/user_app/widgets/user_info_edit.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // TODO: toggle demo mode

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            _buildSettingsSection(
              context,
              title: 'Profile Information',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfileInfoScreen()),
              ),
            ),
            _buildSettingsSection(
              context,
              title: 'Medical Information',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MedicalInfoScreen()),
              ),
            ),
            _buildSettingsSection(
              context,
              title: 'Emergency Contacts',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EmergencyContactsScreen()),
              ),
            ),
            const SizedBox(height: 20),
            _buildLogoutButton(context),
            _buildDeleteAccountButton(context),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DemoSettingsScreen()));
              },
              child: const Text('Demo Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    // TODO: Replace this with actual user profile data
    Map<String, String> profileInfo = {
      'First Name': 'John',
      'Last Name': 'Doe',
      'DOB': '22/02/1990',
      'Sex': 'Male',
      'Email': 'john@cardiocare.com',
      'Phone': '+233 245 6789',
      'Address': '123 Main Street, Accra',
    };

    return Container(
      height: 160.0,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        color: Theme.of(context).primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/profile.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                height: 80.0,
                width: 80.0,
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${profileInfo['First Name']} ${profileInfo['Last Name']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${profileInfo['Email']}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Implement logout functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout functionality not implemented')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade800,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      icon: const Icon(Icons.logout),
      label: const Text('Logout'),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        // TODO: Implement delete account functionality
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Account'),
              content: const Text(
                  'Are you sure you want to delete your account? This action cannot be undone.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    // TODO: Implement actual account deletion
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Account deletion not implemented')),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: const Text('Delete Account'),
    );
  }
}
