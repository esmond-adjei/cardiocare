import 'package:intl/intl.dart';

String formatDuration(String startDateTime, String endDateTime) {
  final duration =
      DateTime.parse(endDateTime).difference(DateTime.parse(startDateTime));
  final List<String> parts = [];

  void addPart(int value, String unit) {
    if (value > 0) {
      parts.add('$value $unit${value > 1 ? 's' : ''}');
    }
  }

  addPart(duration.inDays, 'day');
  addPart(duration.inHours.remainder(24), 'hr');
  addPart(duration.inMinutes.remainder(60), 'min');
  addPart(duration.inSeconds.remainder(60), 'sec');

  return parts.isEmpty ? '0 secs' : parts.join(' ');
}

String formatDateTime(String timestamp) {
  final dateTime = DateTime.parse(timestamp);
  return DateFormat('d MMM yyyy HH:mm').format(dateTime);
}

String formatTime(int milliseconds) {
  final duration = Duration(milliseconds: milliseconds);
  return '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
}

String formatDateOnly(String timestamp) {
  final dateTime = DateTime.parse(timestamp);
  return DateFormat('d MMM yyyy').format(dateTime);
}

String formatWeekday(String timestamp) {
  final dateTime = DateTime.parse(timestamp);
  return DateFormat('EEEE').format(dateTime);
}

String formatRelativeDate(String timestamp) {
  final dateTime = DateTime.parse(timestamp);
  final difference = DateTime.now().difference(dateTime);

  final Map<String, int> units = {
    'day': difference.inDays,
    'hr': difference.inHours,
    'min': difference.inMinutes,
    'sec': difference.inSeconds,
  };

  for (var entry in units.entries) {
    if (entry.value > 0) {
      return '${entry.value} ${entry.key}${entry.value > 1 ? 's' : ''} ago';
    }
  }

  return 'Just now';
}

String formatRelativeDayDate(String timestamp) {
  final dateTime = DateTime.parse(timestamp);
  final difference = DateTime.now().difference(dateTime);

  if (difference.inDays > 3) {
    return '${formatWeekday(timestamp)}, ${formatDateOnly(timestamp)}';
  } else {
    return formatRelativeDate(timestamp);
  }
}
