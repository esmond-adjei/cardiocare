import 'package:flutter/material.dart';
import 'package:cardiocare/services/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum SignalType {
  ecg,
  bp,
  btemp;

  String get name {
    switch (this) {
      case SignalType.ecg:
        return 'ECG';
      case SignalType.bp:
        return 'BP';
      case SignalType.btemp:
        return 'BTEMP';
    }
  }

  String get description {
    switch (this) {
      case SignalType.ecg:
        return 'ECG';
      case SignalType.bp:
        return 'Blood Pressure';
      case SignalType.btemp:
        return 'Body Temperature';
    }
  }

  String get tableName {
    switch (this) {
      case SignalType.ecg:
        return ecgTable;
      case SignalType.bp:
        return bpTable;
      case SignalType.btemp:
        return btempTable;
    }
  }

  Color get color {
    switch (this) {
      case SignalType.ecg:
        return Colors.blue;
      case SignalType.bp:
        return Colors.purple;
      case SignalType.btemp:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  FaIcon get icon {
    switch (this) {
      case SignalType.ecg:
        return const FaIcon(FontAwesomeIcons.heartPulse);
      case SignalType.bp:
        return const FaIcon(FontAwesomeIcons.heart);
      case SignalType.btemp:
        return const FaIcon(FontAwesomeIcons.thermometer);
      default:
        return const FaIcon(FontAwesomeIcons.heart);
    }
  }
}
