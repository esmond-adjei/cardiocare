import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:xmonapp/main.dart';
import 'package:xmonapp/widgets/ecg_renderer.dart';
import 'package:xmonapp/services/models/db_helper.dart';
import 'package:xmonapp/services/models/db_model.dart';
import 'package:xmonapp/utils/singal_generator.dart';
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
  Map<String, int> _bpValues = {'systolic': 120, 'diastolic': 80};
  double _btempValue = 36.1;

  StreamSubscription<dynamic>? _subscription;

  final SignalGenerator _signalGenerator = SignalGenerator();

  final ScrollController _scrollController = ScrollController();
  final Stopwatch _stopwatch = Stopwatch();

  final DatabaseHelper _dbhelper = DatabaseHelper();

  dynamic _currentSignal;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, initialIndex: 0, vsync: this);
    // _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _subscription?.cancel();

    _scrollController.dispose();
    _stopwatch.reset();

    // _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();

    super.dispose();
  }

  // void _handleTabSelection() {
  //   if (isRecording && _tabController.indexIsChanging) {
  //     _tabController.index = _tabController.previousIndex;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('You cannot switch tabs while recording')),
  //     );
  //   }
  // }

  void _startRecording() {
    setState(() {
      isRecording = true;
      isPaused = false;
      _stopwatch.start();
    });

    switch (_tabController.index) {
      case 0:
        _currentSignal = EcgModel(
          userId: 1,
          startTime: DateTime.now(),
          stopTime: DateTime.now(),
          ecg: Uint8List.fromList(_ecgValues),
        );
        _subscription = _signalGenerator.generateECG().listen((value) {
          setState(() {
            _ecgValues.add(value);
            _scrollToEnd();
          });
        });
        break;
      case 1:
        _currentSignal = BpModel(
          userId: 1,
          startTime: DateTime.now(),
          stopTime: DateTime.now(),
          bpSystolic: _bpValues['systolic']!,
          bpDiastolic: _bpValues['diastolic']!,
        );
        _subscription = _signalGenerator.generateBP().listen((value) {
          setState(() {
            _bpValues = value;
            _scrollToEnd();
          });
        });
        break;
      case 2:
        _currentSignal = BtempModel(
          userId: 1,
          startTime: DateTime.now(),
          stopTime: DateTime.now(),
          bodyTemp: _btempValue,
        );
        _subscription = _signalGenerator.generateBtemp().listen((value) {
          setState(() {
            _btempValue = value;
            _scrollToEnd();
          });
        });
        break;
    }
  }

  void _stopRecording() {
    setState(() {
      isRecording = false;
      isPaused = false;
      _ecgValues.clear();
      _bpValues = {'systolic': 120, 'diastolic': 80};
      _btempValue = 36.1;
      _stopwatch.reset();
    });
    _subscription?.cancel();
  }

  void _pauseRecording() {
    setState(() {
      isPaused = true;
      _stopwatch.stop();
    });
    _subscription?.pause();
  }

  void _resumeRecording() {
    setState(() {
      isPaused = false;
      _stopwatch.start();
    });
    _subscription?.resume();
  }

  void _saveRecording() {
    _pauseRecording();
    _showSaveDialog();
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController
          .jumpTo(_scrollController.position.maxScrollExtent - 100);
    }
  }

  void _showSaveDialog() {
    TextEditingController textFieldController = TextEditingController();

    _currentSignal.stopTime = DateTime.now().add(_stopwatch.elapsed);
    textFieldController.text =
        '${_currentSignal.signalType} ${_currentSignal.stopTime.day}-${_currentSignal.stopTime.month}-${_currentSignal.stopTime.year} ${_currentSignal.stopTime.hour}:${_currentSignal.stopTime.minute}';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Save ${_currentSignal.signalType} Data'),
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
            ElevatedButton(
              onPressed: () async {
                try {
                  _currentSignal.setName(textFieldController.text);
                  switch (_tabController.index) {
                    case 0:
                      _currentSignal.setEcg(_ecgValues);
                      await _dbhelper.createEcgData(_currentSignal);
                      break;
                    case 1:
                      _currentSignal.setBp(
                        systolic: _bpValues['systolic']!,
                        diastolic: _bpValues['diastolic']!,
                      );
                      await _dbhelper.createBpData(_currentSignal);
                      break;
                    case 2:
                      _currentSignal.setBodyTemp(_btempValue);
                      await _dbhelper.createBtempData(_currentSignal);
                      break;
                  }

                  _stopRecording();

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data saved successfully')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to save data')));
                }
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
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainScreen(selectedIndex: 1),
                ),
                (route) => false,
              );
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
          // TAB VIEWS
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ECGRenderer(
                  isRecording: isRecording,
                  ecgValues: _ecgValues,
                  title: 'Monitor Your ECG',
                  scrollController: _scrollController,
                ),
                BPRenderer(
                  isRecording: isRecording,
                  bpValues: _bpValues,
                  title: 'Monitor Your Blood Pressure',
                ),
                BtempRenderer(
                  isRecording: isRecording,
                  btempValue: _btempValue,
                  title: 'Monitor Your Body Temperature',
                ),
              ],
            ),
          ),
          // TAB BARS
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(40),
            ),
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(4),
            child: TabBar(
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              labelColor: Colors.redAccent,
              unselectedLabelColor: Colors.grey[500],
              controller: _tabController,
              indicatorWeight: 0.0,
              labelPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              tabs: const [Text('ECG'), Text('BP'), Text('TEMP')],
            ),
          ),
          // RECORDING CONTROL BUTTONS
          Container(
            height: 100,
            padding: const EdgeInsets.all(16.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: !isRecording
                  ? ElevatedButton(
                      key: const ValueKey("start"),
                      onPressed: _startRecording,
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        shape: CircleBorder(
                          side: BorderSide(
                            color: Colors.redAccent.shade100,
                            width: 4,
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Icon(
                        Icons.fiber_manual_record,
                        color: Colors.redAccent,
                      ))
                  : Row(
                      key: const ValueKey("recording"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _stopRecording,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400,
                          ),
                          icon: const Icon(Icons.restart_alt_outlined),
                          label: const Text("Restart"),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed:
                              isPaused ? _resumeRecording : _pauseRecording,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amberAccent,
                          ),
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: isPaused
                                ? const Icon(Icons.play_arrow,
                                    key: ValueKey("play"))
                                : const Icon(Icons.pause,
                                    key: ValueKey("pause")),
                          ),
                          label: isPaused
                              ? const Text("Resume")
                              : const Text("Pause"),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _saveRecording,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400,
                          ),
                          icon: const Icon(Icons.done),
                          label: const Text("Done"),
                        ),
                      ],
                    ),
            ),
          ),
        ],
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
    if (!isRecording) {
      return Center(
        child: Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.grey.shade100,
            child: Column(children: [
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
  final Map<String, int> bpValues;

  const BPRenderer({
    super.key,
    required this.isRecording,
    required this.title,
    required this.bpValues,
  });

  @override
  Widget build(BuildContext context) {
    if (!isRecording) {
      return Center(
        child: Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildBloodPressureRow('systolic', bpValues['systolic']!),
          const SizedBox(height: 20),
          _buildBloodPressureRow('diastolic', bpValues['diastolic']!,
              color: Colors.redAccent[100]!),
        ],
      ),
    );
  }

  Widget _buildBloodPressureRow(String label, int value,
      {Color color = Colors.redAccent}) {
    return Row(
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
            Text(
              'mmHg',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 72.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 30),
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
