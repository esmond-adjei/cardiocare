import 'package:flutter/material.dart';
import 'package:xmonapp/widgets/list_container.dart';
import 'package:xmonapp/services/dummy_data.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'ECG'),
              Tab(text: 'Blood Pressure'),
              Tab(text: 'Body Temperature'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DataTab(dataType: DataType.ECG),
            DataTab(dataType: DataType.BloodPressure),
            DataTab(dataType: DataType.BodyTemperature),
          ],
        ),
      ),
    );
  }
}

// ignore: constant_identifier_names
enum DataType { ECG, BloodPressure, BodyTemperature }

class DataTab extends StatelessWidget {
  final DataType dataType;

  const DataTab({super.key, required this.dataType});

  List<Map<String, String>> _getData() {
    switch (dataType) {
      case DataType.ECG:
        return getECGData();
      case DataType.BloodPressure:
        return getBloodPressureData();
      case DataType.BodyTemperature:
        return getBodyTemperatureData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        Container(
          height: 180,
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        ListContainer(
          listHeading: '${dataType.toString().split('.').last} Data',
          listData: _getData(),
        ),
      ]),
    );
  }
}
