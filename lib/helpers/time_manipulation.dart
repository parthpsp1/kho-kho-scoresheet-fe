import 'package:intl/intl.dart';

String deriveFirstTimeDifference(int dataLength, data) {
  if (dataLength == 0) {
    return 'No Difference';
  }
  return 'Difference';
}

String deriveTimeDifference(List<Duration> perTimes, String symbol) {
  String result = "0:00";

  for (int i = 0; i < perTimes.length; i++) {
    if (symbol == 'SA' || symbol == 'L') {
      if (i - 2 < 0) {
        result = "0:00";
      } else {
        result =
            calculateTimeDifference(perTimes[i], perTimes[i - 2]).toString();
      }
    } else {
      if (i - 1 < 0) {
        result = "0:00";
      } else {
        result =
            calculateTimeDifference(perTimes[i], perTimes[i - 1]).toString();
      }
    }
  }
  return result;
}

Duration calculateTimeDifference(Duration time1, Duration time2) {
  return time1 - time2;
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
  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);
  return Duration(hours: hours, minutes: minutes);
}
