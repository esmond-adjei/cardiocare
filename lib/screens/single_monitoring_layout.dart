import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:xmonapp/screens/pages/ecg_renderer.dart';
import 'package:xmonapp/services/models/db_helper.dart';
import 'package:xmonapp/services/models/db_model.dart';
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
  late EcgModel _ecgSignal;
  final DatabaseHelper _dbhelper = DatabaseHelper();

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
    _stopwatch.reset();
    _tabController.dispose();
    _ecgGenerator.dispose();
    super.dispose();
  }

  void _startRecording() {
    _ecgSignal = EcgModel(
      userId: 1,
      startTime: DateTime.now(),
      stopTime: DateTime.now(),
      ecg: Uint8List.fromList([]),
    );
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
    _ecgSignal.stopTime =
        DateTime.now(); // change to use duration (same as timer's)
    _showSaveDialog();
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _showSaveDialog() {
    TextEditingController textFieldController = TextEditingController();
    textFieldController.text =
        'ECG ${_ecgSignal.stopTime.day}-${_ecgSignal.stopTime.month}-${_ecgSignal.stopTime.year} ${_ecgSignal.stopTime.hour}:${_ecgSignal.stopTime.minute}';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_ecgSignal.name),
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
              onPressed: () async {
                _ecgSignal.signalName = textFieldController.text;
                _ecgSignal.setEcg(_ecgValues);
                // Here you would save the recording with the given name

                Navigator.pop(context);

                int ecgID = await _dbhelper.createEcgData(_ecgSignal);
                // You can add logic here to actually save the data to the database or any other storage
                print(
                    "Recording saved as: ID-$ecgID, SN-${_ecgSignal.name} $_ecgSignal, ${_ecgSignal.ecg}");
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // title: const Text('Recorder', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
            child: const Text('List'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                ECGRenderer(
                  isRecording: isRecording,
                  ecgValues: _ecgValues,
                  title: 'ECG Graph Placeholder',
                  scrollController: _scrollController,
                ),
                BPRenderer(
                  isRecording: false,
                  ecgValues: _ecgValues,
                  title: 'Blood Pressure Graph Placeholder',
                  scrollController: _scrollController,
                ),
                BtempRenderer(
                  isRecording: false,
                  ecgValues: _ecgValues,
                  title: 'Body Temperature Graph Placeholder',
                  scrollController: _scrollController,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(40),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            padding: const EdgeInsets.all(4),
            child: TabBar(
              indicator: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(40),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              labelColor: Colors.redAccent,
              unselectedLabelColor: Colors.grey[600],
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
                      elevation: 2,
                      shape: CircleBorder(
                        side: BorderSide(color: Colors.red.shade200, width: 4),
                      ),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(
                      Icons.fiber_manual_record,
                      color: Colors.redAccent,
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
                        child: const Icon(Icons.restart_alt_rounded),
                      ),
                      const SizedBox(width: 16),
                      isPaused
                          ? ElevatedButton(
                              onPressed: _resumeRecording,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amberAccent,
                              ),
                              child: const Icon(Icons.play_arrow),
                            )
                          : ElevatedButton(
                              onPressed: _pauseRecording,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amberAccent,
                              ),
                              child: const Icon(Icons.pause),
                            ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _saveRecording,
                        child: const Icon(Icons.stop),
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

class ECGRenderer extends StatelessWidget {
  final bool isRecording;
  final String title;
  final List<int> ecgValues;
  final ScrollController scrollController;

  const ECGRenderer({
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
            color: Colors.grey.shade100,
            child: Column(children: [
              const SizedBox(height: 50),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const ECGChart(),
              Container(
                height: 50,
                color: Colors.grey.shade300,
                child: Center(
                  child: ListView.builder(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: ecgValues.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          ' ${ecgValues[index]} ',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class BPRenderer extends StatelessWidget {
  final bool isRecording;
  final String title;
  final List<int> ecgValues;
  final ScrollController scrollController;

  const BPRenderer({
    super.key,
    required this.isRecording,
    required this.title,
    required this.ecgValues,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 50),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Systolic'),
              Text(
                '80 mmHg',
                style: TextStyle(
                  fontSize: 42.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Diastolic'),
              Text(
                '60 mmHg',
                style: TextStyle(
                  fontSize: 42.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BtempRenderer extends StatelessWidget {
  final bool isRecording;
  final String title;
  final List<int> ecgValues;
  final ScrollController scrollController;

  const BtempRenderer({
    super.key,
    required this.isRecording,
    required this.title,
    required this.ecgValues,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 180.0,
            width: 180.0,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '36.1 °C',
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 30.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'min 32.9 °C',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 30.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'min 32.9 °C',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
