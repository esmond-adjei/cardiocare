// User info
import 'package:cardiocare/services/constants.dart';
import 'package:cardiocare/user_app/models/user_model.dart';

Map<String, dynamic> userInfo = {
  idColumn: 1,
  emailColumn: 'john@cardiocare.com',
};

// Profile info
Map<String, String> profileInfo = {
  profilePictureColumn: 'assets/images/profile.jpg',
  firstNameColumn: 'John',
  lastNameColumn: 'Doe',
  dateOfBirthColumn: '1990-02-22',
  sexColumn: 'Male',
  phoneNumberColumn: '+233 245 6789',
  addressColumn: '123 Main Street, Accra',
};

// Medical info
Map<String, dynamic> medicalInfo = {
  noteColumn: 'Patient has a history of hypertension, but is currently stable.',
  yearsOfSmokingColumn: 2,
  hasCvdColumn: 1,
  diagnosedCvdColumn: 'Hypertension',
  heightColumn: 5.11,
  weightColumn: 79.0,
};

// Emergency contacts
List<Map<String, String>> emergencyContacts = [
  {
    contactNameColumn: 'Dr. House',
    relationshipColumn: 'Personal Cardiologist',
    contactPhoneNumberColumn: '+233 245 6789',
    contactEmailColumn: 'drhouse@cardio.com',
  },
  {
    contactNameColumn: 'Honey',
    relationshipColumn: 'Spouse',
    contactPhoneNumberColumn: '+233 986 6543',
    contactEmailColumn: 'honey@wife.com',
  },
];

// Create instances using fromMap
UserProfile demoProfile = UserProfile.fromMap(profileInfo);

MedicalInfo demoMedicalInfo = MedicalInfo.fromMap(medicalInfo);

List<EmergencyContact> demoEmergencyContacts = emergencyContacts.map((contact) {
  return EmergencyContact.fromMap(contact);
}).toList();

// Create the CardioUser instance
CardioUser demoUser = CardioUser(
  id: userInfo[idColumn]!,
  email: userInfo[emailColumn]!,
  emergencyContacts: demoEmergencyContacts,
);
