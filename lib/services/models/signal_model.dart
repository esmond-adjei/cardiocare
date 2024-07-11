import 'dart:typed_data';
import 'package:cardiocare/utils/enums.dart';
import 'package:cardiocare/services/constants.dart';

abstract class Signal {
  final int? id;
  final int userId;
  String? signalName;
  final int? signalId;
  DateTime startTime;
  DateTime stopTime;
  final SignalType signalType;
  String? signalInfo;

  Signal({
    this.id,
    this.signalName,
    this.signalId,
    required this.userId,
    DateTime? startTime,
    DateTime? stopTime,
    required this.signalType,
  })  : startTime = startTime ?? DateTime.now(),
        stopTime = stopTime ?? DateTime.now();

  String get name =>
      signalName ??
      '${signalType.name} ${startTime.day}-${startTime.month}-${startTime.year} ${startTime.hour}:${startTime.minute}';

  set name(String newName) => signalName = newName;

  set starttime(DateTime time) => startTime = time;

  set stoptime(DateTime time) => stopTime = time;

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
  List<int> _ecgCache = [];
  Uint8List? ecg; // for saving to db
  double? _hrv;
  int? _hbpm;

  EcgModel({
    super.id,
    super.signalName,
    super.signalId,
    required super.userId,
    super.startTime,
    super.stopTime,
    this.ecg,
    double? hrv,
    int? hbpm,
  })  : _hrv = hrv,
        _hbpm = hbpm,
        super(signalType: SignalType.ecg);

  set ecgList(List<int> ecgList) => ecg = Uint8List.fromList(ecgList);
  List<int> get ecgList => ecg?.toList() ?? _ecgCache;

  void addEcgCache(int ecgValue) => _ecgCache.add(ecgValue); // before create
  void storeEcg() => ecg = Uint8List.fromList(_ecgCache); // before save

  set hrv(double hrvValue) => _hrv = hrvValue;
  double get hrv => _hrv ?? 0.0;

  set hbpm(int hbpmValue) => _hbpm = hbpmValue;
  int get hbpm => _hbpm ?? 0;

  set ecgData(Map<String, dynamic> ecgValues) {
    ecg = Uint8List.fromList(ecgValues['ecgList']);
    _hrv = ecgValues['hrv'];
    _hbpm = ecgValues['hbpm'];
  }

  Map<String, dynamic> get ecgData => {
        'ecgList': ecgList,
        'hbpm': hbpm,
        'hrv': hrv,
      };

  void clearEcg() {
    ecg = null;
    _ecgCache = [];
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
      hrv: map['hrv'] as double?,
      hbpm: map['hbpm'] as int?,
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
    super.startTime,
    super.stopTime,
    this.bpSystolic,
    this.bpDiastolic,
  }) : super(signalType: SignalType.bp);

  int get systolic => bpSystolic ?? 120;
  set systolic(int sysValue) => bpSystolic = sysValue;

  int get diastolic => bpDiastolic ?? 120;
  set diastolic(int diaValue) => bpDiastolic = diaValue;

  set bpData(List<int> bpValues) {
    bpSystolic = bpValues[0];
    bpDiastolic = bpValues[1];
  }

  List<int> get bpData => [bpSystolic ?? 0, bpDiastolic ?? 0];

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
  double? _minTemp;
  double? bodyTemp;
  double? _maxTemp;

  BtempModel({
    super.id,
    super.signalName,
    super.signalId,
    required super.userId,
    super.startTime,
    super.stopTime,
    this.bodyTemp,
    double? minTemp,
    double? maxTemp,
  })  : _minTemp = minTemp,
        _maxTemp = maxTemp,
        super(signalType: SignalType.btemp);

  set avgTemp(double tempValue) => bodyTemp = tempValue;
  double get avgTemp => bodyTemp ?? 0.0;

  set minTemp(double minTempValue) => _minTemp = minTempValue;
  double get minTemp => _minTemp ?? 0.0;

  set maxTemp(double maxTempValue) => _maxTemp = maxTempValue;
  double get maxTemp => _maxTemp ?? 0.0;

  set tempData(Map<String, double> tempValues) {
    _minTemp = tempValues['minTemp'];
    bodyTemp = tempValues['avgTemp'];
    _maxTemp = tempValues['maxTemp'];
  }

  Map<String, double> get tempData => {
        'minTemp': minTemp,
        'avgTemp': avgTemp,
        'maxTemp': maxTemp,
      };

  factory BtempModel.fromMap(Map<String, dynamic> map) {
    return BtempModel(
      id: map[idColumn] as int?,
      userId: map[userIdColumn] as int,
      signalId: map[signalIdColumn] as int?,
      signalName: map[nameColumn] as String?,
      startTime: DateTime.parse(map[startTimeColumn] as String),
      stopTime: DateTime.parse(map[stopTimeColumn] as String),
      minTemp: map['body_temp_min'] as double?,
      bodyTemp: map['body_temp'] as double?,
      maxTemp: map['body_temp_max'] as double?,
    );
  }
}
