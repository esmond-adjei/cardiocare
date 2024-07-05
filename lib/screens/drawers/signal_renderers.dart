import 'package:flutter/material.dart';
import 'package:cardiocare/widgets/line_chart.dart';

// ========== ECG RENDERER RENDERER =========
class ECGRenderer extends StatefulWidget {
  final bool isActive;
  final List<int> ecgValues;

  const ECGRenderer({
    super.key,
    required this.isActive,
    required this.ecgValues,
  });

  @override
  State<ECGRenderer> createState() => _ECGRendererState();
}

class _ECGRendererState extends State<ECGRenderer> {
  // String _status = 'calibrating...';
  int _heartRate = 72;
  double _hrv = 42.0;

  @override
  void initState() {
    super.initState();
    _updateMeasurements();
  }

  void _updateMeasurements() {
    // TODO: Implement real calculations
    setState(() {
      _heartRate = _calcHR(widget.ecgValues);
      _hrv = _calcHRV(widget.ecgValues).toDouble();
      // _status = _determineStatus();
    });
  }

  int _calcHR(List<int> ecgData) {
    // TODO: Calculate heart rate from ecg data
    return 72;
  }

  int _calcHRV(List<int> ecgData) {
    // TODO: Calculate heart rate variability from ecg data
    return 42;
  }

  String _determineStatus() {
    // TODO: Determine status based on HR and HRV
    return 'Normal';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
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
          dataList: widget.ecgValues,
          height: 200,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: Icons.favorite,
                title: 'Heart Rate',
                value: '$_heartRate BPM',
                color: Colors.red,
              ),
            ),
            Expanded(
              child: _buildInfoCard(
                icon: Icons.timeline,
                title: 'HRV',
                value: '${_hrv.toStringAsFixed(1)} ms',
                color: Colors.blue,
              ),
            ),
          ],
        ),
        // if (!widget.isActive)
        //   _buildInfoCard(
        //     icon: Icons.warning,
        //     title: 'Status',
        //     value: _status,
        //     color: Colors.orange,
        //   ),
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
                Text(title, style: Theme.of(context).textTheme.labelMedium),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
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
  final List<int> bpValues;

  const BPRenderer({
    super.key,
    required this.isActive,
    required this.bpValues,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return const Center(
        child: Text(
          'Start Monitoring Your BP',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final color = bpValues[0] > 120 ? Colors.red : Colors.purple;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBloodPressureRow(
          'systolic',
          bpValues[0],
          color,
        ),
        const SizedBox(height: 20),
        _buildBloodPressureRow(
          'diastolic',
          bpValues[1],
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
class BtempRenderer extends StatefulWidget {
  final bool isActive;
  final double btempValue;

  const BtempRenderer({
    super.key,
    required this.isActive,
    required this.btempValue,
  });

  @override
  State<BtempRenderer> createState() => _BtempRendererState();
}

class _BtempRendererState extends State<BtempRenderer> {
  double minBtemp = 100.0;
  double maxBtemp = 0.0;

  @override
  void initState() {
    super.initState();
    _updateMinMaxTemperatures(widget.btempValue);
  }

  @override
  void didUpdateWidget(BtempRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.btempValue != widget.btempValue) {
      _updateMinMaxTemperatures(widget.btempValue);
    }
  }

  void _updateMinMaxTemperatures(double newValue) {
    setState(() {
      minBtemp = minBtemp.isNaN || newValue < minBtemp ? newValue : minBtemp;
      maxBtemp = maxBtemp.isNaN || newValue > maxBtemp ? newValue : maxBtemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
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
          _buildTemperatureMonitor(),
          const SizedBox(height: 20),
          _buildMinMaxTemperatures(),
        ],
      ),
    );
  }

  Widget _buildTemperatureMonitor() {
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
          '${widget.btempValue.toStringAsFixed(1)} °C',
          style: const TextStyle(
            fontSize: 36.0,
            fontWeight: FontWeight.bold,
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
          valueText: '${minBtemp.toStringAsFixed(1)} °C',
        ),
        _buildTemperatureContainer(
          color: Colors.red.shade100,
          textColor: Colors.red,
          labelText: 'highest',
          valueText: '${maxBtemp.toStringAsFixed(1)} °C',
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
