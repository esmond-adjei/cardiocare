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
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) => PeakItemDrawer(signal: signal),
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

class PeakItemDrawer extends StatelessWidget {
  final dynamic signal;

  const PeakItemDrawer({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Wrap(
        children: [
          // Container(
          //   padding: const EdgeInsets.symmetric(vertical: 20.0),
          //   child:
          // ),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                signal.name,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${signal.description} Details',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        signal.signalType == ecgType
            ? ECGRenderer(
                isRecording: true,
                ecgValues: signal.ecg,
                title: signal.description,
              )
            : signal.signalType == bpType
                ? BPRenderer(
                    isRecording: true,
                    bpValues: {
                      'systolic': signal.bpSystolic,
                      'diastolic': signal.bpDiastolic
                    },
                    title: signal.description,
                  )
                : signal.signalType == btempType
                    ? BtempRenderer(
                        isRecording: true,
                        btempValue: signal.bodyTemp,
                        title: signal.description,
                      )
                    : const Center(
                        child: Text("Cannot find what you're looking for"),
                      )
      ],
    );
  }
}
