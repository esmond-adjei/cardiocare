import 'package:flutter/material.dart';
import 'package:xmonapp/widgets/line_chart.dart';

class ECGRenderer extends StatefulWidget {
  final bool isRecording;
  final String title;
  final List<int> ecgValues;

  const ECGRenderer({
    super.key,
    required this.isRecording,
    required this.title,
    required this.ecgValues,
  });

  @override
  State<ECGRenderer> createState() => _ECGRendererState();
}

class _ECGRendererState extends State<ECGRenderer> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isRecording) {
      return Center(
        child: Text(
          widget.title,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return ScrollableLineChart(ecgValues: widget.ecgValues);
  }
}

// ======== BLOOD PRESSURE RENDERER ========
class BPRenderer extends StatefulWidget {
  final bool isRecording;
  final String title;
  final Map<String, int> bpValues;

  const BPRenderer({
    super.key,
    required this.isRecording,
    required this.title,
    required this.bpValues,
  });

  @override
  State<BPRenderer> createState() => _BPRendererState();
}

class _BPRendererState extends State<BPRenderer> {
  late Color color;

  @override
  void initState() {
    super.initState();
    color = widget.bpValues['systolic']! > 120 ? Colors.red : Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRecording) {
      return Center(
        child: Text(
          widget.title,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildBloodPressureRow(
          'systolic',
          widget.bpValues['systolic']!,
          color,
        ),
        const SizedBox(height: 20),
        _buildBloodPressureRow(
          'diastolic',
          widget.bpValues['diastolic']!,
          color.withOpacity(0.6),
        ),
      ],
    );
  }

  Widget _buildBloodPressureRow(
    String label,
    int value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'mmHg',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
          const SizedBox(width: 50),
          Text(
            '$value',
            textAlign: TextAlign.right,
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

// ======== BODY TEMPERATURE RENDERER ========
class BtempRenderer extends StatefulWidget {
  final bool isRecording;
  final String title;
  final double btempValue;

  const BtempRenderer({
    super.key,
    required this.isRecording,
    required this.title,
    required this.btempValue,
  });

  @override
  State<BtempRenderer> createState() => _BtempRendererState();
}

class _BtempRendererState extends State<BtempRenderer> {
  late double minBtemp;
  late double maxBtemp;

  @override
  void initState() {
    super.initState();
    minBtemp = widget.btempValue;
    maxBtemp = widget.btempValue;
  }

  @override
  void didUpdateWidget(covariant BtempRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.btempValue != widget.btempValue) {
      updateMinMaxTemperatures(widget.btempValue);
    }
  }

  void updateMinMaxTemperatures(double newValue) {
    setState(() {
      if (newValue < minBtemp) {
        minBtemp = newValue;
      }
      if (newValue > maxBtemp) {
        maxBtemp = newValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRecording) {
      return Center(
        child: Text(
          widget.title,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // temperature monitor screen
          Container(
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
          ),
          const SizedBox(height: 20),
          // MIN MAX TEMPERATURE
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildContainer(
                color: Colors.blue.shade100,
                textColor: Colors.blue,
                labelText: 'lowest',
                valueText: '${minBtemp.toStringAsFixed(1)} °C',
              ),
              _buildContainer(
                color: Colors.red.shade100,
                textColor: Colors.red,
                labelText: 'highest',
                valueText: '${maxBtemp.toStringAsFixed(1)} °C',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContainer({
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
          overflow: TextOverflow.fade,
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
