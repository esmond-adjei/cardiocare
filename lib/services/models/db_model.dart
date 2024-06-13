import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:xmonapp/services/constants.dart';

// user table
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
  final int? id;
  final int userId;
  String? signalName;
  final DateTime startTime;
  DateTime stopTime;
  final String signalType;

  Signal({
    this.id,
    this.signalName,
    required this.userId,
    required this.startTime,
    required this.stopTime,
    required this.signalType,
  });

  String get name => signalName ?? '$signalType $id';

  void setName(String name) {
    signalName = name;
  }

  void setStopTime(DateTime time) {
    stopTime = time;
  }

  Signal.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        signalName = map[nameColumn] as String,
        userId = map[userIdColumn] as int,
        startTime = map[startTimeColumn] as DateTime,
        stopTime = map[stopTimeColumn] as DateTime,
        signalType = map[signalTypeColumn] as String;

  Map<String, dynamic> toMap();

  @override
  String toString() =>
      'Signal: ID = $id, SN:$signalName, userID = $userId, type = $signalType';

  @override
  bool operator ==(covariant Signal other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ECG table
class EcgModel extends Signal {
  static String tableName = ecgTable;
  static const String sType = 'ECG';
  late Uint8List? ecg = Uint8List(0);

  EcgModel({
    super.id,
    super.signalName,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    this.ecg,
  }) : super(signalType: sType);

  void write(int value) {
    ecg?.add(value);
  }

  // set ecg
  void setEcg(List<int> data) {
    ecg = Uint8List.fromList(data);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      idColumn: id,
      userIdColumn: userId,
      nameColumn: signalName,
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
      signalName: map[nameColumn],
      startTime: DateTime.parse(map[startTimeColumn]),
      stopTime: DateTime.parse(map[stopTimeColumn]),
      ecg: map['ecg'],
    );
  }
}

// BP table
class BpModel extends Signal {
  static String tableName = bpTable;
  static String sType = 'BP';
  final int bpSystolic;
  final int bpDiastolic;

  BpModel({
    super.id,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    required this.bpSystolic,
    required this.bpDiastolic,
  }) : super(signalType: sType);

  @override
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
  static String tableName = btempTable;
  static String sType = 'BTEMP';
  final double bodyTemp;

  BtempModel({
    super.id,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    required this.bodyTemp,
  }) : super(signalType: sType);

  @override
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
