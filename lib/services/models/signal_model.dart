import 'package:flutter/foundation.dart';
import 'package:cardiocare/utils/enums.dart';
import 'package:cardiocare/services/constants.dart';

abstract class Signal {
  final int? id;
  final int userId;
  String? signalName;
  final int? signalId;
  final DateTime startTime;
  DateTime stopTime;
  final SignalType signalType;
  String? signalInfo;

  Signal({
    this.id,
    this.signalName,
    this.signalId,
    required this.userId,
    required this.startTime,
    required this.stopTime,
    required this.signalType,
  });

  String get name =>
      signalName ??
      '${signalType.name} ${stopTime.day}-${stopTime.month}-${stopTime.year} ${stopTime.hour}:${stopTime.minute}';

  set name(String newName) {
    signalName = newName;
  }

  set stoptime(DateTime time) {
    stopTime = time;
  }

  Map<String, dynamic> toMap() {
    return {
      idColumn: id,
      userIdColumn: userId,
      nameColumn: signalName,
      startTimeColumn: startTime.toIso8601String(),
      stopTimeColumn: stopTime.toIso8601String(),
      signalTypeColumn: signalType.name,
      signalInfoColumn: signalInfo,
    };
  }

  @override
  String toString() =>
      'Signal(id: $id, signalName: $signalName, userId: $userId, signalType: ${signalType.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Signal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          signalType == other.signalType;

  @override
  int get hashCode =>
      id.hashCode ^ userId.hashCode ^ signalId.hashCode ^ signalType.hashCode;
}

class EcgModel extends Signal {
  Uint8List? ecg;
  double? hrv;
  double? hbpm;

  EcgModel({
    super.id,
    super.signalName,
    super.signalId,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    this.ecg,
  }) : super(signalType: SignalType.ecg);

  set ecgData(List<int> ecgValues) {
    ecg = Uint8List.fromList(ecgValues);
  }

  Uint8List get ecgData {
    return ecg ?? Uint8List.fromList([]);
  }

  factory EcgModel.fromMap(Map<String, dynamic> map) {
    return EcgModel(
      id: map[idColumn] as int?,
      userId: map[userIdColumn] as int,
      signalName: map[nameColumn] as String?,
      signalId: map[signalIdColumn] as int?,
      startTime: DateTime.parse(map[startTimeColumn] as String),
      stopTime: DateTime.parse(map[stopTimeColumn] as String),
      ecg: map['ecg'] as Uint8List,
    );
  }
}

class BpModel extends Signal {
  int? bpSystolic;
  int? bpDiastolic;

  BpModel({
    super.id,
    super.signalName,
    super.signalId,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    this.bpSystolic,
    this.bpDiastolic,
  }) : super(signalType: SignalType.bp);

  set bpData(List<int> bpValues) {
    bpSystolic = bpValues[0];
    bpDiastolic = bpValues[1];
  }

  List<int> get bpData {
    return [bpSystolic ?? 0, bpDiastolic ?? 0];
  }

  factory BpModel.fromMap(Map<String, dynamic> map) {
    return BpModel(
      id: map[idColumn] as int?,
      userId: map[userIdColumn] as int,
      signalId: map[signalIdColumn] as int?,
      signalName: map[nameColumn] as String?,
      startTime: DateTime.parse(map[startTimeColumn] as String),
      stopTime: DateTime.parse(map[stopTimeColumn] as String),
      bpSystolic: map['bp_systolic'] as int?,
      bpDiastolic: map['bp_diastolic'] as int?,
    );
  }
}

class BtempModel extends Signal {
  double? bodyTemp;
  double? minTemp;
  double? maxTemp;

  BtempModel({
    super.id,
    super.signalName,
    super.signalId,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    this.bodyTemp,
    this.minTemp,
    this.maxTemp,
  }) : super(signalType: SignalType.btemp);

  set tempData(double tempValue) {
    bodyTemp = tempValue;
  }

  double get tempData {
    return bodyTemp ?? 0.0;
  }

  factory BtempModel.fromMap(Map<String, dynamic> map) {
    return BtempModel(
      id: map[idColumn] as int?,
      userId: map[userIdColumn] as int,
      signalId: map[signalIdColumn] as int?,
      signalName: map[nameColumn] as String?,
      startTime: DateTime.parse(map[startTimeColumn] as String),
      stopTime: DateTime.parse(map[stopTimeColumn] as String),
      bodyTemp: map['body_temp'] as double?,
      minTemp: map['body_temp_min'] as double?,
      maxTemp: map['body_temp_max'] as double?,
    );
  }
}
