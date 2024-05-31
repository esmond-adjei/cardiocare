import 'dart:typed_data';
import 'package:flutter/material.dart';

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

  Signal({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.stopTime,
  });

  Signal.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        startTime = map[startTimeColumn] as DateTime,
        stopTime = map[stopTimeColumn] as DateTime;

  @override
  String toString() => 'Signal: ID = $id, userID = $userId';

  @override
  bool operator ==(covariant Signal other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ECG table
class EcgData extends Signal {
  final List<int> ecg;

  EcgData({
    required super.id,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    required this.ecg,
  });

  Map<String, dynamic> toMap() {
    return {
      idColumn: id,
      userIdColumn: userId,
      startTimeColumn: startTime.toIso8601String(),
      stopTimeColumn: stopTime.toIso8601String(),
      'ecg': Uint8List.fromList(ecg),
    };
  }

  factory EcgData.fromMap(Map<String, dynamic> map) {
    return EcgData(
      id: map[idColumn],
      userId: map[userIdColumn],
      startTime: DateTime.parse(map[startTimeColumn]),
      stopTime: DateTime.parse(map[stopTimeColumn]),
      ecg: List<int>.from(map['ecg']),
    );
  }
}

// BP table
class BpData extends Signal {
  final int bpSystolic;
  final int bpDiastolic;

  BpData({
    required super.id,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    required this.bpSystolic,
    required this.bpDiastolic,
  });

  Map<String, dynamic> toMap() {
    return {
      idColumn: id,
      userIdColumn: userId,
      startTimeColumn: startTime.toIso8601String(),
      stopTimeColumn: stopTime.toIso8601String(),
      'bp_systolic': bpSystolic,
      'bp_diastolic': bpDiastolic,
    };
  }

  factory BpData.fromMap(Map<String, dynamic> map) {
    return BpData(
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
class Btemp extends Signal {
  final double bodyTemp;

  Btemp({
    required super.id,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    required this.bodyTemp,
  });

  Map<String, dynamic> toMap() {
    return {
      userIdColumn: userId,
      startTimeColumn: startTime.toIso8601String(),
      stopTimeColumn: stopTime.toIso8601String(),
      'body_temp': bodyTemp,
    };
  }

  factory Btemp.fromMap(Map<String, dynamic> map) {
    return Btemp(
      id: map[idColumn],
      userId: map[userIdColumn],
      startTime: DateTime.parse(map[startTimeColumn]),
      stopTime: DateTime.parse(map[stopTimeColumn]),
      bodyTemp: map['body_temp'],
    );
  }
}

// ------ CONSTANTS --------
const dbName = 'cardio.db';
const userTable = 'cardio_user';
const ecgTable = 'cardio_ecg';
const bpTable = 'cardio_bp';
const btempTable = 'cardio_btemp';

const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const startTimeColumn = 'start_time';
const stopTimeColumn = 'stop_time';
