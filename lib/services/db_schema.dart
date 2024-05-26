import 'dart:typed_data';

class EcgData {
  final int? id;
  final int userId;
  final List<int> ecg;
  final DateTime timestamp;

  EcgData(
      {this.id,
      required this.userId,
      required this.ecg,
      required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'ecg': Uint8List.fromList(ecg),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory EcgData.fromMap(Map<String, dynamic> map) {
    return EcgData(
      id: map['id'],
      userId: map['user_id'],
      ecg: List<int>.from(map['ecg']),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class BpData {
  final int? id;
  final int userId;
  final int bpSystolic;
  final int bpDiastolic;
  final DateTime timestamp;

  BpData(
      {this.id,
      required this.userId,
      required this.bpSystolic,
      required this.bpDiastolic,
      required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'bp_systolic': bpSystolic,
      'bp_diastolic': bpDiastolic,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory BpData.fromMap(Map<String, dynamic> map) {
    return BpData(
      id: map['id'],
      userId: map['user_id'],
      bpSystolic: map['bp_systolic'],
      bpDiastolic: map['bp_diastolic'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class TemperatureData {
  final int? id;
  final int userId;
  final double bodyTemp;
  final DateTime timestamp;

  TemperatureData(
      {this.id,
      required this.userId,
      required this.bodyTemp,
      required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'body_temp': bodyTemp,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TemperatureData.fromMap(Map<String, dynamic> map) {
    return TemperatureData(
      id: map['id'],
      userId: map['user_id'],
      bodyTemp: map['body_temp'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
