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
      signalIdColumn: signalId,
      userIdColumn: userId,
      nameColumn: signalName,
      startTimeColumn: startTime.toIso8601String(),
      stopTimeColumn: stopTime.toIso8601String(),
      signalTypeColumn: signalType.name,
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
          signalId == other.signalId &&
          signalType == other.signalType;

  @override
  int get hashCode =>
      id.hashCode ^ userId.hashCode ^ signalId.hashCode ^ signalType.hashCode;
}

class EcgModel extends Signal {
  Uint8List? ecg;

  EcgModel({
    super.id,
    super.signalName,
    super.signalId,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    this.ecg,
  }) : super(signalType: SignalType.ecg);

  void setEcg(List<int> data) {
    ecg = Uint8List.fromList(data);
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['ecg'] = ecg;
    return map;
  }

  factory EcgModel.fromMap(Map<String, dynamic> map) {
    return EcgModel(
      id: map[idColumn] as int?,
      userId: map[userIdColumn] as int,
      signalName: map[nameColumn] as String?,
      signalId: map[signalIdColumn] as int?,
      startTime: DateTime.parse(map[startTimeColumn] as String),
      stopTime: DateTime.parse(map[stopTimeColumn] as String),
      ecg: map['ecg'] as Uint8List?,
    );
  }
}

class BpModel extends Signal {
  final int bpSystolic;
  final int bpDiastolic;

  BpModel({
    super.id,
    super.signalName,
    super.signalId,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    required this.bpSystolic,
    required this.bpDiastolic,
  }) : super(signalType: SignalType.bp);

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['bp_systolic'] = bpSystolic;
    map['bp_diastolic'] = bpDiastolic;
    return map;
  }

  factory BpModel.fromMap(Map<String, dynamic> map) {
    return BpModel(
      id: map[idColumn] as int?,
      userId: map[userIdColumn] as int,
      signalId: map[signalIdColumn] as int?,
      signalName: map[nameColumn] as String?,
      startTime: DateTime.parse(map[startTimeColumn] as String),
      stopTime: DateTime.parse(map[stopTimeColumn] as String),
      bpSystolic: map['bp_systolic'] as int,
      bpDiastolic: map['bp_diastolic'] as int,
    );
  }
}

class BtempModel extends Signal {
  final double bodyTemp;

  BtempModel({
    super.id,
    super.signalName,
    super.signalId,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    required this.bodyTemp,
  }) : super(signalType: SignalType.btemp);

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['body_temp'] = bodyTemp;
    return map;
  }

  factory BtempModel.fromMap(Map<String, dynamic> map) {
    return BtempModel(
      id: map[idColumn] as int?,
      userId: map[userIdColumn] as int,
      signalId: map[signalIdColumn] as int?,
      signalName: map[nameColumn] as String?,
      startTime: DateTime.parse(map[startTimeColumn] as String),
      stopTime: DateTime.parse(map[stopTimeColumn] as String),
      bodyTemp: map['body_temp'] as double,
    );
  }
}
