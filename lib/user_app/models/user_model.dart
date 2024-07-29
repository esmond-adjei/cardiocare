import 'package:flutter/foundation.dart';
import 'package:cardiocare/services/constants.dart';

@immutable
class CardioUser {
  final int? id;
  final String email;

  final UserProfile? profileInfo;
  final MedicalInfo? medicalInfo;
  final List<EmergencyContact>? emergencyContacts;

  const CardioUser({
    this.id,
    required this.email,
    this.profileInfo,
    this.medicalInfo,
    this.emergencyContacts,
  });

  Map<String, dynamic> toMap() {
    return {
      idColumn: id,
      emailColumn: email,
    };
  }

  factory CardioUser.fromMap(Map<String, dynamic> map) {
    return CardioUser(
      id: map[idColumn] as int?,
      email: map[emailColumn] as String,
    );
  }

  CardioUser copyWith({
    int? id,
    String? email,
    UserProfile? profileInfo,
    MedicalInfo? medicalInfo,
    List<EmergencyContact>? emergencyContacts,
  }) {
    return CardioUser(
      id: id ?? this.id,
      email: email ?? this.email,
      profileInfo: profileInfo ?? this.profileInfo,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }

  @override
  String toString() => 'CardioUser(id: $id, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardioUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}

class UserProfile {
  final String? _profilePicturePath;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String sex;
  final String phoneNumber;
  final String address;

  UserProfile({
    String? profilePicturePath,
    required this.firstName,
    required this.lastName,
    required this.sex,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.address,
  }) : _profilePicturePath = profilePicturePath;

  String? get profilePicturePath => _profilePicturePath;

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      profilePictureColumn: _profilePicturePath,
      firstNameColumn: firstName,
      lastNameColumn: lastName,
      sexColumn: sex,
      dateOfBirthColumn: dateOfBirth.toIso8601String(),
      phoneNumberColumn: phoneNumber,
      addressColumn: address,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      profilePicturePath: map[profilePictureColumn] as String?,
      firstName: map[firstNameColumn] as String,
      lastName: map[lastNameColumn] as String,
      sex: map[sexColumn] as String,
      dateOfBirth: DateTime.parse(map[dateOfBirthColumn] as String),
      phoneNumber: map[phoneNumberColumn] as String,
      address: map[addressColumn] as String,
    );
  }
}

class MedicalInfo {
  final String? note;
  final bool hasCVD;
  final String diagnosedCVD;
  final int yearsOfSmoking;
  final double height; // in meters
  final double weight; // in kg

  MedicalInfo({
    this.note,
    required this.hasCVD,
    required this.yearsOfSmoking,
    required this.diagnosedCVD,
    required this.height,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      noteColumn: note,
      hasCvdColumn: hasCVD ? 1 : 0,
      diagnosedCvdColumn: diagnosedCVD,
      yearsOfSmokingColumn: yearsOfSmoking,
      heightColumn: height,
      weightColumn: weight,
    };
  }

  factory MedicalInfo.fromMap(Map<String, dynamic> map) {
    return MedicalInfo(
      note: map[noteColumn] as String?,
      hasCVD: (map[hasCvdColumn] as int) == 1,
      diagnosedCVD: map[diagnosedCvdColumn] as String,
      yearsOfSmoking: map[yearsOfSmokingColumn] as int,
      height: map[heightColumn] as double,
      weight: map[weightColumn] as double,
    );
  }
}

class EmergencyContact {
  final String name;
  final String phoneNumber;
  final String? email;
  final String relationship;

  EmergencyContact({
    required this.name,
    this.email,
    required this.phoneNumber,
    required this.relationship,
  });

  Map<String, dynamic> toMap() {
    return {
      contactNameColumn: name,
      contactEmailColumn: email,
      contactPhoneNumberColumn: phoneNumber,
      relationshipColumn: relationship,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      name: map[contactNameColumn] as String,
      email: map[contactEmailColumn] as String?,
      phoneNumber: map[contactPhoneNumberColumn] as String,
      relationship: map[relationshipColumn] as String,
    );
  }
}
