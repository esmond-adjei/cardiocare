import 'package:flutter/material.dart';
import 'package:xmonapp/services/models/db_model.dart';
import 'package:xmonapp/utils/format_datetime.dart';

class ListItem extends StatelessWidget {
  // final String name;
  // final String startTime;
  // final String endTime;

  final Signal signal;

  const ListItem({
    super.key,
    required this.signal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        leading: const Icon(
          Icons.favorite,
          color: Colors.red,
        ),
        onTap: () {
          print('Tapped ${signal.id} - ${signal.name}');
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
                formatDuration(signal.startTime.toIso8601String(),
                    signal.stopTime.toIso8601String()),
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
