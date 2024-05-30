final List<Map<String, String>> _ecgData = [
  {
    'name': 'ECG 015',
    'startTime': '2024-10-01 13:00:00',
    'endTime': '2024-10-02 13:00:01',
  },
  {
    'name': 'ECG 014',
    'startTime': '2024-10-01 13:00:00',
    'endTime': '2024-10-02 13:00:01',
  },
  {
    'name': 'ECG 013',
    'startTime': '2024-10-01 13:00:00',
    'endTime': '2024-10-02 13:00:01',
  },
  {
    'name': 'ECG 012',
    'startTime': '2024-10-01 13:00:00',
    'endTime': '2024-10-02 13:00:01',
  },
  {
    'name': 'ECG 011',
    'startTime': '2024-10-01 13:00:00',
    'endTime': '2024-10-02 13:00:01',
  },
  {
    'name': 'ECG 010',
    'startTime': '2024-10-01 13:00:00',
    'endTime': '2024-10-02 13:00:01',
  },
  {
    'name': 'ECG 009',
    'startTime': '2024-10-01 12:55:00',
    'endTime': '2024-10-02 12:55:30',
  },
  {
    'name': 'ECG 008',
    'startTime': '2024-10-01 12:50:00',
    'endTime': '2024-10-02 12:50:30',
  },
  {
    'name': 'ECG 007',
    'startTime': '2024-10-01 12:45:00',
    'endTime': '2024-10-02 12:45:30',
  },
  {
    'name': 'ECG 006',
    'startTime': '2024-10-01 12:55:00',
    'endTime': '2024-10-02 12:55:30',
  },
  {
    'name': 'ECG 005',
    'startTime': '2024-10-01 12:50:00',
    'endTime': '2024-10-02 12:50:30',
  },
  {
    'name': 'ECG 004',
    'startTime': '2024-10-01 12:45:00',
    'endTime': '2024-10-02 12:45:30',
  },
  {
    'name': 'ECG 003',
    'startTime': '2021-10-01 12:30:00',
    'endTime': '2021-10-01 12:40:44',
  },
  {
    'name': 'ECG 002',
    'startTime': '2021-10-01 12:15:12',
    'endTime': '2021-10-01 12:25:00',
  },
  {
    'name': 'ECG 001',
    'startTime': '2021-10-01 12:00:00',
    'endTime': '2021-10-01 12:10:00',
  },
];

final List<Map<String, String>> _bloodPressureData = [
  {
    'name': 'Blood Pressure 001',
    'startTime': '2024-10-01 13:00:00',
    'endTime': '2024-10-01 13:30:00',
    'systolic': '120',
    'diastolic': '80',
  },
  {
    'name': 'Blood Pressure 002',
    'startTime': '2024-10-01 12:55:00',
    'endTime': '2024-10-01 13:25:00',
    'systolic': '118',
    'diastolic': '78',
  },
  {
    'name': 'Blood Pressure 003',
    'startTime': '2024-10-01 12:50:00',
    'endTime': '2024-10-01 13:20:00',
    'systolic': '122',
    'diastolic': '82',
  },
];

final List<Map<String, String>> _bodyTemperatureData = [
  {
    'name': 'Body Temperature 001',
    'startTime': '2024-10-01 13:00:00',
    'endTime': '2024-10-01 13:30:00',
    'temperature': '37.2',
  },
  {
    'name': 'Body Temperature 002',
    'startTime': '2024-10-01 12:55:00',
    'endTime': '2024-10-01 13:25:00',
    'temperature': '37.0',
  },
  {
    'name': 'Body Temperature 003',
    'startTime': '2024-10-01 12:50:00',
    'endTime': '2024-10-01 13:20:00',
    'temperature': '37.5',
  },
];

List<Map<String, String>> getECGData() {
  return List<Map<String, String>>.from(_ecgData);
}

List<Map<String, String>> getBloodPressureData() {
  return List<Map<String, String>>.from(_bloodPressureData);
}

List<Map<String, String>> getBodyTemperatureData() {
  return List<Map<String, String>>.from(_bodyTemperatureData);
}
