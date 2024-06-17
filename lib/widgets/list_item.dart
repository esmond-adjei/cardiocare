import 'package:flutter/material.dart';
import 'package:xmonapp/main.dart';
import 'package:xmonapp/screens/drawers/signal_renderers.dart';
import 'package:xmonapp/screens/single_monitoring_layout.dart';
import 'package:xmonapp/services/constants.dart';
import 'package:xmonapp/services/models/db_helper.dart';
import 'package:xmonapp/services/models/db_model.dart';
import 'package:xmonapp/utils/format_datetime.dart';

class ListItem extends StatelessWidget {
  final Signal signal;
  final DatabaseHelper _dbhelper = DatabaseHelper();

  ListItem({
    super.key,
    required this.signal,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(signal.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) async {
        // Handle item deletion here
        int success = await _dbhelper.deleteSignal(signal);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${signal.name} ID: $success deleted successfully"),
          ),
        );
      },
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              title: Text("Delete ${signal.name}?"),
              content: const Text("Are you sure you want to delete this item?"),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("CANCEL"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("DELETE"),
                ),
              ],
            );
          },
        );
      },
      child: ListTile(
        iconColor: Colors.redAccent,
        splashColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        leading: const Icon(Icons.favorite),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailScreen(signal: signal)),
          );
        },
        title: Text(
          signal.name,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                formatDuration(
                  signal.startTime.toIso8601String(),
                  signal.stopTime.toIso8601String(),
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            Text(
              formatDateTime(signal.startTime.toIso8601String()),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final dynamic signal;

  const DetailScreen({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    switch (signal.signalType) {
      case ecgType:
        return Scaffold(
          appBar: AppBar(
            title: Text(signal.name),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MainScreen(selectedIndex: 1),
                      ),
                      (route) => false);
                },
                child: const Text(
                  'List',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SingleMonitorLayout(initialScreen: 0),
                      ));
                },
              ),
            ],
          ),
          body: Center(
            child: ECGRenderer(
              isRecording: true,
              ecgValues: signal.ecg,
              title: 'okay...',
            ),
          ),
        );
      case bpType:
        return Scaffold(
          appBar: AppBar(
            title: Text(signal.name),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MainScreen(selectedIndex: 1),
                      ),
                      (route) => false);
                },
                child: const Text(
                  'List',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SingleMonitorLayout(initialScreen: 1),
                      ));
                },
              ),
            ],
          ),
          body: Center(
            child: BPRenderer(
              isRecording: true,
              bpValues: {
                'systolic': signal.bpSystolic,
                'diastolic': signal.bpDiastolic
              },
              title: 'okay...',
            ),
          ),
        );
      case btempType:
        return Scaffold(
          appBar: AppBar(
            title: Text(signal.name),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MainScreen(selectedIndex: 1),
                      ),
                      (route) => false);
                },
                child: const Text(
                  'List',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SingleMonitorLayout(initialScreen: 2),
                      ));
                },
              ),
            ],
          ),
          body: Center(
            child: BtempRenderer(
              isRecording: true,
              btempValue: signal.bodyTemp,
              title: 'okay...',
            ),
          ),
        );
      default:
        return Scaffold(
          appBar: AppBar(
            title: Text(signal.toString()),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Signal Name: $signal',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        );
    }
  }
}
