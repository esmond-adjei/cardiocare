import 'package:cardiocare/signal_app/model/signal_enums.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cardiocare/signal_app/model/signal_model.dart';

class AIAnalysis extends StatefulWidget {
  final Signal signal;

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
      final signalData = widget.signal.toMap();

      // Make API call to the generative AI service
      final response = await http.post(
        Uri.parse('YOUR_GENERATIVE_AI_API_ENDPOINT'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'signal_type': widget.signal.signalType.toString(),
          'signal_data': signalData,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          _analysisResult = result['analysis'];
        });
      } else {
        throw Exception('Failed to analyze signal');
      }
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
