import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Metric {
  final String text;
  final String value;
  final String unit;

  Metric({required this.text, required this.value, required this.unit});

  Map<String, dynamic> toJson() => {
        'text': text,
        'value': value,
        'unit': unit,
      };

  factory Metric.fromJson(Map<String, dynamic> json) => Metric(
        text: json['text'] as String? ?? '',
        value: json['value'] as String? ?? '',
        unit: json['unit'] as String? ?? '',
      );
}

class SharedPreferencesManager extends ChangeNotifier {
  SharedPreferencesManager._privateConstructor();
  static final SharedPreferencesManager instance =
      SharedPreferencesManager._privateConstructor();

  static const String _metricsKey = 'all_metrics';
  static const String _stressMojiKey = 'selected_stress_level';
  static const String _appSettingsKey = 'app_settings';

  List<Metric> _metrics = [];
  String? _stressMoji;
  Map<String, dynamic>? _appSettings;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      await _loadAllData();
      _isInitialized = true;
    }
  }

  Future<void> _loadAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load metrics
      String? metricsJson = prefs.getString(_metricsKey);
      if (metricsJson != null) {
        dynamic decodedData = json.decode(metricsJson);
        if (decodedData is List) {
          _metrics = decodedData
              .map((data) => Metric.fromJson(Map<String, dynamic>.from(data)))
              .toList();
        } else if (decodedData is Map) {
          // Handle the case where it's stored as a single object
          _metrics = [Metric.fromJson(Map<String, dynamic>.from(decodedData))];
        }
      }

      // Load stress moji
      _stressMoji = prefs.getString(_stressMojiKey);

      // Load app settings
      String? settingsString = prefs.getString(_appSettingsKey);
      if (settingsString != null) {
        dynamic decodedSettings = json.decode(settingsString);
        _appSettings = Map<String, dynamic>.from(decodedSettings);
      }
    } catch (e) {
      dev.log('Error loading data: $e');
      // Handle the error appropriately, maybe set default values
      _metrics = [];
      _stressMoji = null;
      _appSettings = null;
    }

    notifyListeners();
  }

  Future<void> saveAllData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save metrics
    String metricsJson = json.encode(_metrics.map((m) => m.toJson()).toList());
    await prefs.setString(_metricsKey, metricsJson);

    // Save stress moji
    if (_stressMoji != null) {
      await prefs.setString(_stressMojiKey, _stressMoji!);
    } else {
      await prefs.remove(_stressMojiKey);
    }

    // Save app settings
    if (_appSettings != null) {
      await prefs.setString(_appSettingsKey, json.encode(_appSettings));
    } else {
      await prefs.remove(_appSettingsKey);
    }
  }

  List<Metric> getAllMetrics() => _metrics;

  void setMetric(Metric metric) {
    final index = _metrics.indexWhere((m) => m.text == metric.text);
    if (index != -1) {
      _metrics[index] = metric;
    } else if (metric.text != '') {
      _metrics.add(metric);
    }
    notifyListeners();
    saveAllData();
  }

  String? getStressMoji() => _stressMoji;

  void setStressMoji(String animationPath) {
    _stressMoji = animationPath;
    notifyListeners();
    saveAllData();
  }

  Map<String, dynamic>? get appSettings => _appSettings;

  void saveAppSettings(Map<String, dynamic> settings) {
    _appSettings = settings;
    notifyListeners();
    saveAllData();
  }

  Future<void> clearAll() async {
    _metrics.clear();
    _stressMoji = null;
    _appSettings = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
