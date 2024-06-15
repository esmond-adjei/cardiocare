import 'dart:async';
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

class BPGenerator {
  final int duration;
  late double systolic;
  late double disatolic;

  BPGenerator({
    this.duration = 100,
  });

  Stream<int> get ecgStream async* {
    final rand = Random(42);
    for (int i = 40; i < 140; i++) {
      yield rand.nextInt(140) + 40;
    }
  }
}
