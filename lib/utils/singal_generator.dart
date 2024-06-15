import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

class ECGGenerator {
  final int duration;
  final int fs;
  final double heartRate;
  final double rrInterval;
  final int numBeats;
  final StreamController<int> _controller = StreamController<int>();

  ECGGenerator({this.duration = 10, this.fs = 500, this.heartRate = 60})
      : rrInterval = 60 / heartRate,
        numBeats = (duration / (60 / heartRate)).floor();

  Stream<int> get ecgStream async* {
    List<double> t = List.generate(duration * fs, (i) => i / fs);
    List<double> ecg = List.filled(t.length, 0.0);

    for (int beat = 0; beat < numBeats; beat++) {
      double beatTime = beat * rrInterval;
      for (int i = 0; i < t.length; i++) {
        double pWave =
            exp(-pow((t[i] - beatTime - 0.1), 2) / (2 * pow(0.01, 2)));
        double qWave =
            -exp(-pow((t[i] - beatTime - 0.16), 2) / (2 * pow(0.02, 2)));
        double rWave =
            2 * exp(-pow((t[i] - beatTime - 0.2), 2) / (2 * pow(0.02, 2)));
        double sWave =
            -exp(-pow((t[i] - beatTime - 0.26), 2) / (2 * pow(0.02, 2)));
        double tWave =
            0.5 * exp(-pow((t[i] - beatTime - 0.4), 2) / (2 * pow(0.04, 2)));

        ecg[i] += pWave + qWave + rWave + sWave + tWave;
      }
    }

    // Normalize the ecg values to be within 0-255 range
    double minValue = ecg.reduce(min);
    double maxValue = ecg.reduce(max);
    double range = maxValue - minValue;

    for (int i = 0; i < t.length; i++) {
      await Future.delayed(Duration(milliseconds: (1000 / fs).round()));
      yield ((ecg[i] - minValue) / range * 255).round();
    }
  }

  void dispose() {
    _controller.close();
  }
}

// ------------------------------------------------
class SignalGenerator {
  final int durationSeconds;
  final int samplingRate;

  SignalGenerator({
    this.durationSeconds = 10,
    this.samplingRate = 2,
  });

  Stream<int> generateECG() async* {
    const int fs = 500;
    const double heartRate = 60.0;
    final numBeats = (durationSeconds / (60 / heartRate)).floor();
    const rrInterval = 60 / heartRate;
    List<double> t = List.generate(durationSeconds * fs, (i) => i / fs);
    List<double> ecg = List.filled(t.length, 0.0);

    for (int beat = 0; beat < numBeats; beat++) {
      double beatTime = beat * rrInterval;
      for (int i = 0; i < t.length; i++) {
        double pWave =
            exp(-pow((t[i] - beatTime - 0.1), 2) / (2 * pow(0.01, 2)));
        double qWave =
            -exp(-pow((t[i] - beatTime - 0.16), 2) / (2 * pow(0.02, 2)));
        double rWave =
            2 * exp(-pow((t[i] - beatTime - 0.2), 2) / (2 * pow(0.02, 2)));
        double sWave =
            -exp(-pow((t[i] - beatTime - 0.26), 2) / (2 * pow(0.02, 2)));
        double tWave =
            0.5 * exp(-pow((t[i] - beatTime - 0.4), 2) / (2 * pow(0.04, 2)));

        ecg[i] += pWave + qWave + rWave + sWave + tWave;
      }
    }

    // Normalize the ecg values to be within 0-255 range
    double minValue = ecg.reduce(min);
    double maxValue = ecg.reduce(max);
    double range = maxValue - minValue;

    for (int i = 0; i < t.length; i++) {
      await Future.delayed(Duration(milliseconds: (1000 / fs).round()));
      yield ((ecg[i] - minValue) / range * 255).round();
    }
  }

  Stream<Map<String, int>> generateBP() async* {
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

      yield {'systolic': systolic, 'diastolic': diastolic};
      await Future.delayed(
          Duration(milliseconds: (1000 / samplingRate).round()));
    }
  }

  Stream<double> generateBtemp() async* {
    const double tempNoiseAmplitude = 0.5;
    final numSamples = durationSeconds * samplingRate;
    var temp = 37.0;
    final random = Random();

    for (int i = 0; i < numSamples; i++) {
      temp += random.nextDouble() * 2 * tempNoiseAmplitude - tempNoiseAmplitude;
      temp = temp.clamp(35.0, 40.0);

      dev.log('Temperature: $temp');

      yield temp;
      await Future.delayed(
          Duration(milliseconds: (1000 / samplingRate).round()));
    }
  }
}
