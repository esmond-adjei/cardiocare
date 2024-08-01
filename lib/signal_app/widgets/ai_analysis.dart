import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cardiocare/signal_app/model/signal_enums.dart';

class AIAnalysis extends StatefulWidget {
  final dynamic signal;

  const AIAnalysis({super.key, required this.signal});

  @override
  State<AIAnalysis> createState() => _AIAnalysisState();
}

class _AIAnalysisState extends State<AIAnalysis> {
  String? _analysisResult;
  bool _isLoading = false;

  Future<void> _analyzeSignal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare the signal data
      final signalData = [
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
        0.890123,
        0.901234,
        0.012345,
        0.123456,
        0.234567,
        0.345678,
        0.456789,
        0.567890,
        0.678901,
        0.789012,
      ];

      // widget.signal.ecg;

      // Make API call to the generative AI service
      final response = await http.post(
        Uri.parse('http://192.168.53.178:8000/api/classify/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(signalData),
      );

      dev.log("response: ${response.body}");
      final result = json.decode(response.body);

      dev.log("result: ${result['classification_result'] is Map}");
      setState(() {
        _analysisResult = "${result['classification_result']}";
      });
    } catch (e) {
      setState(() {
        _analysisResult = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.signal.signalType != SignalType.ecg) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _analyzeSignal,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.psychology),
            label: Text(_isLoading ? 'Analyzing...' : 'Analyze with AI'),
          ),
        ),
        if (_analysisResult != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Card(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Analysis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_analysisResult!),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
