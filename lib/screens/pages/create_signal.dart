import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:xmonapp/services/enums.dart';
import 'package:xmonapp/services/models/db_helper.dart';
import 'package:xmonapp/services/models/db_model.dart';

class AddSignalScreen extends StatefulWidget {
  final DataType dataType;

  const AddSignalScreen({super.key, required this.dataType});

  @override
  State<AddSignalScreen> createState() => _AddSignalScreenState();
}

class _AddSignalScreenState extends State<AddSignalScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbhelper = DatabaseHelper();

  int? userId;
  DateTime? startTime;
  DateTime? stopTime;
  Uint8List? ecgData;
  int? bpSystolic;
  int? bpDiastolic;
  double? bodyTemp;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      switch (widget.dataType) {
        case DataType.ECG:
          final ecgModel = EcgModel(
            userId: userId!,
            startTime: startTime!,
            stopTime: stopTime!,
            ecg: ecgData!,
          );
          _dbhelper.createEcgData(ecgModel);
          break;
        case DataType.BloodPressure:
          final bpModel = BpModel(
            userId: userId!,
            startTime: startTime!,
            stopTime: stopTime!,
            bpSystolic: bpSystolic!,
            bpDiastolic: bpDiastolic!,
          );
          _dbhelper.createBpData(bpModel);
          break;
        case DataType.BodyTemperature:
          final btempModel = BtempModel(
            userId: userId!,
            startTime: startTime!,
            stopTime: stopTime!,
            bodyTemp: bodyTemp!,
          );
          _dbhelper.createBtempData(btempModel);
          break;
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.dataType.toString().split('.').last} Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: _buildFormFields(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitForm,
        child: const Icon(Icons.save),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    List<Widget> fields = [
      TextFormField(
        decoration: const InputDecoration(labelText: 'User ID'),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter User ID';
          }
          return null;
        },
        onSaved: (value) {
          userId = int.parse(value!);
        },
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Start Time'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter Start Time';
          }
          return null;
        },
        onSaved: (value) {
          startTime = DateTime.parse(value!);
        },
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Stop Time'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter Stop Time';
          }
          return null;
        },
        onSaved: (value) {
          stopTime = DateTime.parse(value!);
        },
      ),
    ];

    switch (widget.dataType) {
      case DataType.ECG:
        fields.add(
          TextFormField(
            decoration: const InputDecoration(labelText: 'ECG Data'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter ECG Data';
              }
              return null;
            },
            onSaved: (value) {
              ecgData = Uint8List.fromList(value!.codeUnits);
            },
          ),
        );
        break;
      case DataType.BloodPressure:
        fields.addAll([
          TextFormField(
            decoration: const InputDecoration(labelText: 'Systolic'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Systolic';
              }
              return null;
            },
            onSaved: (value) {
              bpSystolic = int.parse(value!);
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Diastolic'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Diastolic';
              }
              return null;
            },
            onSaved: (value) {
              bpDiastolic = int.parse(value!);
            },
          ),
        ]);
        break;
      case DataType.BodyTemperature:
        fields.add(
          TextFormField(
            decoration: const InputDecoration(labelText: 'Body Temperature'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Body Temperature';
              }
              return null;
            },
            onSaved: (value) {
              bodyTemp = double.parse(value!);
            },
          ),
        );
        break;
    }

    return fields;
  }
}
