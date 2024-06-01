import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:xmonapp/services/constants.dart';

// user table
@immutable
class CardioUser {
  final int? id;
  final String email;

  const CardioUser({
    required this.id,
    required this.email,
  });

  CardioUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person: ID = $id, email = $email';

  @override
  bool operator ==(covariant CardioUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// signal abstract model
abstract class Signal {
  final int id;
  final int userId;
  final DateTime startTime;
  final DateTime stopTime;
  final String signalType;

  Signal({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.stopTime,
    required this.signalType,
  });

  Signal.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        startTime = map[startTimeColumn] as DateTime,
        stopTime = map[stopTimeColumn] as DateTime,
        signalType = map[signalTypeColumn] as String;

  @override
  String toString() => 'Signal: ID = $id, userID = $userId, type = $signalType';

  @override
  bool operator ==(covariant Signal other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ECG table
class EcgModel extends Signal {
  final Uint8List ecg;

  EcgModel({
    required super.id,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    required this.ecg,
  }) : super(signalType: 'ECG');

  Map<String, dynamic> toMap() {
    return {
      idColumn: id,
      userIdColumn: userId,
      startTimeColumn: startTime.toIso8601String(),
      stopTimeColumn: stopTime.toIso8601String(),
      signalTypeColumn: signalType,
      'ecg': ecg,
    };
  }

  factory EcgModel.fromMap(Map<String, dynamic> map) {
    return EcgModel(
      id: map[idColumn],
      userId: map[userIdColumn],
      startTime: DateTime.parse(map[startTimeColumn]),
      stopTime: DateTime.parse(map[stopTimeColumn]),
      ecg: map['ecg'],
    );
  }
}

// BP table
class BpModel extends Signal {
  final int bpSystolic;
  final int bpDiastolic;

  BpModel({
    required super.id,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    required this.bpSystolic,
    required this.bpDiastolic,
  }) : super(signalType: 'BP');

  Map<String, dynamic> toMap() {
    return {
      idColumn: id,
      userIdColumn: userId,
      startTimeColumn: startTime.toIso8601String(),
      stopTimeColumn: stopTime.toIso8601String(),
      signalTypeColumn: signalType,
      'bp_systolic': bpSystolic,
      'bp_diastolic': bpDiastolic,
    };
  }

  factory BpModel.fromMap(Map<String, dynamic> map) {
    return BpModel(
      id: map[idColumn],
      userId: map[userIdColumn],
      startTime: DateTime.parse(map[startTimeColumn]),
      stopTime: DateTime.parse(map[stopTimeColumn]),
      bpSystolic: map['bp_systolic'],
      bpDiastolic: map['bp_diastolic'],
    );
  }
}

// body temperature table
class BtempModel extends Signal {
  final double bodyTemp;

  BtempModel({
    required super.id,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    required this.bodyTemp,
  }) : super(signalType: 'BTEMP');

  Map<String, dynamic> toMap() {
    return {
      idColumn: id,
      userIdColumn: userId,
      startTimeColumn: startTime.toIso8601String(),
      stopTimeColumn: stopTime.toIso8601String(),
      signalTypeColumn: signalType,
      'body_temp': bodyTemp,
    };
  }

  factory BtempModel.fromMap(Map<String, dynamic> map) {
    return BtempModel(
      id: map[idColumn],
      userId: map[userIdColumn],
      startTime: DateTime.parse(map[startTimeColumn]),
      stopTime: DateTime.parse(map[stopTimeColumn]),
      bodyTemp: map['body_temp'],
    );
  }
}
