import 'package:flutter/material.dart';
import 'package:xmonapp/services/models/db_model.dart';
import 'package:xmonapp/utils/format_datetime.dart';

class ListItem extends StatelessWidget {
  final Signal signal;

  const ListItem({
    super.key,
    required this.signal,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(signal.id.toString()), // Provide a unique key for each item
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        // Handle item deletion here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${signal.name} dismissed")),
        );
      },
      confirmDismiss: (direction) async {
        // You can show a confirmation dialog here
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Delete ${signal.name}?"),
              content: const Text("Are you sure you want to delete this item?"),
              actions: <Widget>[
                TextButton(
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
          // Navigate to detail screen or perform any action on tap
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
  final Signal signal;

  const DetailScreen({Key? key, required this.signal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(signal.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Signal Name: ${signal.name}',
              style: const TextStyle(fontSize: 20),
            ),
            // Display other details of the signal as needed
          ],
        ),
      ),
    );
  }
}
