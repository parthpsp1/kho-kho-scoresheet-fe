import 'package:intl/intl.dart';

String calculatePerTime(List<Duration> perTimes, String symbol) {
  int lastValidIndex = perTimes.length - 1; // Track the last valid index

  for (int i = perTimes.length - 1; i >= 0; i--) {
    if (i == 0) {
      return formatDuration(perTimes[lastValidIndex]);
    }
    if (symbol == 'SA' || symbol == 'L') {
      return "0:00";
    } else {
      if (perTimes[i - 1] == Duration.zero) {
        lastValidIndex = i; // Keep the current i if continue is used
        continue;
      } else {
        return calculateTimeDifference(
            perTimes[i - 1], perTimes[lastValidIndex]);
      }
    }
  }

  return "0:00"; // Default return in case all conditions fail
}

String calculateTimeDifference(Duration time1, Duration time2) {
  Duration difference = time2 - time1;
  return formatDuration(difference);
}

String formatDuration(Duration duration) {
  int minutes = duration.inMinutes;
  int seconds = duration.inSeconds.remainder(60);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String formatMultipleDurations(List<Duration> durations) {
  return durations.map((duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }).join(', ');
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
