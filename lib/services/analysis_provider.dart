import 'package:cardiocare/services/preferences.dart';
import 'package:cardiocare/signal_app/model/signal_model.dart';

class AnalysisProvider {
  AnalysisProvider(this.dataResource, this.prefsManager);

  final List<Signal> dataResource;
  final SharedPreferencesManager prefsManager;

  List<Signal> get data => dataResource.reversed.toList();
  int get dataLength => dataResource.length;

  // ------------------ ecg ---------------------------
  double getAverageHeartRate() {
    if (dataResource.isEmpty) return 0;
    return dataResource.fold(0, (sum, e) => sum + (e as EcgModel).hbpm) /
        dataResource.length;
  }

  void updateHeartRateMetric() {
    final avgHR = getAverageHeartRate();
    prefsManager.setMetric(Metric(
      text: 'heart rate',
      value: avgHR.toStringAsFixed(1),
      unit: 'bpm',
    ));
  }

  // ------------------ blood pressure ------------------
  List<int> getAverageBP() {
    if (dataResource.isEmpty) return [0, 0];

    final avgSys =
        dataResource.fold(0, (sum, e) => sum + (e as BpModel).systolic) ~/
            dataResource.length;
    final avgDia =
        dataResource.fold(0, (sum, e) => sum + (e as BpModel).diastolic) ~/
            dataResource.length;

    return [avgSys, avgDia];
  }

  void updateBloodPressureMetric() {
    final avgBP = getAverageBP();
    prefsManager.setMetric(Metric(
      text: 'blood pressure',
      value: '${avgBP[0]}/${avgBP[1]}',
      unit: 'mmHg',
    ));
  }

  // ------------------ temperature ------------------
  double getMaxTemperature() {
    if (dataResource.isEmpty) return 0;
    return dataResource
        .map((e) => (e as BtempModel).avgTemp)
        .reduce((a, b) => a > b ? a : b);
  }

  void updateTemperatureMetric() {
    final maxTemp = getMaxTemperature();
    prefsManager.setMetric(Metric(
      text: 'body temp.',
      value: maxTemp.toStringAsFixed(1),
      unit: '°C',
    ));
  }
}
