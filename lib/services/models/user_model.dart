import 'package:flutter/foundation.dart';
import 'package:cardiocare/services/constants.dart';

@immutable
class CardioUser {
  final int? id;
  final String email;

  const CardioUser({
    this.id,
    required this.email,
  });

  CardioUser copyWith({int? id, String? email}) {
    return CardioUser(
      id: id ?? this.id,
      email: email ?? this.email,
    );
  }

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
