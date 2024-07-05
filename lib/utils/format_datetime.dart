String formatDuration(String startDateTime, String endDateTime) {
  final duration =
      DateTime.parse(endDateTime).difference(DateTime.parse(startDateTime));

  if (duration.inDays > 0) {
    String result = '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    if (duration.inHours.remainder(24) > 0) {
      result +=
          ' ${duration.inHours.remainder(24)} hr${duration.inHours.remainder(24) > 1 ? 's' : ''}';
    }
    if (duration.inMinutes.remainder(60) > 0) {
      result +=
          ' ${duration.inMinutes.remainder(60)} min${duration.inMinutes.remainder(60) > 1 ? 's' : ''}';
    }
    if (duration.inSeconds.remainder(60) > 0) {
      result +=
          ' ${duration.inSeconds.remainder(60)} sec${duration.inSeconds.remainder(60) > 1 ? 's' : ''}';
    }
    return result;
  } else if (duration.inHours > 0) {
    String result = '${duration.inHours} hr${duration.inHours > 1 ? 's' : ''}';
    if (duration.inMinutes.remainder(60) > 0) {
      result +=
          ' ${duration.inMinutes.remainder(60)} min${duration.inMinutes.remainder(60) > 1 ? 's' : ''}';
    }
    if (duration.inSeconds.remainder(60) > 0) {
      result +=
          ' ${duration.inSeconds.remainder(60)} sec${duration.inSeconds.remainder(60) > 1 ? 's' : ''}';
    }
    return result;
  } else if (duration.inMinutes > 0) {
    String result =
        '${duration.inMinutes} min${duration.inMinutes > 1 ? 's' : ''}';
    if (duration.inSeconds.remainder(60) > 0) {
      result +=
          ' ${duration.inSeconds.remainder(60)} sec${duration.inSeconds.remainder(60) > 1 ? 's' : ''}';
    }
    return result;
  } else if (duration.inSeconds > 0) {
    return '${duration.inSeconds} sec${duration.inSeconds > 1 ? 's' : ''}';
  } else {
    return '0 secs';
  }
}

String formatDateTime(String timestamp) {
  final dateTime = DateTime.parse(timestamp);
  return '${dateTime.day} ${getMonthName(dateTime.month)} ${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

String formatTime(int milliseconds) {
  final int seconds = milliseconds ~/ 1000;
  final int minutes = seconds ~/ 60;
  final int remainingSeconds = seconds % 60;

  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

String getMonthName(int month) {
  switch (month) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'Aug';
    case 9:
      return 'Sept';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
    default:
      return '';
  }
}
