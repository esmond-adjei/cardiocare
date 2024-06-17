import 'package:flutter/material.dart';
import 'package:xmonapp/screens/update_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UpdateProfileScreen(),
                  ),
                );
              },
              child: Container(
                height: 160.0,
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        // PROFILE PIC
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/profile.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          height: 60.0,
                          width: 60.0,
                        ),
                        const SizedBox(width: 20),
                        // PROFILE INFO
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Username',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'user@example.com',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        // PROFILE EDIT BUTTON
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UpdateProfileScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            _buildSectionTitle('Profile Information'),
            _buildProfileInfo(),
            _buildSectionTitle('Medical Information'),
            _buildMedicalInfo(),
            _buildSectionTitle('Emergency Contacts'),
            _buildEmergencyContacts(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade300,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          const Row(
            children: [
              Icon(Icons.menu, color: Colors.black),
              SizedBox(width: 10),
              Icon(Icons.add, color: Colors.black),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileInfoRow('First Name', 'person'),
          _buildProfileInfoRow('Last Name', 'in name'),
          _buildProfileInfoRow('DOB', '22/02/2022'),
          _buildProfileInfoRow('Sex', 'Male'),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMedicalInfoRow('Smoker Yrs', '2 years'),
          _buildMedicalInfoRowWithSwitch('Diagnosed with CVD', true),
          _buildMedicalInfoRow('Height', '5.11 m'),
          _buildMedicalInfoRow('Weight', '79 kg'),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoRowWithSwitch(String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(width: 10),
          Switch(
            value: value,
            onChanged: (bool newValue) {},
            activeColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildEmergencyContact(
            'Dr. House',
            'Personal Cardiologist',
            '+233 245 6789',
            'drhouse@cardio.com',
          ),
          const SizedBox(height: 10),
          _buildEmergencyContact(
            'Honey',
            'Bride and Wife',
            '+233 986 6543',
            'honey@wife.com',
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact(
      String name, String relation, String phone, String email) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.black)),
              Text('Relation: $relation',
                  style: const TextStyle(color: Colors.grey)),
              Text('Home: $phone', style: const TextStyle(color: Colors.grey)),
              Text('Email: $email', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.phone, color: Colors.blue),
          const SizedBox(width: 10),
          const Icon(Icons.message, color: Colors.blue),
        ],
      ),
    );
  }
}
