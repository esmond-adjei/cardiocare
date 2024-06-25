import 'package:flutter/material.dart';
import 'package:xmonapp/user/update_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isProfileExpanded = true;
  bool _isMedicalExpanded = true;
  bool _isEmergencyExpanded = true;

  // Sample data
  Map<String, String> profileInfo = {
    'First Name': 'John',
    'Last Name': 'Doe',
    'DOB': '22/02/1990',
    'Sex': 'Male',
  };

  Map<String, dynamic> medicalInfo = {
    'Smoker Years': '2 years',
    'Diagnosed with CVD': true,
    'Height': '5.11 m',
    'Weight': '79 kg',
  };

  List<Map<String, String>> emergencyContacts = [
    {
      'name': 'Dr. House',
      'relation': 'Personal Cardiologist',
      'phone': '+233 245 6789',
      'email': 'drhouse@cardio.com',
    },
    {
      'name': 'Honey',
      'relation': 'Spouse',
      'phone': '+233 986 6543',
      'email': 'honey@wife.com',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildExpandableSection(
              title: 'Profile Information',
              isExpanded: _isProfileExpanded,
              onExpansionChanged: (value) =>
                  setState(() => _isProfileExpanded = value),
              children: [_buildProfileInfo()],
              onEdit: () => _showEditDialog('Profile Information', profileInfo),
            ),
            _buildExpandableSection(
              title: 'Medical Information',
              isExpanded: _isMedicalExpanded,
              onExpansionChanged: (value) =>
                  setState(() => _isMedicalExpanded = value),
              children: [_buildMedicalInfo()],
              onEdit: () => _showEditDialog('Medical Information', medicalInfo),
            ),
            _buildExpandableSection(
              title: 'Emergency Contacts',
              isExpanded: _isEmergencyExpanded,
              onExpansionChanged: (value) =>
                  setState(() => _isEmergencyExpanded = value),
              children: [_buildEmergencyContacts()],
              // onEdit: null,
            ),
            const SizedBox(height: 20),
            _buildLogoutButton(),
            _buildDeleteAccountButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      height: 160.0,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.redAccent, Colors.red.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                  const Text(
                    'user@example.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
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
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required Function(bool) onExpansionChanged,
    required List<Widget> children,
    VoidCallback? onEdit,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              onEdit == null
                  ? const SizedBox()
                  : IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: onEdit,
                    ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.grey,
              ),
            ],
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: profileInfo.entries
            .map((entry) => _buildInfoRow(entry.key, entry.value))
            .toList(),
      ),
    );
  }

  Widget _buildMedicalInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: medicalInfo.entries
            .map((entry) => _buildInfoRow(entry.key, entry.value))
            .toList(),
      ),
    );
  }

  Widget _buildInfoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // TEXT TITLE COLUMN
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),

          // VALUE COLUMN
          if (value is bool)
            Switch(
              value: value,
              onChanged: (bool newValue) =>
                  setState(() => medicalInfo[title] = newValue),
              activeColor: Colors.redAccent,
            )
          else
            Text(
              value,
              style: TextStyle(color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...emergencyContacts
              .map((contact) => _buildEmergencyContact(contact)),
          ElevatedButton(
            child: const Text('Add New Contact'),
            onPressed: () => _showEditContactDialog({}),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact(Map<String, String> contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.redAccent,
                child: Text(
                  contact['name']?.substring(0, 1).toUpperCase() ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact['name'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      contact['relation'] ?? '',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () => _showEditContactDialog(contact),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(contact['phone'] ?? ''),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.email, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(contact['email'] ?? ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
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

  Widget _buildDeleteAccountButton() {
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

  void _showEditContactDialog(Map<String, String> contact) {
    final isNewContact = contact.isEmpty;
    final editedContact = Map<String, String>.from(contact);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isNewContact ? 'Add New Contact' : 'Edit Contact'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                for (String key in ['name', 'relation', 'phone', 'email'])
                  TextFormField(
                    initialValue: editedContact[key] ?? '',
                    decoration: InputDecoration(labelText: key.capitalize()),
                    onChanged: (value) {
                      editedContact[key] = value;
                    },
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (!isNewContact)
              TextButton(
                child: const Text('Delete'),
                onPressed: () {
                  setState(() => emergencyContacts.remove(contact));
                  Navigator.of(context).pop();
                },
              ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  if (isNewContact) {
                    emergencyContacts.add(editedContact);
                  } else {
                    final index = emergencyContacts.indexOf(contact);
                    emergencyContacts[index] = editedContact;
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(String title, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Map<String, dynamic> editedData = Map.from(data);
        return AlertDialog(
          title: Text('Edit $title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: editedData.entries.map((entry) {
                if (entry.value is bool) {
                  return SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    title: Text(entry.key),
                    value: entry.value,
                    onChanged: (bool value) =>
                        setState(() => editedData[entry.key] = value),
                  );
                } else {
                  return TextFormField(
                    initialValue: entry.value.toString(),
                    decoration: InputDecoration(labelText: entry.key),
                    onChanged: (value) {
                      editedData[entry.key] = value;
                    },
                  );
                }
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  if (title == 'Profile Information') {
                    profileInfo = Map<String, String>.from(editedData);
                  } else if (title == 'Medical Information') {
                    medicalInfo = editedData;
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
