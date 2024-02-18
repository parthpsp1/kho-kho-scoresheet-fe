import 'package:intl/intl.dart';

String deriveFirstTimeDifference(int dataLength, data) {
  if (dataLength == 0) {
    return 'No Difference';
  }
  return 'Difference';
}

List deriveTimeDifference(runTimes) {
  List perTimes = [];
  for (var i = runTimes.length - 1; i >= 0; i--) {
    if (i == 0) {
      perTimes.add(runTimes[0]['run_time']);
      return perTimes.reversed.toList();
    }
    if (runTimes[i]['symbol'] == 'SA' || runTimes[i]['symbol'] == 'L') {
      perTimes.add("0:00");
      continue;
    }

    if (runTimes[i - 1]['symbol'] == 'SA' || runTimes[i - 1]['symbol'] == 'L') {
      var result = formatDuration(calculateTimeDifference(
          runTimes[i]['run_time']!, runTimes[i - 2]['run_time']!));
      perTimes.add(result);
    } else {
      var result = formatDuration(calculateTimeDifference(
          runTimes[i]['run_time']!, runTimes[i - 1]['run_time']!));
      perTimes.add(result);
    }
  }
  return perTimes.reversed.toList();
}

Duration calculateTimeDifference(String time1, String time2) {
  List<int> parts1 = time1.split(':').map(int.parse).toList();
  List<int> parts2 = time2.split(':').map(int.parse).toList();

  Duration duration1 = Duration(minutes: parts1[0], seconds: parts1[1]);
  Duration duration2 = Duration(minutes: parts2[0], seconds: parts2[1]);

  return duration1 - duration2;
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
