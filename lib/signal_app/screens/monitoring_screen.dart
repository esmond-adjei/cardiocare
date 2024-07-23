import 'dart:developer' as dev;
import 'package:cardiocare/signal_app/screens/connect_device_screen.dart';
import 'package:cardiocare/signal_app/model/signal_enums.dart';
import 'package:cardiocare/utils/format_datetime.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cardiocare/main.dart';
import 'package:cardiocare/signal_app/widgets/signal_renderers.dart';
import 'package:cardiocare/services/db_helper.dart';
import 'package:cardiocare/signal_app/screens/monitoring_screen_state.dart';

class SingleMonitorLayout extends StatefulWidget {
  final int initialScreen;

  const SingleMonitorLayout({super.key, this.initialScreen = 1});

  @override
  State<SingleMonitorLayout> createState() => _SingleMonitorLayoutState();
}

class _SingleMonitorLayoutState extends State<SingleMonitorLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      initialIndex: widget.initialScreen,
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBluetoothConnection();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkBluetoothConnection() {
    final monitorState = Provider.of<MonitorState>(context, listen: false);
    if (!monitorState.isBluetoothConnected) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ConnectDevice()),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _showSaveDialog(MonitorState monitorState) {
    monitorState.pauseRecording();
    dynamic signal = monitorState.getCurrentSignal(_tabController.index);
    TextEditingController textFieldController = TextEditingController();
    textFieldController.text = signal.name;

    showDialog(
      context: context,
      builder: (context) {
        final DatabaseHelper dbHelper = Provider.of<DatabaseHelper>(context);
        return AlertDialog(
          title: Text('Save ${signal.signalType.name} Data'),
          content: TextField(
            controller: textFieldController,
            decoration: const InputDecoration(hintText: "Enter recording name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  signal.name = textFieldController.text;
                  signal.stopTime =
                      signal.startTime.add(monitorState.stopwatch.elapsed);
                  int signalId = -1;
                  switch (signal.signalType) {
                    case SignalType.ecg:
                      signal.storeEcg();
                      signalId = await dbHelper.createEcgData(signal);
                      break;
                    case SignalType.bp:
                      signalId = await dbHelper.createBpData(signal);
                      break;
                    case SignalType.btemp:
                      signalId = await dbHelper.createBtempData(signal);
                      break;
                  }
                  monitorState.stopRecording();
                  Navigator.pop(context);
                  _showSnackBar(
                      '${signal.name} saved successfully (ID: $signalId)');
                } catch (e) {
                  dev.log('>> CREATE_SIGNAL_ERROR: ${e.toString()}');
                  _showSnackBar('Failed to save data');
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MonitorState monitorState = Provider.of<MonitorState>(context);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildTimer(monitorState),
          _buildTabBarView(monitorState),
          _buildTabBar(monitorState),
          _buildControlButtons(monitorState),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final monitorState = Provider.of<MonitorState>(context, listen: false);
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      leading: IconButton(
        onPressed: () {
          if (monitorState.isRecording) {
            _showSnackBar('Cannot change tabs while recording is in progress.');
            return;
          }
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (monitorState.isRecording) {
              _showSnackBar(
                  'Cannot change tabs while recording is in progress.');
              return;
            }
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
    );
  }

  Widget _buildTimer(MonitorState monitorState) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        formatTime(monitorState.stopwatch.elapsedMilliseconds),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTabBarView(MonitorState monitorState) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        physics: monitorState.isRecording
            ? const NeverScrollableScrollPhysics()
            : null,
        children: [
          ECGRenderer(
            isActive: monitorState.isRecording,
            ecgSignal: monitorState.ecgSignal,
          ),
          BPRenderer(
            isActive: monitorState.isRecording,
            bpSignal: monitorState.bpSignal,
          ),
          BtempRenderer(
            isActive: monitorState.isRecording,
            btempSignal: monitorState.btempSignal,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(MonitorState monitorState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(40),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        indicator: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
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
        onTap: (index) {
          if (monitorState.isRecording) {
            _tabController.index = _tabController.previousIndex;
            _showSnackBar('Cannot switch tabs while recording is in progress.');
          }
        },
      ),
    );
  }

  Widget _buildControlButtons(MonitorState monitorState) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: !monitorState.isRecording
            ? ElevatedButton(
                key: const ValueKey("start"),
                onPressed: () {
                  monitorState.startRecording(_tabController.index);
                },
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
                ),
              )
            : Row(
                key: const ValueKey("recording"),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: monitorState.stopRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                    ),
                    icon: const Icon(Icons.restart_alt_outlined),
                    label: const Text("Restart"),
                  ),
                  const SizedBox(width: 16),

                  // ElevatedButton.icon(
                  //   onPressed: monitorState.isPaused
                  //       ? monitorState.resumeRecording
                  //       : monitorState.pauseRecording,
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: monitorState.isPaused
                  //         ? Colors.amberAccent
                  //         : Colors.grey.shade400,
                  //   ),
                  //   icon: AnimatedSwitcher(
                  //     duration: const Duration(milliseconds: 300),
                  //     transitionBuilder:
                  //         (Widget child, Animation<double> animation) {
                  //       return ScaleTransition(
                  //         scale: animation,
                  //         child: child,
                  //       );
                  //     },
                  //     child: monitorState.isPaused
                  //         ? const Icon(Icons.play_arrow, key: ValueKey("play"))
                  //         : const Icon(Icons.pause, key: ValueKey("pause")),
                  //   ),
                  //   label: Text(monitorState.isPaused ? "Resume" : "Paused"),
                  // ),
                  // const SizedBox(width: 16),

                  ElevatedButton.icon(
                    onPressed: () => _showSaveDialog(monitorState),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    icon: const Icon(Icons.done),
                    label: const Text("Done"),
                  ),
                ],
              ),
      ),
    );
  }
}
