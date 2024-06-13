import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xmonapp/utils/ecg_generator.dart';
import 'package:xmonapp/widgets/timer.dart';

class SingleMonitorLayout extends StatefulWidget {
  const SingleMonitorLayout({super.key});

  @override
  State<SingleMonitorLayout> createState() => _SingleMonitorLayoutState();
}

class _SingleMonitorLayoutState extends State<SingleMonitorLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isRecording = false;
  bool isPaused = false;
  final List<int> _ecgValues = [];
  StreamSubscription<int>? _ecgSubscription;
  final ECGGenerator _ecgGenerator = ECGGenerator();
  final ScrollController _scrollController = ScrollController();
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, initialIndex: 0, vsync: this);
  }

  @override
  void dispose() {
    if (isRecording) {
      _ecgSubscription?.cancel();
    }
    _scrollController.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      isRecording = true;
      isPaused = false;
      _stopwatch.start();
    });
    _ecgSubscription = _ecgGenerator.ecgStream.listen((value) {
      setState(() {
        _ecgValues.add(value);
        _scrollToEnd();
      });
    });
  }

  void _stopRecording() {
    setState(() {
      isRecording = false;
      isPaused = false;
      _ecgValues.clear();
      _stopwatch.reset();
    });
    _ecgSubscription?.cancel();
  }

  void _pauseRecording() {
    setState(() {
      isPaused = true;
      _stopwatch.stop();
    });
    _ecgSubscription?.pause();
  }

  void _resumeRecording() {
    setState(() {
      isPaused = false;
      _stopwatch.start();
    });
    _ecgSubscription?.resume();
  }

  void _saveRecording() {
    _pauseRecording();
    _showSaveDialog();
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _showSaveDialog() {
    TextEditingController textFieldController = TextEditingController();
    textFieldController.text = 'ECG ${DateTime.now().millisecondsSinceEpoch}';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Recording'),
          content: TextField(
            controller: textFieldController,
            decoration: const InputDecoration(hintText: "Enter recording name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String recordName = textFieldController.text;
                // Here you would save the recording with the given name

                Navigator.pop(context);
                // You can add logic here to actually save the data to the database or any other storage
                print("Recording saved as: $recordName");
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Recorder', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('List', style: TextStyle(color: Colors.black)),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: TimerWidget(
              isRecording: isRecording,
              isPaused: isPaused,
              stopwatch: _stopwatch,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RecordingScreen(
                  isRecording: isRecording,
                  ecgValues: _ecgValues,
                  title: 'ECG Graph Placeholder',
                  scrollController: _scrollController,
                ),
                RecordingScreen(
                  isRecording: false,
                  ecgValues: _ecgValues,
                  title: 'Blood Pressure Graph Placeholder',
                  scrollController: _scrollController,
                ),
                RecordingScreen(
                  isRecording: false,
                  ecgValues: _ecgValues,
                  title: 'Body Temperature Graph Placeholder',
                  scrollController: _scrollController,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
            child: TabBar(
              indicator: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(40),
              ),
              dividerHeight: 0,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              controller: _tabController,
              tabs: [
                _buildTab('ECG'),
                _buildTab('BP'),
                _buildTab('BTemp'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            height: 100.0,
            child: !isRecording
                ? ElevatedButton(
                    onPressed: _startRecording,
                    style: ElevatedButton.styleFrom(
                      elevation: 4,
                      shape: CircleBorder(
                        side: BorderSide(color: Colors.red.shade200, width: 4),
                      ),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(
                      Icons.record_voice_over_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _stopRecording,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                        ),
                        child: const Text(
                          'discard',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 16),
                      isPaused
                          ? ElevatedButton(
                              onPressed: _resumeRecording,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amberAccent,
                              ),
                              child: const Text(
                                'resume',
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _pauseRecording,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amberAccent,
                              ),
                              child: const Text(
                                'pause',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _saveRecording,
                        child: const Text('save'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Tab _buildTab(String text) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text(text),
      ),
    );
  }
}

class RecordingScreen extends StatelessWidget {
  final bool isRecording;
  final String title;
  final List<int> ecgValues;
  final ScrollController scrollController;

  const RecordingScreen({
    super.key,
    required this.isRecording,
    required this.title,
    required this.ecgValues,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.grey[300],
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        if (isRecording)
          Container(
            height: 100,
            color: Colors.grey[400],
            child: Center(
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: ecgValues.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      ' ${ecgValues[index]} ',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
