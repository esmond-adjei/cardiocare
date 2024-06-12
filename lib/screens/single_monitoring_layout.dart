import 'package:flutter/material.dart';
import 'package:xmonapp/screens/pages/ecg_renderer.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, initialIndex: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: TimerWidget(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RecordingScreen(
                  isRecording: isRecording,
                  title: 'ECG Graph Placeholder',
                  onRecordingToggle: () {
                    setState(() {
                      isRecording = !isRecording;
                    });
                  },
                ),
                RecordingScreen(
                  isRecording: isRecording,
                  title: 'Blood Pressure Graph Placeholder',
                  onRecordingToggle: () {
                    setState(() {
                      isRecording = !isRecording;
                    });
                  },
                ),
                RecordingScreen(
                  isRecording: isRecording,
                  title: 'Body Temperature Graph Placeholder',
                  onRecordingToggle: () {
                    setState(() {
                      isRecording = !isRecording;
                    });
                  },
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
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isRecording = !isRecording;
                });
              },
              style: ElevatedButton.styleFrom(
                elevation: 4,
                shape: CircleBorder(
                  side: BorderSide(color: Colors.red.shade200, width: 4),
                ),
                padding: const EdgeInsets.all(16),
              ),
              child: Icon(
                isRecording ? Icons.pause : Icons.mic,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('discard'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Tab _buildTab(String text) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(text),
      ),
    );
  }
}

class RecordingScreen extends StatelessWidget {
  final bool isRecording;
  final String title;
  final VoidCallback onRecordingToggle;

  const RecordingScreen({
    super.key,
    required this.isRecording,
    required this.title,
    required this.onRecordingToggle,
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
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
        ),
        if (isRecording)
          Container(
            height: 100,
            color: Colors.grey[400],
            child: const Center(
              child: Text(
                'Recording Waveform Placeholder',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }
}
