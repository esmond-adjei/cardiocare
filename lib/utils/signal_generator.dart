import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

class SignalGenerator {
  final int durationSeconds;
  final int samplingRate;

  SignalGenerator({
    this.durationSeconds = 60 * 60, // one minute
    this.samplingRate = 2,
  });

  Stream<Map<String, dynamic>> generateECG() async* {
    const int fs = 500;
    const double baseHeartRate = 60.0;
    final random = Random();
    List<double> rrIntervals = [];
    List<int> heartRates = [];

    double time = 0;
    while (time < durationSeconds) {
      double heartRate =
          baseHeartRate + random.nextDouble() * 20 - 10; // between 50-70 bpm
      double rrInterval = 60 / heartRate;
      rrIntervals.add(rrInterval);
      heartRates.add(heartRate.round());
      time += rrInterval;
    }

    List<double> t = [];
    List<double> ecg = [];

    for (int i = 0; i < rrIntervals.length; i++) {
      double beatTime = t.isEmpty ? 0 : t.last;
      List<double> beatT = List.generate(
          (rrIntervals[i] * fs).round(), (j) => beatTime + j / fs);
      t.addAll(beatT);

      for (double ti in beatT) {
        double pWave = exp(-pow((ti - beatTime - 0.1), 2) / (2 * pow(0.01, 2)));
        double qWave =
            -exp(-pow((ti - beatTime - 0.16), 2) / (2 * pow(0.02, 2)));
        double rWave =
            2 * exp(-pow((ti - beatTime - 0.2), 2) / (2 * pow(0.02, 2)));
        double sWave =
            -exp(-pow((ti - beatTime - 0.26), 2) / (2 * pow(0.02, 2)));
        double tWave =
            0.5 * exp(-pow((ti - beatTime - 0.4), 2) / (2 * pow(0.04, 2)));

        ecg.add(pWave + qWave + rWave + sWave + tWave);
      }
    }

    // Normalize the ecg values to be within 0-255 range
    double minValue = ecg.reduce(min);
    double maxValue = ecg.reduce(max);
    double range = maxValue - minValue;

    // Calculate HRV (SDNN - Standard Deviation of NN intervals)
    double meanRR = rrIntervals.reduce((a, b) => a + b) / rrIntervals.length;
    num sumSquaredDiff =
        rrIntervals.map((rr) => pow(rr - meanRR, 2)).reduce((a, b) => a + b);
    double sdnn = sqrt(sumSquaredDiff / (rrIntervals.length - 1));

    int currentBeatIndex = 0;
    for (int i = 0; i < t.length; i++) {
      await Future.delayed(Duration(milliseconds: (500 / fs).round()));
      if (i / fs >=
          rrIntervals.take(currentBeatIndex + 1).reduce((a, b) => a + b)) {
        currentBeatIndex++;
      }
      dev.log("hbpm: ${heartRates[currentBeatIndex]}, hrv: $sdnn");
      yield {
        'ecg': ((ecg[i] - minValue) / range * 255).round(),
        'hbpm': heartRates[currentBeatIndex],
        'hrv': sdnn,
      };
    }
  }

  Stream<List<int>> generateBP() async* {
    const int bpNoiseAmplitude = 5;
    final numSamples = durationSeconds * samplingRate;
    var systolic = 120;
    var diastolic = 80;
    final random = Random();

    for (int i = 0; i < numSamples; i++) {
      systolic += random.nextInt(2 * bpNoiseAmplitude + 1) - bpNoiseAmplitude;
      diastolic += random.nextInt(2 * bpNoiseAmplitude + 1) - bpNoiseAmplitude;

      systolic = systolic.clamp(90, 180);
      diastolic = diastolic.clamp(60, 110);

      dev.log('Systolic: $systolic, Diastolic: $diastolic');

      yield [systolic, diastolic];
      await Future.delayed(
          Duration(milliseconds: (1000 / samplingRate).round()));
    }
  }

  Stream<Map<String, double>> generateBtemp() async* {
    const double tempNoiseAmplitude = 0.5;
    final numSamples = durationSeconds * samplingRate;
    var temp = 37.0;
    final random = Random();
    double minTemp = temp;
    double maxTemp = temp;
    double sumTemp = 0;

    for (int i = 0; i < numSamples; i++) {
      temp += random.nextDouble() * 2 * tempNoiseAmplitude - tempNoiseAmplitude;
      temp = temp.clamp(35.0, 40.0);

      minTemp = min(minTemp, temp);
      maxTemp = max(maxTemp, temp);
      sumTemp += temp;

      dev.log('Temperature: $temp');

      yield {
        // 'current': temp,
        'minTemp': minTemp,
        'maxTemp': maxTemp,
        'avgTemp': sumTemp / (i + 1),
      };
      await Future.delayed(
          Duration(milliseconds: (1000 / samplingRate).round()));
    }
  }
}
