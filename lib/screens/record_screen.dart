import 'package:flutter/material.dart';
import 'package:xmonapp/layout/list_container.dart';
// import 'package:xmonapp/widgets/ecg_tile.dart';

final List<Map<String, String>> _ecgData = [
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

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(10),
        child: ListContainer(listHeading: 'ECG Data', listData: _ecgData),
      ),
    );
  }
}
