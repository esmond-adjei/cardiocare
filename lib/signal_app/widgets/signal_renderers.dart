import 'package:cardiocare/signal_app/model/signal_model.dart';
import 'package:flutter/material.dart';
import 'package:cardiocare/signal_app/charts/line_chart.dart';

// ========== ECG RENDERER RENDERER =========
class ECGRenderer extends StatelessWidget {
  final bool isActive;
  final EcgModel ecgSignal;

  const ECGRenderer({
    super.key,
    required this.isActive,
    required this.ecgSignal,
  });

//   @override
//   State<ECGRenderer> createState() => _ECGRendererState();
// }

// class _ECGRendererState extends State<ECGRenderer> {
  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return const Center(
        child: Text(
          'Start Recording Your ECG',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        ScrollableLineChart(
          dataList: ecgSignal.ecgList,
          height: 200,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: Icons.favorite,
                title: 'Heart Rate',
                value: "${ecgSignal.hbpm} BPM",
                color: Colors.red,
              ),
            ),
            Expanded(
              child: _buildInfoCard(
                icon: Icons.timeline,
                title: 'HRV',
                value: "${ecgSignal.hrv.toStringAsFixed(2)} ms",
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.2),
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12.0)),
                //Theme.of(context).textTheme.labelMedium),
                Text(value, style: const TextStyle(fontSize: 16)),
                //Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ========== BLOOD PRESSURE RENDERER =========
class BPRenderer extends StatelessWidget {
  final bool isActive;
  final BpModel bpSignal;

  const BPRenderer({
    super.key,
    required this.isActive,
    required this.bpSignal,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return const Center(
        child: Text(
          'Record Your BP',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final color =
        bpSignal.systolic > 120 ? Colors.red : bpSignal.signalType.color;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBloodPressureRow(
          'systolic',
          bpSignal.systolic,
          color,
        ),
        const SizedBox(height: 20),
        _buildBloodPressureRow(
          'diastolic',
          bpSignal.diastolic,
          color.withOpacity(0.6),
        ),
      ],
    );
  }

  Widget _buildBloodPressureRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'mmHg',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
          const SizedBox(width: 50),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 72.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ========== BODY TEMPERATURE RENDERER =========
class BtempRenderer extends StatelessWidget {
  final bool isActive;
  final BtempModel btempSignal;

  const BtempRenderer({
    super.key,
    required this.isActive,
    required this.btempSignal,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return const Center(
        child: Text(
          'Start Monitoring Your Body Temperature',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTemperatureMonitor(context),
          const SizedBox(height: 20),
          _buildMinMaxTemperatures(),
        ],
      ),
    );
  }

  Widget _buildTemperatureMonitor(BuildContext context) {
    return Container(
      height: 180.0,
      width: 180.0,
      decoration: BoxDecoration(
        color: Colors.amber.shade300,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.amber.shade100,
          width: 8,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Text(
          '${btempSignal.avgTemp.toStringAsFixed(1)} °C',
          style: TextStyle(
            fontSize: 36.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
      ),
    );
  }

  Widget _buildMinMaxTemperatures() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTemperatureContainer(
          color: Colors.blue.shade100,
          textColor: Colors.blue,
          labelText: 'lowest',
          valueText: '${btempSignal.minTemp.toStringAsFixed(1)} °C',
        ),
        _buildTemperatureContainer(
          color: Colors.red.shade100,
          textColor: Colors.red,
          labelText: 'highest',
          valueText: '${btempSignal.maxTemp.toStringAsFixed(1)} °C',
        ),
      ],
    );
  }

  Widget _buildTemperatureContainer({
    required Color color,
    required Color textColor,
    required String labelText,
    required String valueText,
  }) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: textColor,
          fontSize: 12.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(labelText),
            Text(
              valueText,
              style: const TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}
