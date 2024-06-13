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

    for (int i = 0; i < t.length; i++) {
      await Future.delayed(Duration(milliseconds: (1000 / fs).round()));
      final d = (ecg[i] * 1000).round(); // scale to int for simplicity
      // print(d);
      yield d;
    }
  }

  void dispose() {
    _controller.close();
  }
}
