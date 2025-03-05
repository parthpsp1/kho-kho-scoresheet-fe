import 'package:intl/intl.dart';

String deriveFirstTimeDifference(int dataLength, data) {
  if (dataLength == 0) {
    return 'No Difference';
  }
  return 'Difference';
}

String deriveTimeDifference(List<Duration> perTimes, String symbol) {
  // To do - Update this logic to continue the loop
  perTimes = perTimes.reversed.toList();
  for (int i = perTimes.length - 1; i >= 0;) {
    if (symbol == 'SA' || symbol == 'L') {
      if (perTimes.length <= 2) {
        return "0:00";
      } else {
        return calculateTimeDifference(perTimes[i], perTimes[i - 2]).toString();
      }
    } else {
      if (perTimes.length == 1) {
        return perTimes[0].toString();
      } else {
        return calculateTimeDifference(perTimes[i], perTimes[i - 1]).toString();
      }
    }
  }

  return "0:00"; // Default return in case all conditions fail
}

Duration calculateTimeDifference(Duration time1, Duration time2) {
  return time2 - time1;
}

String formatDuration(Duration duration) {
  String minutes = (duration.inMinutes % 60).toString();
  String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String getDate() {
  DateTime now = DateTime.now();
  return DateFormat('dd MMM yyyy').format(now);
}

String getTime() {
  DateTime now = DateTime.now();
  return DateFormat('hh:mm a').format(now);
}

String getTimeDateForFileName() {
  DateTime now = DateTime.now();
  return DateFormat('yyyyMMdd_HHmmss').format(now);
}

Duration parseTime(String time) {
  List<String> parts = time.split(":");
  int minutes = int.parse(parts[0]);
  int seconds = int.parse(parts[1]);
  return Duration(minutes: minutes, seconds: seconds);
}
