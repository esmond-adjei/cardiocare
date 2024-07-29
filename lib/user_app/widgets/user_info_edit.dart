import 'package:flutter/material.dart';

Map<String, String> userInfo = {
  'id': '1',
  'Email': 'john@cardiocare.com',
  'First Name': 'John',
  'Last Name': 'Doe',
};

// Sample data (move this to a provider or state management solution in a real app)
Map<String, String> profileInfo = {
  'profile_pic': 'assets/images/profile_pic.jpg',
  'DOB': '22/02/1990',
  'Sex': 'Male',
  'Phone': '+233 245 6789',
  'Address': '123 Main Street, Accra',
};

// Sample data (move this to a provider or state management solution in a real app)
Map<String, dynamic> medicalInfo = {
  'Smoker Years': '2 years',
  'Diagnosed with CVD': true,
  'Height': '5.11 m',
  'Weight': '79 kg',
};

// Sample data (move this to a provider or state management solution in a real app)
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

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: profileInfo.entries.map((entry) {
            return TextFormField(
              initialValue: entry.value,
              decoration: InputDecoration(labelText: entry.key),
              onChanged: (value) {
                setState(() {
                  profileInfo[entry.key] = value;
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class MedicalInfoScreen extends StatefulWidget {
  const MedicalInfoScreen({super.key});

  @override
  State<MedicalInfoScreen> createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: medicalInfo.entries.map((entry) {
            if (entry.value is bool) {
              return SwitchListTile(
                title: Text(entry.key),
                value: entry.value,
                onChanged: (bool value) {
                  setState(() {
                    medicalInfo[entry.key] = value;
                  });
                },
              );
            } else {
              return TextFormField(
                initialValue: entry.value.toString(),
                decoration: InputDecoration(labelText: entry.key),
                onChanged: (value) {
                  setState(() {
                    medicalInfo[entry.key] = value;
                  });
                },
              );
            }
          }).toList(),
        ),
      ),
    );
  }
}

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: ListView.builder(
        itemCount: emergencyContacts.length,
        itemBuilder: (context, index) {
          return _buildEmergencyContact(emergencyContacts[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showEditContactDialog({}),
      ),
    );
  }

  Widget _buildEmergencyContact(Map<String, String> contact) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.redAccent,
          child: Text(
            contact['name']?.substring(0, 1).toUpperCase() ?? '',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(contact['name'] ?? ''),
        subtitle: Text(contact['relation'] ?? ''),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showEditContactDialog(contact),
        ),
      ),
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
}

// string entesnions
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
